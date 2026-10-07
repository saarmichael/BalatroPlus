local T = BPlus.test

local function hand_size() return G.hand.config.card_limit end

T.test('Knife Juggler: hand size 8 + 2 = 10 (vanilla: 8 + 1)', function()
    T.start_run({ jokers = { 'bplus_juggler_plus' } })
    T.eq(hand_size(), 8 + 2)
end)

T.test('Knife Juggler: sell it -> hand size back to 8', function()
    T.start_run({ jokers = { 'bplus_juggler_plus' } })
    T.sell('bplus_juggler_plus')
    T.eq(hand_size(), 8)
end)

T.test('Knife Juggler: upgrade Juggler -> hand size goes from 9 to 10', function()
    T.start_run({ jokers = { 'juggler' } })
    T.eq(hand_size(), 8 + 1)
    T.upgrade('juggler')
    T.eq(hand_size(), 8 + 2)
end)

T.test('Knife Juggler: Juggler forced to "+" -> 10, back -> 9; sold while "+" -> 8', function()
    T.start_run({ jokers = { 'juggler' } })
    T.force_behavior('juggler', 'plus')
    T.eq(hand_size(), 8 + 2)
    T.force_behavior('juggler', nil)
    T.eq(hand_size(), 8 + 1)
    T.force_behavior('juggler', 'plus')
    T.sell('juggler')
    T.eq(hand_size(), 8)
end)

T.test('Knife Juggler: forced to base -> 9', function()
    T.start_run({ jokers = { 'bplus_juggler_plus' } })
    T.force_behavior(1, 'base')
    T.eq(hand_size(), 8 + 1)
end)
