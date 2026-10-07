local T = BPlus.test

T.test('Astronaut: with Oops! All 6s (2 in 2), play a Pair -> Pair levels up every time', function()
    T.start_run({ ante = 3, jokers = { 'bplus_space_plus', 'oops' } })
    T.select_blind()
    T.eq(G.GAME.hands['Pair'].level, 1)
    T.set_hand({ 'KS', 'KH' })
    T.play({ 'KS', 'KH' })
    T.eq(G.GAME.hands['Pair'].level, 1 + 1)
    T.set_hand({ 'QS', 'QH' })
    T.play({ 'QS', 'QH' })
    T.eq(G.GAME.hands['Pair'].level, 1 + 1 + 1)
end)

T.test('Astronaut: seeded run, 20 hands -> some level-ups and some misses', function()
    T.start_run({ ante = 8, hands = 20, jokers = { 'bplus_space_plus' } })
    T.select_blind()
    local ups = 0
    for _ = 1, 20 do
        local before = G.GAME.hands['High Card'].level
        T.set_hand({ '2S', '4H', '6D', '8C', '9S' })
        T.play({ '9S' })
        if G.GAME.hands['High Card'].level > before then ups = ups + 1 end
        if T.state_name() ~= 'SELECTING_HAND' then break end
    end
    T.truthy(ups >= 1, 'some level-ups')
    T.truthy(ups <= 19, 'some misses')
end)

T.test('Astronaut: description shows 1 in 2 (vanilla: 1 in 4)', function()
    T.start_run({ jokers = { 'bplus_space_plus' } })
    local num, den = SMODS.get_probability_vars(T.joker('bplus_space_plus'), 1, 2, 'bplus_astronaut')
    T.eq({ num, den }, { 1, 2 })
    local vars = G.P_CENTERS.j_bplus_space_plus:loc_vars({}, T.joker('bplus_space_plus')).vars
    T.eq(vars, { 1, 2 })
end)

T.test('Astronaut: vanilla Space Joker forced to "+" with Oops! levels Pair', function()
    T.start_run({ ante = 3, jokers = { 'space', 'oops' } })
    T.force_behavior('space', 'plus')
    T.select_blind()
    T.set_hand({ 'KS', 'KH' })
    T.play({ 'KS', 'KH' })
    T.eq(G.GAME.hands['Pair'].level, 1 + 1)
end)
