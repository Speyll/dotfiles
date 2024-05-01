local start_time = nil
local segments = {}
local osd_message_id = nil
local osd_persistent = false

function startSegment()
    start_time = mp.get_property_number("time-pos")
    osd_persistent = true
    osd_message_id = mp.osd_message("Segment start point set")
end

function endSegment()
    local end_time = mp.get_property_number("time-pos")
    if start_time then
        table.insert(segments, {start = start_time, stop = end_time})
        start_time = nil
        osd_persistent = true
        osd_message_id = mp.osd_message("Segment end point set")
    else
        osd_persistent = false
        osd_message_id = mp.osd_message("No start point set")
    end
end

function processSegments()
    if #segments == 0 then
        osd_persistent = false
        osd_message_id = mp.osd_message("No segments to process")
        return
    end

    local input_file = mp.get_property("path")

    -- Ensure absolute path for input file
    input_file = mp.command_native({"expand-path", input_file})

    -- Get directory of the input video file
    local file_dir = input_file:match("(.*/)")
    if not file_dir then
        osd_persistent = false
        osd_message_id = mp.osd_message("Failed to determine video directory")
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
        osd_persistent = false
        osd_message_id = mp.osd_message("Failed to create concat file")
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
    osd_persistent = true
    osd_message_id = mp.osd_message("Merging segments...")
    os.execute(concat_command)
    osd_message_id = mp.osd_message("Segments merged")

    -- Clean up
    os.remove(concat_file_path)
    for i, _ in ipairs(segments) do
        local segment_file = string.format("%s/segment_%d.mp4", file_dir, i)
        os.remove(segment_file)
    end

    osd_persistent = false
    osd_message_id = mp.osd_message("Segments processed, temporary files deleted")
end

function updateOSDMessage(message)
    if osd_persistent then
        osd_message_id = mp.osd_message(message, osd_message_id)
    end
end

mp.add_key_binding("c", "start_segment", startSegment)
mp.add_key_binding("x", "end_segment", endSegment)
mp.add_key_binding("z", "process_segments", processSegments)

mp.register_event("shutdown", function()
    if osd_message_id then
        mp.osd_message("")
    end
end)

mp.add_periodic_timer(0.5, function()
    if osd_persistent and start_time then
        updateOSDMessage("Segment in progress...")
    end
end)
