local T = BPlus.test

local function pair(a, b)
    T.set_hand({ a, b, '2D', '3D', '5D' })
    return T.play({ 1, 2 })
end

T.test('Chameleon: scoring Pair Club + Heart -> X3 (vanilla: X2)', function()
    T.start_run({ jokers = { 'bplus_seeing_double_plus' }, ante = 3 })
    T.select_blind()
    T.eq(pair('KC', 'KH').mult, 2 * 3)
    T.start_run({ jokers = { 'seeing_double' }, ante = 3 })
    T.select_blind()
    T.eq(pair('KC', 'KH').mult, 2 * 2)
end)

T.test('Chameleon: scoring Pair of two Clubs -> no trigger', function()
    T.start_run({ jokers = { 'bplus_seeing_double_plus' }, ante = 3 })
    T.select_blind()
    T.eq(pair('KC', 'KC').mult, 2)
end)

T.test('Chameleon: vanilla forced to "+" gives X3', function()
    T.start_run({ jokers = { 'seeing_double' }, ante = 3 })
    T.select_blind()
    T.force_behavior('seeing_double', 'plus')
    T.eq(pair('KC', 'KH').mult, 2 * 3)
end)
