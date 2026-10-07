local T = BPlus.test

local function sets()
    local t = {}
    for _, c in ipairs(G.consumeables.cards) do t[#t + 1] = c.ability.set end
    return t
end

T.test('Superduperposition: A-2-3-4-5 Straight with 2 free slots -> 2 Tarots (vanilla: 1)', function()
    T.start_run({ ante = 3, jokers = { 'bplus_superposition_plus' } })
    T.select_blind()
    T.set_hand({ 'AS', '2H', '3D', '4C', '5S' })
    local r = T.play({ 'AS', '2H', '3D', '4C', '5S' })
    T.eq(r.hand, 'Straight')
    T.eq(sets(), { 'Tarot', 'Tarot' })
end)

T.test('Superduperposition: Straight without an Ace -> nothing', function()
    T.start_run({ ante = 3, jokers = { 'bplus_superposition_plus' } })
    T.select_blind()
    T.set_hand({ '9S', '8H', '7D', '6C', '5S' })
    local r = T.play({ '9S', '8H', '7D', '6C', '5S' })
    T.eq(r.hand, 'Straight')
    T.eq(#G.consumeables.cards, 0)
end)

T.test('Superduperposition: only 1 free slot -> 1 Tarot', function()
    T.start_run({ ante = 3, consumables = { 'pluto' }, jokers = { 'bplus_superposition_plus' } })
    T.select_blind()
    T.set_hand({ 'AS', '2H', '3D', '4C', '5S' })
    T.play({ 'AS', '2H', '3D', '4C', '5S' })
    T.eq(sets(), { 'Planet', 'Tarot' })
end)

T.test('Superduperposition: vanilla Superposition forced to "+" -> 2 Tarots', function()
    T.start_run({ ante = 3, jokers = { 'superposition' } })
    T.force_behavior('superposition', 'plus')
    T.select_blind()
    T.set_hand({ 'AS', '2H', '3D', '4C', '5S' })
    T.play({ 'AS', '2H', '3D', '4C', '5S' })
    T.eq(sets(), { 'Tarot', 'Tarot' })
end)
