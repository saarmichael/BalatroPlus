local T = BPlus.test

local function counts()
    local t, s = 0, 0
    for _, c in ipairs(G.consumeables.cards) do
        if c.ability.set == 'Tarot' then t = t + 1 elseif c.ability.set == 'Spectral' then s = s + 1 end
    end
    return t, s
end

T.test('Magic 8 Ball: with Oops! All 6s (2 in 4 each), every scored 8 creates exactly one card', function()
    T.start_run({ ante = 3, consumable_slots = 5, jokers = { 'bplus_8_ball_plus', 'oops' } })
    T.select_blind()
    T.set_hand({ '8S', '8H', '8D', '8C', '2S' })
    T.play({ '8S', '8H', '8D', '8C' })
    local t, s = counts()
    T.eq(t + s, 4)
end)

T.test('Magic 8 Ball: seeded run, many 8s -> Tarots and Spectrals both appear, never two cards from one 8', function()
    local tarots, spectrals, eights = 0, 0, 0
    T.start_run({ ante = 8, hands = 12, consumable_slots = 100, jokers = { 'bplus_8_ball_plus', 'oops' } })
    T.select_blind()
    for _ = 1, 12 do
        T.set_hand({ '8S', '8H', '8D', '8C', '2S' })
        T.play({ '8S', '8H', '8D', '8C' })
        eights = eights + 4
        if T.state_name() ~= 'SELECTING_HAND' then break end
    end
    tarots, spectrals = counts()
    T.truthy(tarots > 0, 'tarots')
    T.truthy(spectrals > 0, 'spectrals')
    T.eq(tarots + spectrals, eights)
end)

T.test('Magic 8 Ball: consumable slots full -> nothing created', function()
    T.start_run({ ante = 3, consumables = { 'pluto', 'mercury' }, jokers = { 'bplus_8_ball_plus', 'oops' } })
    T.select_blind()
    T.set_hand({ '8S', '8H', '8D', '8C', '2S' })
    T.play({ '8S', '8H', '8D', '8C' })
    T.eq(#G.consumeables.cards, 2)
    T.eq(G.consumeables.cards[1].ability.set, 'Planet')
end)

T.test('Magic 8 Ball: description shows 1 in 4 (with Oops!: 2 in 4)', function()
    T.start_run({ jokers = { 'bplus_8_ball_plus' } })
    local j = T.joker('bplus_8_ball_plus')
    T.eq(j.config.center:loc_vars({}, j).vars, { 1, 4 })
    T.start_run({ jokers = { 'bplus_8_ball_plus', 'oops' } })
    j = T.joker('bplus_8_ball_plus')
    T.eq(j.config.center:loc_vars({}, j).vars, { 2, 4 })
end)

T.test('Magic 8 Ball: vanilla 8 Ball forced to "+" with Oops! -> one card per 8', function()
    T.start_run({ ante = 3, consumable_slots = 5, jokers = { '8_ball', 'oops' } })
    T.force_behavior('8_ball', 'plus')
    T.select_blind()
    T.set_hand({ '8S', '8H', '8D', '8C', '2S' })
    T.play({ '8S', '8H', '8D', '8C' })
    local t, s = counts()
    T.eq(t + s, 4)
end)

T.test('Magic 8 Ball JokerDisplay: +0 (1 in 4) and odds follow behaviour', function()
    T.start_run({ dollars = 6, jokers = { 'bplus_8_ball_plus', '8_ball' } })
    local d = T.joker_display('bplus_8_ball_plus')
    T.eq(d.text, '+0')
    T.eq(d.extra[1], '(1 in 4)')
    T.force_behavior('8_ball', 'plus')
    T.eq(T.joker_display('8_ball').extra[1], '(1 in 4)')
    T.force_behavior('bplus_8_ball_plus', 'base')
    T.eq(T.joker_display('bplus_8_ball_plus').extra[1], '(1 in 4)')
end)
