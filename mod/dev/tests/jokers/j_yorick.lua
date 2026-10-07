local T = BPlus.test

-- discards `n` cards, at most 5 per discard
local function discard_cards(n)
    while n > 0 do
        local k = math.min(5, n)
        local idx = {}
        for i = 1, k do idx[i] = i end
        T.discard(idx)
        n = n - k
    end
end

T.test('Yorick+: discard 14 cards -> X2; 28 cards -> X3 (vanilla needs 23 per step)', function()
    T.start_run({ jokers = { 'bplus_yorick_plus' }, discards = 8, ante = 3 })
    T.select_blind()
    discard_cards(14)
    T.eq(T.joker(1).ability.extra.Xmult, 1 + 1)
    discard_cards(14)
    T.eq(T.joker(1).ability.extra.Xmult, 1 + 1 + 1)
    T.set_hand({ '2S', '3H', '7C', '5D', '9D' })
    local r = T.play({ '9D' })
    T.eq(r.mult, 1 * 3)
end)

T.test('Yorick+: Yorick at X2 with 17 of 23 remaining, upgrade -> Yorick+ keeps X2; counter fits 14 (3 more discards -> X3)', function()
    T.start_run({ jokers = { { key = 'yorick', edition = 'holo' } }, discards = 12, ante = 3 })
    T.select_blind()
    discard_cards(23)
    T.eq(T.joker(1).ability.x_mult, 1 + 1)
    T.eq(T.joker(1).ability.yorick_discards, 23)
    discard_cards(6)
    T.eq(T.joker(1).ability.yorick_discards, 17)
    local card = T.upgrade('yorick')
    T.eq(card.ability.extra.Xmult, 2)
    T.eq(card.ability.extra.discards_left, 17)
    T.truthy(card.edition and card.edition.holo, 'holo kept')
    discard_cards(1)
    T.eq(card.ability.extra.discards_left, ((17 - 1) % 14) + 1 - 1)
    discard_cards(1)
    T.eq(card.ability.extra.Xmult, 2)
    discard_cards(1)
    T.eq(card.ability.extra.Xmult, 2 + 1)
    T.eq(card.ability.extra.discards_left, 14)
end)

T.test('Yorick+: vanilla Yorick forced to "+" counts in 14s (counter fitted to 14)', function()
    T.start_run({ jokers = { 'yorick' }, discards = 8, ante = 3 })
    T.select_blind()
    T.force_behavior('yorick', 'plus')
    -- 23 -> ((23 - 1) % 14) + 1 = 9 remaining: the 9th card gives the gain
    discard_cards(8)
    T.eq(T.joker(1).ability.x_mult, 1)
    discard_cards(1)
    T.eq(T.joker(1).ability.x_mult, 1 + 1)
end)

T.test('Yorick+: Yorick+ forced to base counts down its kept counter and keeps its value', function()
    T.start_run({ jokers = { 'bplus_yorick_plus' }, discards = 10, ante = 3 })
    T.select_blind()
    discard_cards(14)
    T.eq(T.joker(1).ability.extra.Xmult, 2)
    T.force_behavior(1, 'base')
    -- the counter (14 after the gain) is kept; vanilla counts it down, then restarts at 23
    discard_cards(13)
    T.eq(T.joker(1).ability.extra.Xmult, 2)
    discard_cards(1)
    T.eq(T.joker(1).ability.extra.Xmult, 2 + 1)
end)
