-- ~/.config/mpv/scripts/autoprofile.lua

local function has_hevc_support()
    -- We ask ffmpeg to list supported hardware decoders for HEVC.
    -- This is much more reliable than parsing 'vainfo' output.
    local cmd = "ffmpeg -hide_banner -hwaccels"
    local handle = io.popen(cmd)
    if not handle then return false end
    local output = handle:read("*a")
    handle:close()

    -- Check if vaapi or vdpau is listed as a supported hwaccel
    if output:find("vaapi") or output:find("vdpau") then
        return true
    end

    return false
end

-- Apply logic
if has_hevc_support() then
    print("Hardware Decoding (VAAPI/VDPAU) detected. Applying modern profile.")
    mp.commandv("apply-profile", "modern-hardware")
else
    print("No hardware decoding found. Applying legacy profile.")
    mp.commandv("apply-profile", "legacy-intel-laptop")
end
