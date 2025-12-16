local utils = require 'mp.utils'

function delete_current_file()
    local file_path = mp.get_property("path")
    if file_path == nil then
        mp.msg.error("No file is currently loaded.")
        return
    end

    local args = {"rm", file_path}
    local res = utils.subprocess({ args = args, cancellable = false })

    if res.status == 0 then
        mp.msg.info("Deleted file: " .. file_path)
        -- Move to the next file in the playlist
        mp.command("playlist-next")
    else
        mp.msg.error("Failed to delete file: " .. file_path)
    end
end

mp.register_command("delete-current", delete_current_file, "Delete the currently playing file.")
