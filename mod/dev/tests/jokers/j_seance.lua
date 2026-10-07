local T = BPlus.test

local function sets()
    local t = {}
    for _, c in ipairs(G.consumeables.cards) do t[#t + 1] = c.ability.set end
    return t
end

T.test('Spirit Board: Straight Flush with 2 free slots -> 2 Spectral cards (vanilla: 1)', function()
    T.start_run({ ante = 3, jokers = { 'bplus_seance_plus' } })
    T.select_blind()
    T.set_hand({ '9S', '8S', '7S', '6S', '5S' })
    local r = T.play({ '9S', '8S', '7S', '6S', '5S' })
    T.eq(r.hand, 'Straight Flush')
    T.eq(sets(), { 'Spectral', 'Spectral' })
end)

T.test('Spirit Board: Flush -> nothing', function()
    T.start_run({ ante = 3, jokers = { 'bplus_seance_plus' } })
    T.select_blind()
    T.set_hand({ 'AS', 'KS', '9S', '5S', '2S' })
    local r = T.play({ 'AS', 'KS', '9S', '5S', '2S' })
    T.eq(r.hand, 'Flush')
    T.eq(#G.consumeables.cards, 0)
end)

T.test('Spirit Board: vanilla Seance forced to "+" -> 2 Spectral cards', function()
    T.start_run({ ante = 3, jokers = { 'seance' } })
    T.force_behavior('seance', 'plus')
    T.select_blind()
    T.set_hand({ '9S', '8S', '7S', '6S', '5S' })
    T.play({ '9S', '8S', '7S', '6S', '5S' })
    T.eq(sets(), { 'Spectral', 'Spectral' })
end)
