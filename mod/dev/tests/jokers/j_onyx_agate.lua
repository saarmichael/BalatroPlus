local T = BPlus.test

local function pair()
    T.set_hand({ 'KC', 'KC', '2H', '3H', '5H' })
    return T.play({ 1, 2 })
end

T.test('Obsidian: Pair of Clubs -> +15 + 15 Mult (vanilla: +7 + 7)', function()
    T.start_run({ jokers = { 'bplus_onyx_agate_plus' }, ante = 3 })
    T.select_blind()
    T.eq(pair().mult, 2 + 15 + 15)
end)

T.test('Obsidian: vanilla Onyx Agate gives +7 + 7 Mult', function()
    T.start_run({ jokers = { 'onyx_agate' }, ante = 3 })
    T.select_blind()
    T.eq(pair().mult, 2 + 7 + 7)
end)

T.test('Obsidian: vanilla forced to "+" gives +15 + 15 Mult', function()
    T.start_run({ jokers = { 'onyx_agate' }, ante = 3 })
    T.select_blind()
    T.force_behavior('onyx_agate', 'plus')
    T.eq(pair().mult, 2 + 15 + 15)
end)
