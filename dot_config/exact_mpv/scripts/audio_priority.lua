local msg = require 'mp.msg'

local selected_for_file = false

local function lower(s)
    return string.lower(s or '')
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

local function contains(s, list)
    for _, value in ipairs(list) do
        if s:find(value, 1, true) then
            return true
        end
    end
    return false
end

local function matches_lang(s, token_list, text_list)
    return has_token(s, token_list) or contains(s, text_list)
end

local function score_audio(track)
    local identity = table.concat({ track.lang or '', track.title or '' }, ' ')

    if matches_lang(identity, { 'jpn', 'ja', 'jp', 'jap', 'japanese', 'nihongo' }, { '日本', '日本語', '日語', 'japanese' }) then
        return 300
    elseif matches_lang(identity, { 'eng', 'en', 'english' }, { 'англ', 'english' }) then
        return 200
    elseif matches_lang(identity, { 'rus', 'ru', 'russian' }, { 'рус', 'russian' }) then
        return 100
    end

    return 0
end

local function select_audio()
    if selected_for_file then
        return
    end

    local best_id = nil
    local best_score = 0

    for _, track in ipairs(mp.get_property_native('track-list', {})) do
        if track.type == 'audio' then
            local score = score_audio(track)
            if score > best_score then
                best_score = score
                best_id = track.id
            end
        end
    end

    selected_for_file = true

    if best_id ~= nil then
        mp.set_property_number('aid', best_id)
        msg.info('selected audio track ' .. best_id .. ' with score ' .. best_score)
    end
end

mp.register_event('file-loaded', function()
    selected_for_file = false
    mp.add_timeout(0.1, select_audio)
end)
