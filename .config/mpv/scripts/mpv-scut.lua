local start_time = nil
local segments = {}
local is_processing = false
local cut_overlay = mp.create_osd_overlay("ass-events")
local status_overlay = mp.create_osd_overlay("ass-events")

function format_time(seconds)
    if not seconds then return "00:00" end
    local s = math.floor(seconds)
    return string.format("%02d:%02d", math.floor(s / 60), s % 60)
end

function get_file_info()
    local path = mp.get_property("path")
    if not path or path:find("http") then return nil, nil, nil, nil end
    path = mp.command_native({"expand-path", path})
    local dir = string.match(path, "(.-)[^/\\]+$")
    local name = string.match(path, "([^/\\]+)%.%w+$")
    local ext = string.match(path, "%.(%w+)$") or "mkv"
    return dir, name, ext, path
end

-- UI Updates (Now with dark borders for perfect contrast)
function update_overlay()
    if start_time then
        cut_overlay.data = string.format("{\\an7}{\\b1}{\\bord2}{\\3c&H111111&}{\\c&H00FF00&}✂ In: %s", format_time(start_time))
        cut_overlay:update()
    else
        cut_overlay:remove()
    end
end

function set_status(msg, color_hex)
    status_overlay.data = string.format("{\\an9}{\\b1}{\\bord2}{\\3c&H111111&}{\\c&H%s&}%s", color_hex, msg)
    status_overlay:update()
end

function clear_status()
    if not is_processing then status_overlay:remove() end
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

function saveCutsToFile()
    if #segments == 0 then
        mp.osd_message("No cuts to save!", 2)
        return
    end
    local dir, name, _ = get_file_info()
    if not dir then return end
    local cuts_path = dir .. name .. ".cuts.txt"
    local f = io.open(cuts_path, "w")
    if f then
        for _, seg in ipairs(segments) do f:write(string.format("%f,%f\n", seg.start, seg.stop)) end
        f:close()
        mp.osd_message("Cuts saved to: " .. name .. ".cuts.txt", 3)
    end
end

function loadAndProcessCuts()
    if is_processing then return end
    local dir, name, _, _ = get_file_info()
    if not dir then return end
    local cuts_path = dir .. name .. ".cuts.txt"
    local f = io.open(cuts_path, "r")
    if not f then
        mp.osd_message("No cuts file found.", 2)
        return
    end
    segments = {}
    for line in f:lines() do
        local st, sp = line:match("([%d%.]+),([%d%.]+)")
        if st and sp then table.insert(segments, {start = tonumber(st), stop = tonumber(sp)}) end
    end
    f:close()
    if #segments > 0 then processSegments() else mp.osd_message("Cuts file empty.", 2) end
end

-- ========================================================
-- ASYNC PROCESSING ENGINE (The Cream of the Crop)
-- ========================================================
function processSegments()
    if #segments == 0 then
        set_status("No segments to process!", "0000FF") -- Red
        return
    end
    if is_processing then
        mp.osd_message("Already processing! Please wait.", 2)
        return
    end

    local dir, name, ext, input_file = get_file_info()
    if not dir then return end

    is_processing = true

    -- Create isolated tmp directory for this specific session
    local session_id = tostring(math.floor(mp.get_time() * 1000))
    local base_tmp = os.getenv("TMPDIR") or "/tmp"
    local session_tmp = string.format("%s/mpv_cutter_%s/", base_tmp, session_id)
    os.execute('mkdir -p "' .. session_tmp .. '"')

    local current_segment = 1
    local concat_path = session_tmp .. "concat.txt"

    -- Function 3: Cleanup and Finish
    local function finish_processing(success, msg)
        os.execute('rm -rf "' .. session_tmp .. '"') -- Nuke the temp folder cleanly
        if success then
            set_status("Success! Saved: " .. name .. "_merged." .. ext, "00FF00") -- Green
            segments = {} -- clear memory on success
        else
            set_status("Failed: " .. msg, "0000FF") -- Red
        end
        is_processing = false
    end

    -- Function 2: Merge the segments asynchronously
    local function merge_segments()
        set_status("Merging segments...", "00FFFF") -- Yellow

        -- Write concat file
        local concat_file = io.open(concat_path, "w")
        for i = 1, #segments do
            -- Use absolute paths in the concat file to be 100% bulletproof
            local seg_file = string.format("%ssegment_%d.%s", session_tmp, i, ext)
            concat_file:write(string.format("file '%s'\n", seg_file:gsub("'", "'\\''")))
        end
        concat_file:close()

        local output_file = string.format("%s%s_merged.%s", dir, name, ext)

        mp.command_native_async({
            name = "subprocess",
            args = {"ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", concat_path, "-c", "copy", output_file}
        }, function(success, result, error)
            if result and result.status == 0 then
                finish_processing(true, "")
            else
                finish_processing(false, "Merge failed.")
            end
        end)
    end

    -- Function 1: Recursive asynchronous segment cutter
    local function cut_next_segment()
        if current_segment > #segments then
            merge_segments() -- All cut, move to merge
            return
        end

        set_status(string.format("Cutting segment %d of %d...", current_segment, #segments), "00FFFF")
        local seg = segments[current_segment]
        local segment_file = string.format("%ssegment_%d.%s", session_tmp, current_segment, ext)

        mp.command_native_async({
            name = "subprocess",
            args = {
                "ffmpeg", "-y", "-ss", tostring(seg.start), "-to", tostring(seg.stop),
                "-i", input_file, "-c", "copy", "-avoid_negative_ts", "make_zero", segment_file
            }
        }, function(success, result, error)
            if result and result.status == 0 then
                current_segment = current_segment + 1
                cut_next_segment() -- Loop recursively to next segment
            else
                finish_processing(false, "Failed on segment " .. current_segment)
            end
        end)
    end

    -- Kick off the async chain
    cut_next_segment()
end

-- ========================================================
-- KEYBINDS
-- ========================================================
mp.add_key_binding("I", "start_segment", startSegment)           -- Shift + i : Mark In (Start)
mp.add_key_binding("O", "end_segment", endSegment)               -- Shift + o : Mark Out (End)
mp.add_key_binding("P", "process_segments", processSegments)     -- Shift + p : Process (Merge) Cuts
mp.add_key_binding("S", "save_cuts", saveCutsToFile)             -- Shift + s : Save cuts to text file
mp.add_key_binding("L", "load_cuts", loadAndProcessCuts)         -- Shift + l : Load cuts & Process
mp.add_key_binding("C", "clear_segments", clearSegments)         -- Shift + c : Clear start point and all cuts
