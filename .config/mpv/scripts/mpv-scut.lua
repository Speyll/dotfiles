local start_time = nil
local segments = {}
local osd_message_id = nil
local osd_persistent = false
local segments_file_path = nil

-- Get the path for the segments file based on the video file name
function getSegmentsFilePath()
    local input_file = mp.get_property("path")
    input_file = mp.command_native({"expand-path", input_file})
    local file_dir = input_file:match("(.*/)")
    local file_name = input_file:match("([^/]+)%.%w+$")
    return string.format("%s/%s_segments.txt", file_dir, file_name)
end

-- Start segment at the current playback position
function startSegment()
    start_time = mp.get_property_number("time-pos")
    osd_persistent = true
    osd_message_id = mp.osd_message("Segment start point set")
end

-- End segment at the current playback position
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

-- Save segments to file
function saveSegmentsToFile()
    if #segments == 0 then
        osd_persistent = false
        osd_message_id = mp.osd_message("No segments to save")
        return
    end

    segments_file_path = getSegmentsFilePath()
    local segments_file = io.open(segments_file_path, "w")
    if not segments_file then
        osd_persistent = false
        osd_message_id = mp.osd_message("Failed to create segments file")
        return
    end

    for _, segment in ipairs(segments) do
        segments_file:write(string.format("%s,%s\n", segment.start, segment.stop))
    end
    segments_file:close()
    osd_persistent = true
    osd_message_id = mp.osd_message("Segments saved to file")
end

-- Load segments from file
function loadSegmentsFromFile()
    segments_file_path = getSegmentsFilePath()
    local segments_file = io.open(segments_file_path, "r")
    if not segments_file then
        osd_persistent = false
        osd_message_id = mp.osd_message("Failed to read segments file")
        return
    end

    segments = {}
    for line in segments_file:lines() do
        local start, stop = line:match("([^,]+),([^,]+)")
        table.insert(segments, {start = tonumber(start), stop = tonumber(stop)})
    end
    segments_file:close()
end

-- Process segments (cut and merge)
function processSegments()
    if #segments == 0 then
        osd_persistent = false
        osd_message_id = mp.osd_message("No segments to process")
        return
    end

    saveSegmentsToFile()

    local input_file = mp.get_property("path")
    input_file = mp.command_native({"expand-path", input_file})
    local file_dir = input_file:match("(.*/)")
    local file_name = input_file:match("([^/]+)%.%w+$")
    if not file_dir or not file_name then
        osd_persistent = false
        osd_message_id = mp.osd_message("Failed to determine video directory or file name")
        return
    end

    for i, segment in ipairs(segments) do
        local segment_file = string.format("%s/%s_segment_%d.mp4", file_dir, file_name, i)
        local command = string.format('ffmpeg -i "%s" -ss %s -to %s -c copy "%s"', input_file, segment.start, segment.stop, segment_file)
        print("Executing command:", command)
        os.execute(command)
    end

    local concat_file_path = string.format("%s/%s_concat.txt", file_dir, file_name)
    local concat_file = io.open(concat_file_path, "w")
    if not concat_file then
        osd_persistent = false
        osd_message_id = mp.osd_message("Failed to create concat file")
        return
    end

    for i, _ in ipairs(segments) do
        local segment_file = string.format("%s_segment_%d.mp4", file_name, i)
        concat_file:write(string.format("file '%s'\n", segment_file))
    end
    concat_file:close()

    local output_file = string.format("%s/%s_merged.mp4", file_dir, file_name)
    local concat_command = string.format('ffmpeg -f concat -safe 0 -i "%s" -c copy "%s"', concat_file_path, output_file)
    print("Executing concat command:", concat_command)
    osd_persistent = true
    osd_message_id = mp.osd_message("Merging segments...")
    os.execute(concat_command)
    osd_message_id = mp.osd_message("Segments merged")

    os.remove(concat_file_path)
    for i, _ in ipairs(segments) do
        local segment_file = string.format("%s/%s_segment_%d.mp4", file_dir, file_name, i)
        os.remove(segment_file)
    end

    osd_persistent = false
    osd_message_id = mp.osd_message("Segments processed, temporary files deleted")
end

-- Retry processing segments using the segments file
function retryProcessSegments()
    loadSegmentsFromFile()
    processSegments()
end

-- Update OSD message if persistent
function updateOSDMessage(message)
    if osd_persistent then
        osd_message_id = mp.osd_message(message, osd_message_id)
    end
end

-- Key bindings
mp.add_key_binding("c", "start_segment", startSegment)
mp.add_key_binding("x", "end_segment", endSegment)
mp.add_key_binding("z", "process_segments", processSegments)
mp.add_key_binding("r", "retry_process_segments", retryProcessSegments)
mp.add_key_binding("s", "save_segments_to_file", saveSegmentsToFile)

-- Clear OSD on shutdown
mp.register_event("shutdown", function()
    if osd_message_id then
        mp.osd_message("")
    end
end)

-- Periodic OSD update
mp.add_periodic_timer(0.5, function()
    if osd_persistent and start_time then
        updateOSDMessage("Segment in progress...")
    end
end)

