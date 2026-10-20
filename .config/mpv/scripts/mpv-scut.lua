
local utils = require("mp.utils")
local logger = require("mp.msg")

local start_time = nil
local segments = {}
local is_processing = false
local active_session = nil
local session_counter = 0
local cuts_save_counter = 0
local cut_overlay = mp.create_osd_overlay("ass-events")
local status_overlay = mp.create_osd_overlay("ass-events")

function format_time(seconds)
    if not seconds then return "00:00" end
    local s = math.floor(seconds)
    return string.format("%02d:%02d", math.floor(s / 60), s % 60)
end

local function trim_text(value)
    local text = tostring(value or "")
    text = text:gsub("[\r\n]+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    if #text > 260 then text = text:sub(1, 257) .. "..." end
    return text
end

local function is_windows()
    return package.config:sub(1, 1) == "\\"
end

local function concat_entry(path)
    if is_windows() then path = path:gsub("\\", "/") end
    path = path:gsub("'", "'\\''")
    return path
end

local function find_temp_base()
    local candidates = is_windows() and {"TEMP", "TMP"} or {"TMPDIR", "TMP", "TEMP", "/tmp"}
    for _, name in ipairs(candidates) do
        local value = name:sub(1, 1) == "/" and name or os.getenv(name)
        if value and value ~= "" then
            local normalized = mp.command_native({"normalize-path", value}) or value
            local info = utils.file_info(normalized)
            if info and info.is_dir then return normalized end
        end
    end
    return nil
end

function get_file_info()
    local path = mp.get_property("path")
    if not path or path == "" then return nil, nil, nil, nil, "No file loaded." end
    if path:match("^%a[%w+.-]*://") then
        return nil, nil, nil, nil, "Only local files are supported."
    end

    local expanded = mp.command_native({"expand-path", path})
    if not expanded or expanded == "" then expanded = path end

    local dir, filename = utils.split_path(expanded)
    if not dir or not filename or filename == "" then
        return nil, nil, nil, nil, "Could not parse the file path."
    end

    local name, ext = filename, "mkv"
    local stem, real_ext = filename:match("^(.*)%.([^%.]+)$")
    if stem and stem ~= "" and real_ext and real_ext ~= "" then
        name, ext = stem, real_ext
    end

    return dir, name, ext, expanded
end

function update_overlay()
    if start_time then
        cut_overlay.data = string.format("{\\an7}{\\b1}{\\bord2}{\\3c&H111111&}{\\c&H00FF00&}✂ In: %s", format_time(start_time))
        cut_overlay:update()
    else
        cut_overlay:remove()
    end
end

function set_status(text, color_hex)
    status_overlay.data = string.format("{\\an9}{\\b1}{\\bord2}{\\3c&H111111&}{\\c&H%s&}%s", color_hex, text)
    status_overlay:update()
end

function clear_status()
    if not is_processing then status_overlay:remove() end
end

local function cleanup_session(session)
    if not session or session.cleaned then return end
    session.cleaned = true

    local files = session.files
    session.files = {}
    for path in pairs(files) do
        local ok = os.remove(path)
        if not ok and utils.file_info(path) then
            logger.warn("mpv-scut: could not remove temporary file: " .. path)
        end
    end
end

local function finish_session(session, success, message)
    if not session or active_session ~= session or session.finished then return end
    session.finished = true
    cleanup_session(session)
    active_session = nil
    is_processing = false

    if success then
        set_status("Success! Saved: " .. tostring(session.output_name), "00FF00")
        segments = {}
    else
        set_status("Failed: " .. trim_text(message), "0000FF")
    end
end

local function untrack_file(session, path)
    if path then session.files[path] = nil end
end

local function remove_file_if_present(path)
    if not path then return end
    local removed = os.remove(path)
    if not removed and utils.file_info(path) then
        logger.warn("mpv-scut: could not remove temporary file: " .. path)
    end
end

local function choose_output_path(dir, name, ext)
    for n = 1, 10000 do
        local suffix = n == 1 and "" or ("_" .. n)
        local output_name = name .. "_merged" .. suffix .. "." .. ext
        local output_path = utils.join_path(dir, output_name)
        if not utils.file_info(output_path) then
            return output_path, output_name
        end
    end
    return nil, nil, "Could not find a free output filename."
end

local function subprocess_error(result, error)
    if error and error ~= "" then return trim_text(error) end
    if not result then return "FFmpeg could not be started." end
    if result.error_string and result.error_string ~= "" then return trim_text(result.error_string) end
    if result.killed_by_us then return "FFmpeg was terminated." end
    if type(result.stderr) == "string" and result.stderr ~= "" then
        local line = result.stderr:match("([^\r\n]+)[\r\n]*$") or result.stderr
        return trim_text(line)
    end
    return "FFmpeg exited with status " .. tostring(result.status) .. "."
end

-- Core Logic
function startSegment()
    if is_processing then return end
    start_time = mp.get_property_number("time-pos")
    if not start_time then return end
    clear_status()
    update_overlay()
end

function endSegment()
    if is_processing then return end
    local end_time = mp.get_property_number("time-pos")
    if start_time and end_time and end_time > start_time then
        table.insert(segments, {start = start_time, stop = end_time})
        mp.osd_message(string.format("Segment %d saved (%s - %s)", #segments, format_time(start_time), format_time(end_time)), 3)
        start_time = nil
        update_overlay()
    else
        mp.osd_message("Error: Set a valid start point first!", 2)
    end
end

function clearSegments()
    if is_processing then return end
    start_time = nil
    segments = {}
    update_overlay()
    clear_status()
    mp.osd_message("All cuts and start points cleared.", 2)
end

local function make_save_token()
    cuts_save_counter = cuts_save_counter + 1
    return string.format(
        "mpv-scut-cuts-%d-%d-%d-%d",
        utils.getpid and utils.getpid() or 0,
        os.time(),
        math.floor((mp.get_time() or 0) * 1000),
        cuts_save_counter
    )
end

function saveCutsToFile()
    if #segments == 0 then
        mp.osd_message("No cuts to save!", 2)
        return
    end

    local dir, name, _, _, info_error = get_file_info()
    if not dir then
        mp.osd_message(info_error or "Only local files are supported.", 3)
        return
    end

    local cuts_path = utils.join_path(dir, name .. ".cuts.txt")
    local token = make_save_token()
    local temp_path = utils.join_path(dir, "." .. name .. ".cuts.txt." .. token .. ".tmp")
    local f, open_error = io.open(temp_path, "w")
    if not f then
        mp.osd_message("Could not save cuts: " .. trim_text(open_error), 3)
        return
    end

    local write_error
    for _, seg in ipairs(segments) do
        local ok, err = f:write(string.format("%f,%f\n", seg.start, seg.stop))
        if not ok then
            write_error = err or "write failed"
            break
        end
    end

    local flush_error
    if not write_error then
        local flushed, err = f:flush()
        if not flushed then flush_error = err or "flush failed" end
    end

    local closed, close_error = f:close()
    if write_error or flush_error or not closed then
        remove_file_if_present(temp_path)
        mp.osd_message("Could not save cuts: " .. trim_text(write_error or flush_error or close_error or "unknown error"), 3)
        return
    end

    if is_windows() and utils.file_info(cuts_path) then
        local backup_path = utils.join_path(dir, "." .. name .. ".cuts.txt." .. token .. ".bak")
        local backed_up, backup_error = os.rename(cuts_path, backup_path)
        if not backed_up then
            remove_file_if_present(temp_path)
            mp.osd_message("Could not save cuts: " .. trim_text(backup_error or "could not back up previous cuts"), 3)
            return
        end

        local replaced, replace_error = os.rename(temp_path, cuts_path)
        if not replaced then
            local restored, restore_error = os.rename(backup_path, cuts_path)
            remove_file_if_present(temp_path)
            local message = replace_error or "could not replace cuts file"
            if not restored then
                message = message .. "; previous cuts left at " .. backup_path
                if restore_error then message = message .. " (" .. restore_error .. ")" end
            end
            mp.osd_message("Could not save cuts: " .. trim_text(message), 3)
            return
        end

        local removed = os.remove(backup_path)
        if not removed and utils.file_info(backup_path) then
            logger.warn("mpv-scut: could not remove cuts backup: " .. backup_path)
        end
    else
        local replaced, replace_error = os.rename(temp_path, cuts_path)
        if not replaced then
            remove_file_if_present(temp_path)
            mp.osd_message("Could not save cuts: " .. trim_text(replace_error or "could not replace cuts file"), 3)
            return
        end
    end

    mp.osd_message("Cuts saved to: " .. name .. ".cuts.txt", 3)
end

function loadAndProcessCuts()
    if is_processing then return end

    local dir, name, _, _, info_error = get_file_info()
    if not dir then
        mp.osd_message(info_error or "Only local files are supported.", 3)
        return
    end

    local cuts_path = utils.join_path(dir, name .. ".cuts.txt")
    local f, open_error = io.open(cuts_path, "r")
    if not f then
        mp.osd_message("Could not open cuts file: " .. trim_text(open_error), 3)
        return
    end

    local loaded = {}
    local invalid = 0
    for line in f:lines() do
        local trimmed = line:gsub("^%s+", ""):gsub("%s+$", "")
        if trimmed ~= "" and trimmed:sub(1, 1) ~= "#" then
            local start_text, stop_text = trimmed:match("^([%d%.]+)%s*,%s*([%d%.]+)$")
            local start_value = tonumber(start_text)
            local stop_value = tonumber(stop_text)
            if start_value and stop_value and start_value >= 0 and stop_value > start_value then
                table.insert(loaded, {start = start_value, stop = stop_value})
            else
                invalid = invalid + 1
            end
        end
    end
    f:close()

    if #loaded == 0 then
        mp.osd_message(invalid > 0 and "No valid cuts found in cuts file." or "Cuts file empty.", 3)
        return
    end

    segments = loaded
    if invalid > 0 then
        mp.osd_message(string.format("%d invalid cut line(s) ignored.", invalid), 3)
    end
    processSegments()
end

-- ========================================================
-- ASYNC PROCESSING ENGINE
-- ========================================================
function processSegments()
    if #segments == 0 then
        set_status("No segments to process!", "0000FF")
        return
    end
    if is_processing then
        mp.osd_message("Already processing! Please wait.", 2)
        return
    end

    local dir, name, ext, input_file, info_error = get_file_info()
    if not dir then
        set_status(info_error or "Only local files are supported.", "0000FF")
        return
    end

    local temp_base = find_temp_base()
    if not temp_base then
        set_status("No usable temporary directory found.", "0000FF")
        return
    end

    local cuts = {}
    for i, seg in ipairs(segments) do
        if type(seg.start) ~= "number" or type(seg.stop) ~= "number" or
           seg.start < 0 or seg.stop <= seg.start then
            set_status(string.format("Invalid cut %d: stop must be after start.", i), "0000FF")
            return
        end
        cuts[i] = {start = seg.start, stop = seg.stop}
    end

    is_processing = true
    session_counter = session_counter + 1
    local token = string.format(
        "mpv-scut-%d-%d-%d-%d",
        utils.getpid and utils.getpid() or 0,
        os.time(),
        math.floor((mp.get_time() or 0) * 1000),
        session_counter
    )

    local session = {
        files = {},
        cuts = cuts,
        input_file = input_file,
        dir = dir,
        name = name,
        ext = ext,
        segment_files = {},
        output_name = nil,
        output_temp = nil,
        finished = false,
        cleaned = false,
    }
    active_session = session

    local function add_file(path)
        session.files[path] = true
        return path
    end

    for i = 1, #cuts do
        session.segment_files[i] = add_file(utils.join_path(temp_base, token .. "-segment-" .. i .. "." .. ext))
    end
    local concat_path = add_file(utils.join_path(temp_base, token .. "-concat.txt"))
    session.output_temp = add_file(utils.join_path(dir, "." .. token .. "-merged." .. ext))

    local function fail(message)
        finish_session(session, false, message)
    end

    local function merge_segments()
        if active_session ~= session or session.finished then return end
        set_status("Merging segments...", "00FFFF")

        local concat_file, open_error = io.open(concat_path, "w")
        if not concat_file then
            fail("Could not write concat file: " .. trim_text(open_error))
            return
        end

        for i = 1, #cuts do
            local escaped = concat_entry(session.segment_files[i])
            local ok, write_error = concat_file:write(string.format("file '%s'\n", escaped))
            if not ok then
                concat_file:close()
                fail("Could not write concat file: " .. trim_text(write_error))
                return
            end
        end

        local closed, close_error = concat_file:close()
        if not closed then
            fail("Could not close concat file: " .. trim_text(close_error))
            return
        end

        mp.command_native_async({
            name = "subprocess",
            args = {
                "ffmpeg", "-nostdin", "-hide_banner", "-loglevel", "error", "-y",
                "-f", "concat", "-safe", "0", "-i", concat_path,
                "-c", "copy", session.output_temp
            },
            playback_only = false,
            capture_stderr = true,
            capture_size = 1048576
        }, function(success, result, error)
            if active_session ~= session or session.finished then return end
            if not (success and result and result.status == 0) then
                fail("Merge failed: " .. subprocess_error(result, error))
                return
            end

            local info = utils.file_info(session.output_temp)
            if not info or not info.is_file or info.size == 0 then
                fail("Merge produced no output.")
                return
            end

            local output_path, output_name, output_error = choose_output_path(dir, name, ext)
            if not output_path then
                fail(output_error or "Could not find a free output filename.")
                return
            end

            local moved, move_error = os.rename(session.output_temp, output_path)
            if not moved then
                fail("Could not move output: " .. trim_text(move_error))
                return
            end

            untrack_file(session, session.output_temp)
            session.output_temp = nil
            session.output_name = output_name
            finish_session(session, true, "")
        end)
    end

    local current_segment = 1

    local function cut_next_segment()
        if active_session ~= session or session.finished then return end
        if current_segment > #cuts then
            merge_segments()
            return
        end

        local seg = cuts[current_segment]
        local segment_file = session.segment_files[current_segment]
        local duration = seg.stop - seg.start
        set_status(string.format("Cutting segment %d of %d...", current_segment, #cuts), "00FFFF")

        mp.command_native_async({
            name = "subprocess",
            args = {
                "ffmpeg", "-nostdin", "-hide_banner", "-loglevel", "error", "-y",
                "-ss", tostring(seg.start), "-i", input_file,
                "-t", tostring(duration), "-c", "copy",
                "-avoid_negative_ts", "make_zero", segment_file
            },
            playback_only = false,
            capture_stderr = true,
            capture_size = 1048576
        }, function(success, result, error)
            if active_session ~= session or session.finished then return end
            if success and result and result.status == 0 then
                current_segment = current_segment + 1
                cut_next_segment()
            else
                fail(string.format("Segment %d failed: %s", current_segment, subprocess_error(result, error)))
            end
        end)
    end

    cut_next_segment()
end

-- ========================================================
-- KEYBINDS
-- ========================================================
mp.add_key_binding("Ctrl+Shift+i", "start_segment", startSegment)
mp.add_key_binding("Ctrl+Shift+o", "end_segment", endSegment)
mp.add_key_binding("Ctrl+Shift+e", "process_segments", processSegments)
mp.add_key_binding("Ctrl+Shift+s", "save_cuts", saveCutsToFile)
mp.add_key_binding("Ctrl+Shift+r", "load_cuts", loadAndProcessCuts)
mp.add_key_binding("Ctrl+Shift+x", "clear_segments", clearSegments)

mp.register_event("file-loaded", function()
    start_time = nil
    update_overlay()
    if not is_processing then
        segments = {}
        status_overlay:remove()
    end
end)

mp.register_event("shutdown", function()
    local session = active_session
    if not session then return end
    active_session = nil
    is_processing = false
    session.finished = true
    cleanup_session(session)
end)
