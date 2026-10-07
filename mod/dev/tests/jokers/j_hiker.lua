local T = BPlus.test

-- The 5 of Spades in hand. T.set_hand builds fresh cards, so a card that already scored once is
-- simulated by giving the fresh one the permanent bonus a first score would have left on it.
local function five_in_hand(perma)
    local c
    for _, card in ipairs(G.hand.cards) do
        if card.base.value == '5' and card.base.suit == 'Spades' then c = card end
    end
    c.ability.perma_bonus = perma
    return c
end

T.test('Jogger: score a 5 twice in two hands -> first 5 + 5 chips, second 5 + 5 + 10, then +20 permanent chips', function()
    T.start_run({ jokers = { 'bplus_hiker_plus' }, hands = 3, ante = 3 })
    T.select_blind()
    T.set_hand({ '5S', '9H', '2C' })
    local c1 = five_in_hand(0)
    local r1 = T.play({ '5S' })
    T.eq(r1.chips, 5 + 5)
    T.eq(c1.ability.perma_bonus, 10)
    T.set_hand({ '5S', '9H', '2C' })
    local c2 = five_in_hand(c1.ability.perma_bonus)
    local r2 = T.play({ '5S' })
    T.eq(r2.chips, 5 + 5 + 10)
    T.eq(c2.ability.perma_bonus, 10 + 10)
end)

T.test('Hiker (vanilla): +5 per score', function()
    T.start_run({ jokers = { 'hiker' }, hands = 3, ante = 3 })
    T.select_blind()
    T.set_hand({ '5S', '9H', '2C' })
    local c1 = five_in_hand(0)
    local r1 = T.play({ '5S' })
    T.eq(r1.chips, 5 + 5)
    T.eq(c1.ability.perma_bonus, 5)
    T.set_hand({ '5S', '9H', '2C' })
    local c2 = five_in_hand(c1.ability.perma_bonus)
    local r2 = T.play({ '5S' })
    T.eq(r2.chips, 5 + 5 + 5)
    T.eq(c2.ability.perma_bonus, 5 + 5)
end)

T.test('Jogger: Hiker forced to "+" -> +10 per score; Jogger forced to base -> +5', function()
    T.start_run({ jokers = { 'hiker', 'bplus_hiker_plus' }, hands = 3, ante = 3 })
    T.select_blind()
    T.force_behavior(1, 'plus')
    T.force_behavior(2, 'base')
    T.set_hand({ '5S', '9H', '2C' })
    local c = five_in_hand(0)
    T.play({ '5S' })
    T.eq(c.ability.perma_bonus, 10 + 5)
end)

T.test('Jogger JokerDisplay: shows nothing, like vanilla (also forced to base / plus)', function()
    T.start_run({ jokers = { 'bplus_hiker_plus', 'hiker' } })
    T.eq(T.joker_display('bplus_hiker_plus').text, '')
    T.force_behavior('hiker', 'plus')
    T.eq(T.joker_display('hiker').text, '')
    T.force_behavior('bplus_hiker_plus', 'base')
    T.eq(T.joker_display('bplus_hiker_plus').text, '')
end)
