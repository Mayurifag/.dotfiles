local msg = require 'mp.msg'
local utils = require 'mp.utils'

local selected_for_file = false
local sub_exts = { ass = true, srt = true, ssa = true, sub = true, vtt = true }

local function lower(s)
    return string.lower(s or '')
end

local function dirname(path)
    path = path or ''
    return path:match('^(.*)[/\\][^/\\]*$') or ''
end

local function basename(path)
    path = path or ''
    return path:match('([^/\\]*)$') or path
end

local function extension(path)
    return lower(path:match('%.([^%.]+)$'))
end

local function strip_extension(path)
    return (path or ''):gsub('%.[^%.]+$', '')
end

local function starts_with(s, prefix)
    return s:sub(1, #prefix) == prefix
end

local function tokens(s)
    return ' ' .. lower(s):gsub('[^%w]+', ' ') .. ' '
end

local function has_token(s, list)
    local t = tokens(s)
    for _, token in ipairs(list) do
        if t:find(' ' .. token .. ' ', 1, true) then
            return true
        end
    end
    return false
end

local function folder_has(path, list)
    local dir = dirname(path)
    for part in dir:gmatch('[^/\\]+') do
        if has_token(part, list) then
            return true
        end
    end
    return false
end

local function matches_video(sub_name, video_base)
    local sub_base = lower(strip_extension(sub_name))
    local base = lower(video_base)
    return starts_with(sub_base, base) or starts_with(base, sub_base)
end

local function subtitle_key(path)
    return lower(strip_extension(basename(path)))
end

local function sub_dir_priority(name)
    if has_token(name, { 'chi', 'chs', 'cht', 'zh', 'zho', 'chinese' }) then
        return nil
    elseif has_token(name, { 'rus', 'ru', 'russian' }) then
        return 1
    elseif has_token(name, { 'eng', 'en', 'english' }) then
        return 2
    end

    return nil
end

local function collect_sub_dirs(base_dir)
    local result = {}
    local seen = {}

    local function add(path, priority)
        if not seen[path] then
            table.insert(result, { path = path, priority = priority })
            seen[path] = true
        end
    end

    local function scan(parent, depth)
        local dirs = utils.readdir(parent, 'dirs') or {}
        table.sort(dirs)

        for _, dir in ipairs(dirs) do
            local path = utils.join_path(parent, dir)
            local priority = sub_dir_priority(dir)

            if priority ~= nil then
                add(path, priority)
                if depth < 2 then
                    scan(path, depth + 1)
                end
            end
        end
    end

    scan(base_dir, 0)

    table.sort(result, function(a, b)
        if a.priority == b.priority then
            return lower(a.path) < lower(b.path)
        end
        return a.priority < b.priority
    end)

    return result
end

local function loaded_subs()
    local loaded = { paths = {}, keys = {} }
    for _, track in ipairs(mp.get_property_native('track-list', {})) do
        local filename = track['external-filename']
        if track.type == 'sub' and filename ~= nil then
            loaded.paths[filename] = true
            loaded.keys[subtitle_key(filename)] = true
        end
    end
    return loaded
end

local function load_folder_subtitles()
    local video_path = mp.get_property('path', '')
    local video_dir = dirname(video_path)
    local video_base = strip_extension(basename(video_path))
    local loaded = loaded_subs()

    for _, dir in ipairs(collect_sub_dirs(video_dir)) do
        local sub_dir = dir.path
        local files = utils.readdir(sub_dir, 'files') or {}
        table.sort(files)

        for _, file in ipairs(files) do
            local path = utils.join_path(sub_dir, file)
            local key = subtitle_key(file)
            if sub_exts[extension(file)] and not loaded.paths[path] and not loaded.keys[key] and matches_video(file, video_base) then
                mp.commandv('sub-add', path, 'auto')
                loaded.paths[path] = true
                loaded.keys[key] = true
            end
        end
    end
end

local function score_sub(track, video_dir)
    local filename = track['external-filename'] or ''
    local name = basename(filename)
    local title = track.title or ''
    local lang = track.lang or ''
    local identity = table.concat({ name, title, lang }, ' ')
    local score = 0

    if has_token(identity, { 'chi', 'chs', 'cht', 'zh', 'zho', 'chinese' }) or
        folder_has(filename, { 'chi', 'chs', 'cht', 'chinese' }) then
        return -10000
    end

    if has_token(identity, { 'rus', 'ru', 'russian' }) then
        score = score + 400
    elseif folder_has(filename, { 'rus', 'russian' }) then
        score = score + 300
    end

    if has_token(identity, { 'eng', 'en', 'english' }) then
        score = score + 100
    elseif folder_has(filename, { 'eng', 'english' }) then
        score = score + 80
    end

    if filename ~= '' and dirname(filename) == video_dir then
        score = score + 50
    end

    return score
end

local function select_subtitle()
    if selected_for_file then
        return
    end

    local tracks = mp.get_property_native('track-list', {})
    local video_dir = dirname(mp.get_property('path', ''))
    local best_id = nil
    local best_score = -1
    local found = false

    for _, track in ipairs(tracks) do
        if track.type == 'sub' and track.external then
            found = true
            local score = score_sub(track, video_dir)
            if score > best_score then
                best_score = score
                best_id = track.id
            end
        end
    end

    selected_for_file = true

    if found and best_score < 0 then
        mp.set_property('sid', 'no')
        msg.info('ignored Chinese subtitles')
    elseif best_id ~= nil and best_score > 0 then
        mp.set_property_number('sid', best_id)
        msg.info('selected subtitle track ' .. best_id .. ' with score ' .. best_score)
    end
end

mp.register_event('file-loaded', function()
    selected_for_file = false
    load_folder_subtitles()
    mp.add_timeout(0.1, select_subtitle)
end)
