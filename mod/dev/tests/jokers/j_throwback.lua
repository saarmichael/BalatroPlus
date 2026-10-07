local T = BPlus.test

local function near(a, e, what) T.near(a, e, 1e-6, what) end

local function boss_hit(skips)
    for _ = 1, skips do T.skip_blind() end
    T.select_blind()
    T.set_hand({ '2S', '3H', '4C', '5D', '7D' })
    return T.play({ '2S' })
end

T.test('Nostalgic Joker: skipped 2 Blinds this run -> X(1 + 1 * 2) = X3 (vanilla: X1.5)', function()
    T.start_run({ jokers = { 'bplus_throwback_plus' }, boss = 'club' })
    near(boss_hit(2).mult, 1 * (1 + 1 * 2))
end)

T.test('Nostalgic Joker: no skips -> no effect', function()
    T.start_run({ jokers = { 'bplus_throwback_plus' }, boss = 'club' })
    near(boss_hit(0).mult, 1)
end)

T.test('Nostalgic Joker: Throwback forced to "+" scores X(1 + 1 * 2) = X3', function()
    T.start_run({ jokers = { 'throwback' }, boss = 'club' })
    T.force_behavior('throwback', 'plus')
    near(boss_hit(2).mult, 1 * (1 + 1 * 2))
end)

T.test('Nostalgic Joker: forced to base scores the vanilla X(1 + 0.25 * 2) = X1.5', function()
    T.start_run({ jokers = { 'bplus_throwback_plus' }, boss = 'club' })
    T.force_behavior(1, 'base')
    near(boss_hit(2).mult, 1 * (1 + 0.25 * 2))
end)

T.test('Nostalgic Joker JokerDisplay: 2 skips -> X3; vanilla forced to "+" shows X3; "+" forced to base shows X1.5', function()
    T.start_run({ jokers = { 'bplus_throwback_plus', 'throwback' } })
    T.skip_blind()
    T.skip_blind()
    T.eq(T.joker_display('bplus_throwback_plus').text, 'X3')
    T.eq(T.joker_display('throwback').text, 'X1.5')
    T.force_behavior('throwback', 'plus')
    T.eq(T.joker_display('throwback').text, 'X3')
    T.force_behavior('bplus_throwback_plus', 'base')
    T.eq(T.joker_display('bplus_throwback_plus').text, 'X1.5')
end)
