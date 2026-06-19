-- ==========================================
-- 1. SHUFFLE PLAYLIST (Key: F12)
-- ==========================================
function do_shuffle()
    mp.commandv("playlist-shuffle")
    mp.add_timeout(0.1, function()
        mp.commandv("playlist-move", mp.get_property_number("playlist-pos"), 0)
        mp.osd_message("Playlist Shuffled")
    end)
end
mp.add_key_binding("F12", "shuffle_action", do_shuffle)

-- ==========================================
-- 2. SAVE PLAYLIST (Key: Shift+P)
-- ==========================================
function do_save()
    local playlist = mp.get_property_native("playlist")
    local path = mp.get_property("path")
    if not path or not playlist then return end

    local dir = string.match(path, "(.*/)") or "/tmp/"
    local filename = dir .. "playlist_" .. os.date("%Y%m%d_%H%M%S") .. ".m3u8"

    local file, err = io.open(filename, "w")
    if file then
        file:write("#EXTM3U\n")
        for _, item in ipairs(playlist) do
            if item.filename then file:write(item.filename .. "\n") end
        end
        file:close()
        mp.osd_message("Playlist Saved to folder")
    else
        mp.osd_message("Save Error: " .. tostring(err))
    end
end
mp.add_key_binding("P", "save_action", do_save)

-- ==========================================
-- 3. DELETE FILE AND SKIP (Key: Shift+D)
-- ==========================================
function do_delete()
    local path = mp.get_property("path")
    if not path or path:find("http") then return end

    mp.command("playlist-next")

    local safe_path = string.gsub(path, '"', '\\"')
    local success = os.execute('gio trash "' .. safe_path .. '"')

    if success then
        mp.osd_message("Sent to Bin")
    else
        mp.osd_message("Failed to Delete")
    end
end
mp.add_key_binding("D", "delete_action", do_delete)
