-- src: https://codeberg.org/mva/mpv_sponsorblock_minimal/raw/branch/master/sponsorblock_minimal.lua
-- sponsorblock_minimal.lua
--
-- This script skips sponsored segments of YouTube videos
-- using data from https://github.com/ajayyy/SponsorBlock

local utils = require 'mp.utils'

local options = {
    API = "https://sponsor.ajay.app/api/skipSegments",
    -- Categories to fetch and skip
    categories = '"sponsor","intro","outro","interaction","selfpromo"'
}

function getranges()
    local args = {
        "curl",
        "-s",
        "-d",
        "videoID=" .. youtube_id,
        "-d",
        "categories=[" .. options.categories .. "]",
        "-G",
        options.API
    }
    local sponsors = mp.command_native({name = "subprocess", capture_stdout = true, playback_only = false, args = args})

    ranges = {}
    local data = utils.parse_json(sponsors.stdout)
    if sponsors.status == 0 and type(data) == 'table' then
        for _, entry in ipairs(data) do
            local segment = type(entry) == 'table' and entry.segment
            if type(segment) == 'table' and type(segment[1]) == 'number' and type(segment[2]) == 'number' then
                table.insert(ranges, segment)
            end
        end
    end
end

function skip_ads(name, pos)
    if pos ~= nil then
        for _, segment in ipairs(ranges) do
            local start_time, end_time = segment[1], segment[2]
            if start_time <= pos and end_time > pos then
                --this message may sometimes be wrong
                --it only seems to be a visual thing though
                mp.osd_message(
                    "[sponsorblock] skipping forward " .. math.floor(end_time - mp.get_property("time-pos")) .. "s"
                )
                --need to do the +0.01 otherwise mpv will start spamming skip sometimes
                --example: https://www.youtube.com/watch?v=4ypMJzeNooo
                mp.set_property("time-pos", end_time + 0.01)
                return
            end
        end
    end
end

function file_loaded()
    local video_path = mp.get_property("path", "")
    local video_referer = string.match(mp.get_property("http-header-fields", ""), "Referer:([^,]+)") or ""

    local urls = {
        "https?://youtu%.be/([%w-_]+).*",
        "https?://w?w?w?%.?youtube%.com/v/([%w-_]+).*",
        "/watch.*[?&]v=([%w-_]+).*",
        "/embed/([%w-_]+).*",
        "-([%w-_]+)%."
    }
    youtube_id = nil
    local purl = mp.get_property("metadata/by-key/PURL", "")
    for i, url in ipairs(urls) do
        youtube_id =
            youtube_id or string.match(video_path, url) or string.match(video_referer, url) or string.match(purl, url)
    end

    if not youtube_id or string.len(youtube_id) < 11 then
        return
    end
    youtube_id = string.sub(youtube_id, 1, 11)

    getranges()
    if #ranges > 0 then
        ON = true
        mp.add_key_binding("b", "sponsorblock", toggle)
        mp.observe_property("time-pos", "native", skip_ads)
    end
end

function end_file()
    mp.unobserve_property(skip_ads)
    mp.remove_key_binding("sponsorblock")
    ranges = nil
    ON = false
end

function toggle()
    if ON then
        mp.unobserve_property(skip_ads)
        mp.osd_message("[sponsorblock] off")
    else
        mp.observe_property("time-pos", "native", skip_ads)
        mp.osd_message("[sponsorblock] on")
    end
    ON = not ON
end

mp.register_event("file-loaded", file_loaded)
mp.register_event("end-file", end_file)
