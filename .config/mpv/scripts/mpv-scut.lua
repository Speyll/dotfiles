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

    -- Ensure absolute path for input file
    input_file = mp.command_native({"expand-path", input_file})

    -- Get directory of the input video file
    local file_dir = input_file:match("(.*/)")
    if not file_dir then
        mp.osd_message("Failed to determine video directory")
        return
    end

    -- Write segment files
    for i, segment in ipairs(segments) do
        local segment_file = string.format("%s/segment_%d.mp4", file_dir, i)
        local command = string.format('ffmpeg -i "%s" -ss %s -to %s -c copy "%s"', input_file, segment.start, segment.stop, segment_file)
        print("Executing command:", command)
        os.execute(command)
    end

    -- Create concat file
    local concat_file_path = string.format("%s/concat.txt", file_dir)
    local concat_file = io.open(concat_file_path, "w")
    if not concat_file then
        mp.osd_message("Failed to create concat file")
        return
    end

    for i, _ in ipairs(segments) do
        local segment_file = string.format("segment_%d.mp4", i)
        concat_file:write(string.format("file '%s'\n", segment_file))
    end
    concat_file:close()

    -- Merge segments
    local output_file = string.format("%s/merged_video.mp4", file_dir)
    local concat_command = string.format('ffmpeg -f concat -safe 0 -i "%s" -c copy "%s"', concat_file_path, output_file)
    print("Executing concat command:", concat_command)
    mp.osd_message("Merging segments...")
    os.execute(concat_command)
    mp.osd_message("Segments merged")

    -- Clean up
    os.remove(concat_file_path)
    for i, _ in ipairs(segments) do
        local segment_file = string.format("%s/segment_%d.mp4", file_dir, i)
        os.remove(segment_file)
    end

    mp.osd_message("Segments processed, temporary files deleted")
end

mp.add_key_binding("c", "start_segment", startSegment)
mp.add_key_binding("v", "end_segment", endSegment)
mp.add_key_binding("m", "process_segments", processSegments)

