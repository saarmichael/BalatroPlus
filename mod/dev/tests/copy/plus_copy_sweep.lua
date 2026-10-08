local T = BPlus.test

-- Table-driven sweep for Architect and Hive Mind (D23 + the later "regular ability" fallback).
-- For every vanilla joker with a "+" version, and for its "+" version as a target:
--   * the compat state shown on the copier matches the rule
--       vanilla target: ("+" carpenter_compat and "+" blueprint_compat) or vanilla blueprint_compat
--       "+" target:     "+" blueprint_compat
--   * BPlus.copy_plus.mode names the right ability ('view' = "+" ability, 'direct' = as it is)
--   * a discard, a played hand and the end of the round raise no error with the copier in play.

local function sorted_keys()
    local keys = {}
    for vk in pairs(BPlus.upgrade_map) do keys[#keys + 1] = vk end
    table.sort(keys)
    return keys
end

local function expected(vk)
    local vanilla = G.P_CENTERS[vk]
    local plus = G.P_CENTERS[BPlus.upgrade_map[vk]]
    local view = plus.bplus.carpenter_compat and plus.blueprint_compat
    local v_mode = view and 'view' or (vanilla.blueprint_compat and 'direct' or nil)
    local p_mode = plus.blueprint_compat and 'direct' or nil
    return v_mode, p_mode, plus
end

local function compat_of(copier)   -- the copier is the last joker of the lineup
    T.wait_frames(3)
    local cards = G.jokers.cards
    T.eq(cards[#cards].config.center.key, 'j_' .. copier, 'last joker is the copier')
    return cards[#cards].ability.blueprint_compat
end

local function round_without_errors()
    T.select_blind()
    T.set_hand({ '2S', '2H', '7C', '5D', '3D' })
    if G.GAME.current_round.discards_left > 0 then
        T.discard({ '3D' })
        T.set_hand({ '2S', '2H', '7C', '5D', '3D' })
    end
    T.play({ '2S', '2H' })
    if T.state_name() == 'SELECTING_HAND' then T.win_blind() end   -- a big copied effect may win it already
end

for _, vk in ipairs(sorted_keys()) do
    local pk = BPlus.upgrade_map[vk]
    local short = vk:gsub('^j_', '')

    T.test('Architect sweep: ' .. short .. ' (vanilla and "+" next to it)', function()
        local v_mode, p_mode = expected(vk)
        -- two Architects in one run: the first copies the vanilla joker, the second its "+" version
        T.start_run({ jokers = { 'bplus_blueprint_plus', vk, 'bplus_blueprint_plus', pk }, ante = 3, joker_slots = 6 })
        local cards = G.jokers.cards
        T.eq(BPlus.copy_plus.mode(cards[2]), v_mode, 'mode of vanilla ' .. vk)
        T.eq(BPlus.copy_plus.mode(cards[4]), p_mode, 'mode of ' .. pk)
        T.wait_frames(3)
        T.eq(cards[1].ability.blueprint_compat, v_mode and 'compatible' or 'incompatible', 'compat UI, vanilla target')
        T.eq(cards[3].ability.blueprint_compat, p_mode and 'compatible' or 'incompatible', 'compat UI, "+" target')
        round_without_errors()
    end)

    T.test('Hive Mind sweep: ' .. short .. ' (vanilla and "+" leftmost)', function()
        local v_mode, p_mode = expected(vk)
        T.start_run({ jokers = { vk, 'bplus_brainstorm_plus' }, ante = 3 })
        T.eq(compat_of('bplus_brainstorm_plus'), v_mode and 'compatible' or 'incompatible', 'compat UI, vanilla target')
        round_without_errors()
        T.start_run({ jokers = { pk, 'bplus_brainstorm_plus' }, ante = 3 })
        T.eq(compat_of('bplus_brainstorm_plus'), p_mode and 'compatible' or 'incompatible', 'compat UI, "+" target')
    end)
end
