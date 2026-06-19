local start_time = nil
local segments = {}

function get_file_info()
    local path = mp.get_property("path")
    if not path or path:find("http") then return nil, nil, nil end
    path = mp.command_native({"expand-path", path})
    local dir = string.match(path, "(.-)[^/\\]+$")
    local name = string.match(path, "([^/\\]+)%.%w+$")
    local ext = string.match(path, "%.(%w+)$") or "mkv"
    return dir, name, ext, path
end

function startSegment()
    start_time = mp.get_property_number("time-pos")
    mp.osd_message(string.format("Start: %02d:%02d", start_time / 60, start_time % 60), 2)
end

function endSegment()
    local end_time = mp.get_property_number("time-pos")
    if start_time and end_time > start_time then
        table.insert(segments, {start = start_time, stop = end_time})
        mp.osd_message(string.format("Segment %d saved", #segments), 2)
        start_time = nil
    else
        mp.osd_message("Error: Set start point first!", 2)
    end
end

function processSegments()
    if #segments == 0 then return end
    local dir, name, ext, input_file = get_file_info()

    mp.osd_message("Cutting (Lossless)...", 3)

    -- 1. Cut segments with STREAM COPY (Instant, no re-encoding)
    -- Adding '-avoid_negative_ts make_zero' helps ffmpeg align the audio/video perfectly
    for i, segment in ipairs(segments) do
        local segment_file = string.format("%s%s_segment_%d.%s", dir, name, i, ext)
        mp.command_native({
            name = "subprocess",
            args = {
                "ffmpeg", "-y", "-ss", tostring(segment.start), "-to", tostring(segment.stop),
                "-i", input_file, "-c", "copy", "-avoid_negative_ts", "make_zero", segment_file
            },
            playback_only = false
        })
    end

    -- 2. Create concat file
    local concat_path = string.format("%s%s_concat.txt", dir, name)
    local concat_file = io.open(concat_path, "w")
    for i, _ in ipairs(segments) do
        concat_file:write(string.format("file '%s_segment_%d.%s'\n", name, i, ext))
    end
    concat_file:close()

    -- 3. Merge segments (Copy stream)
    local output_file = string.format("%s%s_merged.%s", dir, name, ext)
    local merge_res = mp.command_native({
        name = "subprocess",
        args = {"ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", concat_path, "-c", "copy", output_file},
        playback_only = false
    })

    -- Cleanup
    os.remove(concat_path)
    for i, _ in ipairs(segments) do
        os.remove(string.format("%s%s_segment_%d.%s", dir, name, i, ext))
    end

    if merge_res.status == 0 then
        mp.osd_message("Saved as: " .. name .. "_merged." .. ext, 4)
        segments = {}
    else
        mp.osd_message("Merge failed.", 4)
    end
end

-- [Key bindings remain the same]
mp.add_key_binding("c", "start_segment", startSegment)
mp.add_key_binding("x", "end_segment", endSegment)
mp.add_key_binding("z", "process_segments", processSegments)
