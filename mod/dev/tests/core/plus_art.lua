-- "+" joker art (D19): vanilla sprite by default, overlay predicate follows behaviour.
local T = BPlus.test

T.test('art: "+" joker uses its vanilla joker sprite', function()
    for _, pair in ipairs({ { 'j_joker', 'j_bplus_joker_plus' }, { 'j_wee', 'j_bplus_wee_plus' }, { 'j_half', 'j_bplus_half_plus' } }) do
        local v, p = G.P_CENTERS[pair[1]], G.P_CENTERS[pair[2]]
        T.eq(p.atlas, v.atlas or 'Joker', pair[2] .. ' atlas')
        T.eq(p.pos.x, v.pos.x, pair[2] .. ' pos.x')
        T.eq(p.pos.y, v.pos.y, pair[2] .. ' pos.y')
    end
end)

T.test('art: legendary "+" joker has its soul_pos', function()
    local v, p = G.P_CENTERS.j_caino, G.P_CENTERS.j_bplus_caino_plus
    T.truthy(p.soul_pos, 'soul_pos')
    T.eq(p.soul_pos.x, v.soul_pos.x)
    T.eq(p.soul_pos.y, v.soul_pos.y)
end)

T.test('art: Wee Joker+ is small like Wee Joker', function()
    local p = G.P_CENTERS.j_bplus_wee_plus
    T.eq(p.display_size.w, 71 * 0.7)
    T.eq(p.display_size.h, 95 * 0.7)
end)

T.test('art: overlay shows for "+" jokers, not vanilla; follows behaviour', function()
    T.start_run({ jokers = { 'joker', 'bplus_joker_plus', 'greedy_joker', 'bplus_greedy_joker_plus' } })
    local v, p = T.joker('joker'), T.joker('bplus_joker_plus')
    T.truthy(BPlus.show_plus_overlay(p), '+ joker')
    T.falsy(BPlus.show_plus_overlay(v), 'vanilla')
    T.force_behavior('joker', 'plus')
    T.truthy(BPlus.show_plus_overlay(v), 'vanilla forced to plus')
    T.force_behavior('bplus_joker_plus', 'base')
    T.falsy(BPlus.show_plus_overlay(p), '+ forced to base')
end)

T.test('art: overlay works for cards outside G.jokers (shop / collection)', function()
    local c = Card(0, 0, G.CARD_W, G.CARD_H, nil, G.P_CENTERS.j_bplus_joker_plus)
    T.truthy(BPlus.show_plus_overlay(c))
    local d = Card(0, 0, G.CARD_W, G.CARD_H, nil, G.P_CENTERS.j_joker)
    T.falsy(BPlus.show_plus_overlay(d))
    c:remove(); d:remove()
end)
