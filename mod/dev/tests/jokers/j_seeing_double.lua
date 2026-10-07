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

local function highlight(...)
    for _, c in ipairs(T.hand_cards({ ... })) do G.hand:add_to_highlighted(c, true) end
end

T.test('Chameleon JokerDisplay: "+" shows X3(Club+Other); vanilla forced to "+" matches; "+" forced to base shows vanilla X2', function()
    T.start_run({ jokers = { 'bplus_seeing_double_plus', 'seeing_double' }, ante = 3 })
    T.select_blind()
    T.set_hand({ 'KC', 'KD', '2H', '3H', '5H' })
    highlight(1, 2)
    local d = T.joker_display('bplus_seeing_double_plus')
    T.eq(d.text, 'X3')
    T.eq(d.reminder, '(Club+Other)')
    local v = T.joker_display('seeing_double')
    T.eq(v.text, 'X2')
    T.eq(v.reminder, '(Club+Other)')
    T.force_behavior('seeing_double', 'plus')
    v = T.joker_display('seeing_double')
    T.eq(v.text, 'X3')
    T.eq(v.reminder, '(Club+Other)')
    T.force_behavior('bplus_seeing_double_plus', 'base')
    d = T.joker_display('bplus_seeing_double_plus')
    T.eq(d.text, 'X2')
    T.eq(d.reminder, '(Club+Other)')
    G.hand:unhighlight_all()
end)
