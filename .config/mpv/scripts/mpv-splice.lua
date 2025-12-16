-- -----------------------------------------------------------------------------
--
-- MPV Splice
-- URL: https://github.com/pvpscript/mpv-video-splice
--
-- Requires: ffmpeg
--
-- Description:
--
-- This script provides the hability to create video slices by grabbing two
-- timestamps, which generate a slice from timestamp A[i] to timestamp B[i],
-- e.g.:
-- 	-> Slice 1: 00:10:34.25 -> 00:15:00.00.
-- 	-> Slice 2: 00:23:00.84 -> 00:24:10.00.
-- 	...
-- 	-> Slice n: 01:44:22.47 -> 01:56:00.00.
--
-- Then, all the slices from 1 to n are joined together, creating a new
-- video.
--
-- The output file will appear at the directory that the mpv command was ran,
-- or in the environment variable set for it (see Environment variables below)
--
-- Note: This script prevents the mpv player from closing when the video ends,
-- so that the slices don't get lost. Keep this in mind if there's the option
-- 'keep-open=no' in the current config file.
--
-- Note: This script will also silence the terminal, so the script messages
-- can be seen more clearly.
--
-- -----------------------------------------------------------------------------
--
--
-- Usage:
--
-- In the video screen, press Alt + T to grab the first timestamp and then
-- press Alt + T again to get the second timestamp. This process will generate
-- a time range, which represents a video slice. Repeat this process to create
-- more slices.
--
-- To see all the slices made, press Alt + P. All of the slices will appear
-- in the terminal in order of creation, with their corresponding timestamps.
-- Incomplete slices will show up as 'Slice N in progress', where N is the
-- slice number.
--
-- To reset an incomplete slice, press Alt + R. If the first part of a slice
-- was created at the wrong time, this will reset the current slice.
--
-- To delete a whole slice, start the slice deletion mode by pressing Alt + D.
-- When in this mode, it's possible to press Alt + NUM, where NUM is any
-- number between 0 inclusive and 9 inclusive. For each Alt + NUM pressed, a
-- number will be concatenated to make the final number referring to the slice
-- to be removed, then press Alt + D again to stop the slicing deletion mode
-- and delete the slice corresponding to the formed number.
--
-- Example 1: Deleting slice number 3
-- 	-> Alt + D 	# Start slice deletion mode
-- 	-> Alt + 3	# Concatenate number 3
-- 	-> Alt + D	# Exit slice deletion mode
--
-- Example 2> Deleting slice number 76
-- 	-> Alt + D 	# Start slice deletion mode
-- 	-> Alt + 7	# Concatenate number 7
-- 	-> Alt + 6	# Concatenate number 6
-- 	-> Alt + D	# Exit slice deletion mode
--
-- To fire up ffmpeg, which will slice up the video and concatenate the slices
-- together, press Alt + C. It's important that there are at least one
-- slice, otherwise no video will be created.
--
-- Note: No cut will be made unless the user presses Alt + C.
-- Also, the original video file won't be affected by the cutting.
--
--
-- -----------------------------------------------------------------------------
--
--
-- Log level:
--
-- Everytime a timestamp is grabbed, a text will appear on the screen showing
-- the selected time.
-- When Alt + P is pressed, besides showing the slices in the terminal,
-- it will also show on the screen the total number of cuts (or slices)
-- that were made.
-- When the actual cutting and joining process begins, a message will be shown
-- on the screen and the terminal telling that it began. When the process ends,
-- a message will appear on the screen and the terminal displaying the full path
-- of the generated video. It will also appear a message in the terminal telling
-- that the process ended.
--
-- Note: Every message that appears on the terminal has the log level of 'info'.
--
--
-- -----------------------------------------------------------------------------
--
--
-- Environment Variables:
--
-- This script uses environment variables to allow the user to
-- set the temporary location of the video cuts and for setting the location for
-- the resulting video.
--
-- To set the temporary directory, set the variable MPV_SPLICE_TEMP;
-- e.g.: export MPV_SPLICE_TEMP="$HOME/temporary_location"
--
-- To set the video output directory, set the variable MPV_SPLICE_OUTPUT;
-- e.g.: export MPV_SPLICE_OUTPUT="$HOME/output_location"
--
-- Make sure the directories set in the variables really exist, or else the
-- script might fail.
--
-- -----------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Importing the mpv libraries

local mp = require 'mp'
local msg = require 'mp.msg'
local opt = require 'mp.options'
local utils = require 'mp.utils'

--------------------------------------------------------------------------------
-- Setup os dependent stuff

-- Not the best way to check OS, but it should work
local _os = package.config:sub(1, 1) == "/" and "unix" or "windows"

local _default_output_path = mp.get_property("working-directory")

system_dependent = {
    default_output_path = _os == "unix"
                                 and _default_output_path
                                 or _default_output_path:gsub("\\", "/"),

    tmp_path = _os == "unix"
                      and "/tmp"
                      or string.format("%s/Temp", os.getenv("LOCALAPPDATA"):gsub("\\", "/")),

    mkdir = _os == "unix" and "mkdir" or "md",

    rm = _os == "unix" and "rm -rf" or "rd /s /q",
}

--------------------------------------------------------------------------------
-- Setup config

local SCRIPT_NAME = "mpv-splice"

local config = {
    concat_file_name = "concat",

    ffmpeg_cmd = "ffmpeg -hide_banner -loglevel warning",
    ffmpeg_filter = "-c copy -copyts -avoid_negative_ts make_zero",

    tmp_path = system_dependent.tmp_path,
    output_path = system_dependent.default_output_path,
}
opt.read_options(config, SCRIPT_NAME)

--------------------------------------------------------------------------------

local function notify(message, duration)
	local duration = duration or 2

	msg.info(message)
	mp.osd_message(message, duration)
end

local function seconds_to_clock(secs)
	local hours = math.floor(secs / 3600)
	local mins = math.floor((secs - hours * 3600) / 60)
	local secs = secs - hours * 3600 - mins * 60

    return {
        h = hours,
        m = mins,
        s = secs,
    }
end

local function current_timestamp()
	local seconds = mp.get_property_number('time-pos')
    local time_data = seconds_to_clock(seconds)

	return string.format('%02d:%02d:%05.2f', time_data.h, time_data.m, time_data.s)
end

slice_data = {
    _start_timestamp_message = "[START TIMESTAMP]",
    _end_timestamp_message = "[END TIMESTAMP]",

    _timestamps = {},
    _pieces = function(self)
        return #self._timestamps
    end,
    pieces = function(self)
        return self:_pieces()
    end,

    remove = {
        _ongoing = false,
        to_be_removed = "",

        append = function(self, value)
            self.to_be_removed = self.to_be_removed .. value
        end,

        is_ongoing = function(self)
            return self._ongoing
        end,

        is_empty = function(self)
            return self.to_be_removed == ""
        end,

        set_ongoing = function(self)
            self._ongoing = true
        end,

        clear = function(self)
            self._ongoing = false
            self.to_be_removed = ""

            notify("Exited slice deletion mode.")
        end,
    },

    _pairs = function(self)
        return math.floor(self:_pieces() / 2)
    end,

    _has_incomplete_slice = function(self)
        return not (self:_pieces() % 2 == 0)
    end,

    _put_time = function(self, value)
        table.insert(self._timestamps, value)
    end,

    _add_piece = function(self, timestamp)
        self:_put_time(timestamp)

        local message = self:_has_incomplete_slice()
                        and self._start_timestamp_message
                        or self._end_timestamp_message

        notify(message)
    end,

    _as_pairs_coroutine_handler = nil,
    _as_pairs_coroutine_create = function(self)
        local function _as_pairs_coroutine_closure(self)
            local pair = 1

            for piece = 1, self:_pieces(), 2 do
                coroutine.yield({
                    index = pair,
                    p_start = self._timestamps[piece],
                    p_end = self._timestamps[piece + 1],
                })

                pair = pair + 1
            end
        end

        self._as_pairs_coroutine_handler =
            coroutine.create(_as_pairs_coroutine_closure)
    end,

    as_pairs = function(self)
        self:_as_pairs_coroutine_create()

        return function()
            local _, ret = coroutine.resume(self._as_pairs_coroutine_handler, self)
            return ret
        end
    end,

    add_time = function(self)
        local timestamp = current_timestamp()

        slice_data:_add_piece(timestamp)
    end,
    
    show_timestamps = function(self)
        notify(string.format("Total cuts: %d", self:_pairs()))

        local pair = 1

        for piece = 1, self:_pieces(), 2 do
            local t_start = self._timestamps[piece]
            local t_end = self._timestamps[piece + 1]

            msg.info(string.format("Slice %d: %s -> %s", pair, t_start, t_end))

            pair = pair + 1
        end

        if self:_has_incomplete_slice() then
            notify(string.format("Slice %d in progress.", self:_pairs() + 1))
        end
    end,

    reset_current_slice = function(self)
        if self:_has_incomplete_slice() then
            notify(string.format("Slice %d reset.", self:_pairs() + 1))
            
            table.remove(self._timestamps)
        end
    end,

    remove_slice = function(self)
        local pair_index = tonumber(self.remove.to_be_removed)
        local piece_index = pair_index * 2 - 1

        if pair_index > 0 and pair_index <= self:_pairs() then
            table.remove(self._timestamps, piece_index)
            table.remove(self._timestamps, piece_index)

            notify(string.format("Removed slice %d", pair_index))
        end
    end,

    add_number_key_bindings = function(self)
        -- Add shortcut keys to the interval {0..9}.
        for i = 0, 9, 1 do
            local key_code = "Alt+" .. i
            local binding_name = "num_key_" .. i
            local key_action = function()
                self.remove:append(i)
                notify(string.format("Slice to remove: %d", self.remove.to_be_removed), 1)
            end

            mp.add_key_binding(key_code, binding_name, key_action)
        end
    end,

    remove_number_key_bindings = function(self)
        for i = 0, 9, 1 do
            mp.remove_key_binding("num_key_" .. i)
        end
    end,

    delete_slice = function(self, index)
        if not self.remove:is_ongoing() then
            self.remove:set_ongoing()

            notify("Entered slice deletion mode.")

            self:add_number_key_bindings()
        elseif self.remove:is_ongoing() and self.remove:is_empty() then
            self.remove:clear()
        else
            self:remove_number_key_bindings()
            self:remove_slice()
            self.remove:clear()
        end
    end,
}

local quit = {
    _exit_count = 0,

    prevent_quit = function(self, pieces, name)
        if pieces > 0 then
            if self._exit_count >= 1 then
                mp.command(name)
            else
                notify("There are timestamp pieces set. Press again to quit.", 3)
                self._exit_count = self._exit_count + 1
            end
        else
            mp.command(name)
        end
    end,
}

local random = {
    alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",

    _started = false,

	-- Better seed randomization
    _first_startup = function(self)
        if not self._started then
            math.randomseed(os.time())
            for i = 1, 3, 1 do
                math.random()
            end

            self._started = true
        end
    end,

    random_string = function(self, size)
        self:_first_startup()

        local rnd_str = ""

        for i = 1, size, 1 do
            local rnd_index = math.floor(math.random() * #self.alphabet + 0.5)
            rnd_str = rnd_str .. self.alphabet:sub(rnd_index, rnd_index)
        end

        return rnd_str
    end,
}

concat_file = {
    _path = nil,
    _handler = nil,

    _create_file_path = function(self, tmp_path, name)
        local name = name or "concat"
        local file_name = string.format("%s.txt", name)

        return utils.join_path(tmp_path, file_name)
    end,

    get_path = function(self)
        return self._path
    end,

    create = function(self, tmp_path, name)
        self._path = self:_create_file_path(tmp_path, name)
        self._handler = io.open(self._path, "w")
    end,

    add_file = function(self, path)
        local path_line = string.format("file '%s'\n", path)

        self._handler:write(path_line)
    end,

    close = function(self)
        self._handler:close()
    end,
}

--------------------------------------------------------------------------------

local function add_time()
    slice_data:add_time()
end

local function show_timestamps()
    slice_data:show_timestamps()
end

local function reset_current_slice()
    slice_data:reset_current_slice()
end

local function delete_slice()
    slice_data:delete_slice()
end

--------------------------------------------------------------------------------

local function file_info()
    local path = mp.get_property('path')
    local name = mp.get_property('filename')
    local name_without_ext = mp.get_property('filename/no-ext')

    local ext = name == name_without_ext
                and ""
                or string.gsub(name, '.*%.(.*)$', '%1')

    return {
        path = path,
        full_name = name,
        name_only = name_without_ext,
        ext = ext
    }
end

local function make_temp_dir(tmp_path)
    local tmp_path_name = string.format(
        "%s_%s",
        "video-splice-tmp", random:random_string(10)
    )
    local full_tmp_path = utils.join_path(tmp_path, tmp_path_name)

    local mkdir_cmd = string.format(
        "%s \"%s\" 2>&1",
        system_dependent.mkdir, full_tmp_path
    )

    local handler = io.popen(mkdir_cmd)
    local cmd_output = handler:read("*l")

    handler:close()

    if cmd_output ~= nil then
        error(cmd_output)
    end

    return full_tmp_path
end

local function output_file_path(file_name, ext)
    local random_string = random:random_string(10)
    local output_file = string.format(
        "%s_%s_cut.%s",
        file_name, random_string, ext
    )

    return utils.join_path(config.output_path, output_file)
end

local function make_cut_path(tmp_path, piece_index, ext)
    local random_string = random:random_string(10)

    local file_name = string.format(
        "slice_%s_%d.%s",
        random_string, piece_index, ext
    )

    return utils.join_path(tmp_path, file_name)
end

local function run_ffmpeg_cut(piece, input_file_path, output_cut_path)
    local cmd = string.format(
        "%s -ss %s -i \"%s\" -to %s %s %s",
        config.ffmpeg_cmd,
        piece.p_start, input_file_path, piece.p_end,
        config.ffmpeg_filter,
        output_cut_path
    )

    os.execute(cmd)
end

local function make_timestamp_cuts(tmp_path, curr_file_path, curr_file_ext)
    for piece in slice_data:as_pairs() do
        local cut_path = make_cut_path(tmp_path, piece.index, curr_file_ext)

        run_ffmpeg_cut(piece, curr_file_path, cut_path)
        concat_file:add_file(cut_path)
    end

    concat_file:close()
end

local function concat_pieces(cat_file_path, output_file)
    cmd = string.format(
        "%s -f concat -safe 0 -i \"%s\" -c copy \"%s\"",
        config.ffmpeg_cmd, cat_file_path, output_file
    )
    os.execute(cmd)
end

local function cleanup(path)
    cmd = string.format(
        "%s \"%s\"",
        system_dependent.rm, path
    )
    os.execute(cmd)

    msg.info(string.format("Directory \"%s\" removed!", path))
end

function process_video()
    local file_info = file_info()
    local output_file = output_file_path(file_info.name_only, file_info.ext)
    local tmp_path = make_temp_dir(config.tmp_path)

    -- Make concat file
    concat_file:create(tmp_path, config.concat_file_name)

    notify("Process started!")

    -- Make timestamp cuts
    make_timestamp_cuts(tmp_path, file_info.path, file_info.ext)

    -- Make the concat cmd, using the concat.txt file
    concat_pieces(concat_file:get_path(), output_file)

    notify(string.format("File saved as: %s", output_file), 10)
    msg.info("Process ended!")

    -- Cleanup
    cleanup(tmp_path)
end

mp.set_property("keep-open", "yes") -- Prevent mpv from exiting when the video ends
mp.set_property("quiet", "yes") -- Silence terminal.

mp.add_key_binding('q', "quit", function()
	quit:prevent_quit(slice_data:pieces(), "quit")
end)
mp.add_key_binding('Shift+q', "quit-watch-later", function()
	quit:prevent_quit(slice_data:pieces(), "quit-watch-later")
end)

mp.add_key_binding('Alt+t', "put_time", add_time)
mp.add_key_binding('Alt+p', "show_times", show_timestamps)
mp.add_key_binding('Alt+c', "process_video", process_video)
mp.add_key_binding('Alt+r', "reset_current_slice", reset_current_slice)
mp.add_key_binding('Alt+d', "delete_slice", delete_slice)
