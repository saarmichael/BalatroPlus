local T = BPlus.test

local function is_gold(c) return c.config.center == G.P_CENTERS.m_gold end

T.test('Midas Touch: play a scoring Pair of 7s -> both become Gold', function()
    T.start_run({ jokers = { 'bplus_midas_mask_plus' }, ante = 3 })
    T.select_blind()
    T.set_hand({ '7S', '7H', '2C', '3D' })
    T.play({ '7S', '7H' })
    local golds = 0
    for _, c in ipairs(G.playing_cards) do if is_gold(c) then golds = golds + 1 end end
    T.eq(golds, 2)
end)

T.test('Midas Touch: Pair of 7s with a kicker -> kicker (not scored) stays as it is', function()
    T.start_run({ jokers = { 'bplus_midas_mask_plus' }, ante = 3 })
    T.select_blind()
    T.set_hand({ '7S', '7H', 'KC', '3D' })
    T.play({ '7S', '7H', 'KC' })
    local golds, kicker_gold = 0, false
    for _, c in ipairs(G.playing_cards) do
        if is_gold(c) then
            golds = golds + 1
            if c.base.value == 'King' then kicker_gold = true end
        end
    end
    T.eq(golds, 2)
    T.falsy(kicker_gold, 'kicker stays plain')
end)

T.test('Midas Touch: scoring Glass King -> becomes Gold', function()
    T.start_run({ jokers = { 'bplus_midas_mask_plus' }, ante = 3 })
    T.select_blind()
    T.set_hand({ { 'KH', enhancement = 'glass' }, '3D' })
    local r = T.play({ 'KH' })
    T.eq(r.mult, 1, 'scored as Gold, not Glass (no X2)')
    local gold_king = false
    for _, c in ipairs(G.playing_cards) do
        if c.base.value == 'King' and c.base.suit == 'Hearts' and is_gold(c) then gold_king = true end
    end
    T.truthy(gold_king)
end)

T.test('Midas Mask (vanilla): non-face cards are not changed', function()
    T.start_run({ jokers = { 'midas_mask' }, ante = 3 })
    T.select_blind()
    T.set_hand({ '7S', '7H', '2C', '3D' })
    T.play({ '7S', '7H' })
    for _, c in ipairs(G.playing_cards) do T.falsy(is_gold(c)) end
end)

T.test('Midas Touch: Midas Mask forced to "+" -> a scoring 7 becomes Gold', function()
    T.start_run({ jokers = { 'midas_mask' }, ante = 3 })
    T.force_behavior('midas_mask', 'plus')
    T.select_blind()
    T.set_hand({ '7S', '2C' })
    T.play({ '7S' })
    local golds = 0
    for _, c in ipairs(G.playing_cards) do if is_gold(c) then golds = golds + 1 end end
    T.eq(golds, 1)
end)

T.test('Midas Touch JokerDisplay: shows nothing, like vanilla (also forced to base / plus)', function()
    T.start_run({ jokers = { 'bplus_midas_mask_plus', 'midas_mask' } })
    T.eq(T.joker_display('bplus_midas_mask_plus').text, '')
    T.force_behavior('midas_mask', 'plus')
    T.eq(T.joker_display('midas_mask').text, '')
    T.force_behavior('bplus_midas_mask_plus', 'base')
    T.eq(T.joker_display('bplus_midas_mask_plus').text, '')
end)
