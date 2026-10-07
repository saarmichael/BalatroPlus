local T = BPlus.test

local function stones()
    local n = 0
    for _, c in ipairs(G.playing_cards) do
        if c.config.center == G.P_CENTERS.m_stone then n = n + 1 end
    end
    return n
end

T.test('Medusa: select Blind -> no Stone card added (unlike Marble Joker)', function()
    T.start_run({ jokers = { 'bplus_marble_plus' } })
    T.select_blind()
    T.eq(#G.playing_cards, 52)
    T.eq(stones(), 0)
end)

T.test('Marble Joker (vanilla): select Blind adds a Stone card', function()
    T.start_run({ jokers = { 'marble' } })
    T.select_blind()
    T.eq(#G.playing_cards, 52 + 1)
    T.eq(stones(), 1)
end)

T.test('Medusa: first hand is a single 7 -> it becomes a Stone card and scores as one', function()
    T.start_run({ jokers = { 'bplus_marble_plus' }, ante = 3 })
    T.select_blind()
    T.set_hand({ '7S', '9H', '2C' })
    local r = T.play({ '7S' })
    T.eq(r.chips, 5 + 50)
    T.eq(r.mult, 1)
    T.eq(stones(), 1)
end)

T.test('Medusa: first hand has 2 cards -> nothing turns to Stone', function()
    T.start_run({ jokers = { 'bplus_marble_plus' }, ante = 3 })
    T.select_blind()
    T.set_hand({ '7S', '7H', '2C' })
    local r = T.play({ '7S', '7H' })
    T.eq(r.chips, 10 + 7 + 7)
    T.eq(stones(), 0)
end)

T.test('Medusa: second hand of the round is a single card -> nothing turns to Stone', function()
    T.start_run({ jokers = { 'bplus_marble_plus' }, ante = 3 })
    T.select_blind()
    T.set_hand({ '7S', '7H', '2C', '3C' })
    T.play({ '7S', '7H' })
    T.set_hand({ '9S', '9H', '2C' })
    local r = T.play({ '9S' })
    T.eq(r.chips, 5 + 9)
    T.eq(stones(), 0)
end)

T.test('Medusa: Medusa left of DNA, first hand a single 7 -> played card and its copy are both Stone', function()
    T.start_run({ jokers = { 'bplus_marble_plus', 'dna' }, ante = 3 })
    T.select_blind()
    T.set_hand({ '7S', '9H', '2C' })
    T.play({ '7S' })
    T.eq(#G.playing_cards, 52 + 1)
    T.eq(stones(), 2)
end)

T.test('Medusa: DNA left of Medusa, first hand a single 7 -> copy is a normal 7, played card is Stone', function()
    T.start_run({ jokers = { 'dna', 'bplus_marble_plus' }, ante = 3 })
    T.select_blind()
    T.set_hand({ '7S', '9H', '2C' })
    T.play({ '7S' })
    T.eq(#G.playing_cards, 52 + 1)
    T.eq(stones(), 1)
end)

T.test('Medusa: Marble Joker forced to "+" -> no Stone on blind select, single 7 becomes Stone', function()
    T.start_run({ jokers = { 'marble' }, ante = 3 })
    T.force_behavior('marble', 'plus')
    T.select_blind()
    T.eq(stones(), 0)
    T.set_hand({ '7S', '9H', '2C' })
    local r = T.play({ '7S' })
    T.eq(r.chips, 5 + 50)
    T.eq(stones(), 1)
end)
