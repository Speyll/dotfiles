local start_time = nil
local segments = {}

function startSegment()
    start_time = mp.get_property_number("time-pos")
    mp.osd_message("Start of segment set")
end

function endSegment()
    local end_time = mp.get_property_number("time-pos")
    if start_time then
        table.insert(segments, {start = start_time, stop = end_time})
        start_time = nil
        mp.osd_message("Segment added")
    else
        mp.osd_message("No start point set")
    end
end

function processSegments()
    if #segments == 0 then
        mp.osd_message("No segments to process")
        return
    end

    local input_file = mp.get_property("path")
    local file_dir = mp.get_property("working-directory")
    local output_file = string.format("%s/merged_video.mp4", file_dir)

    local concat_file = io.open("concat.txt", "w")
    for i, segment in ipairs(segments) do
        local segment_file = string.format("segment_%d.mp4", i)
        concat_file:write(string.format("file '%s'\n", segment_file))

        local command = string.format('ffmpeg -i "%s" -ss %s -to %s -c:v copy -c:a copy "%s"', input_file, segment.start, segment.stop, segment_file)
        print("Executing command:", command)
        os.execute(command)
    end
    concat_file:close()

    local concat_command = string.format('ffmpeg -f concat -i concat.txt -c:v copy -c:a copy "%s"', output_file)
    print("Executing concat command:", concat_command)
    os.execute(concat_command)

    os.remove("concat.txt")

    -- Delete segment files
    for i, _ in ipairs(segments) do
        local segment_file = string.format("%s/segment_%d.mp4", file_dir, i)
        os.remove(segment_file)
    end

    mp.osd_message("Segments processed, merged, and temporary files deleted")
end

mp.add_key_binding("c", "start_segment", startSegment)
mp.add_key_binding("v", "end_segment", endSegment)
mp.add_key_binding("m", "process_segments", processSegments)
