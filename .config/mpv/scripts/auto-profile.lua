-- ~/.config/mpv/scripts/auto-profile.lua

-- Select a hardware profile only when the hardware is *positively* identified.
-- Anything inconclusive (no DRM render node, missing/failed `vainfo`, unknown
-- vendor) leaves mpv's normal configured/default behaviour untouched, because
-- failing to identify hardware does not prove it is the legacy Intel laptop.
--
--   modern-hardware     -> a successful VAAPI probe reports an HEVC profile
--                          with the decoding entrypoint (VAEntrypointVLD)
--   legacy-intel-laptop -> a successful VAAPI probe reports an Intel device
--                          that does not expose HEVC decoding
--   (no profile)        -> anything else

local function has_render_node()
    local handle = io.popen("ls /dev/dri/renderD* 2>/dev/null")
    if not handle then return false end
    local output = handle:read("*a") or ""
    handle:close()
    return output:find("renderD") ~= nil
end

-- Run `vainfo` and return its output plus exit status. `rc` is nil when the
-- shell itself could not be started.
local function vainfo_probe()
    local handle = io.popen('vainfo 2>/dev/null; echo "__RC=$?"')
    if not handle then return nil, nil end
    local output = handle:read("*a") or ""
    handle:close()
    local rc = tonumber(output:match("__RC=(%d+)"))
    output = output:gsub("__RC=%d+\n?", "")
    return output, rc
end

-- An HEVC profile only means decoding if its entrypoint is VAEntrypointVLD
-- (an encoding-only profile such as VAEntrypointEncSlice must not count), so
-- require both to appear on the same line.
local function has_hevc_decode(info)
    for line in info:gmatch("[^\n]+") do
        if line:find("VAProfileHEVC") and line:find("VAEntrypointVLD") then
            return true
        end
    end
    return false
end

local function apply(name, why)
    print("auto-profile: " .. why .. "; applying '" .. name .. "'.")
    mp.commandv("apply-profile", name)
end

if not has_render_node() then
    print("auto-profile: no DRM render node found; keeping default profile.")
else
    local info, rc = vainfo_probe()
    if info == nil or rc == nil or rc ~= 0 then
        print("auto-profile: VAAPI probe unavailable or failed; keeping default profile.")
    elseif has_hevc_decode(info) then
        apply("modern-hardware", "HEVC VAAPI decoding detected")
    elseif info:find("Intel") then
        apply("legacy-intel-laptop", "Intel VAAPI without HEVC detected")
    else
        print("auto-profile: no matching hardware detected; keeping default profile.")
    end
end
