-- Vanilla joker behaviour. Pins down the base game's numbers (our upgrades are measured against
-- them) and serves as the template for joker tests.
local T = BPlus.test

T.test('Joker: +4 Mult', function()
    T.start_run({ jokers = { 'joker' } })
    T.select_blind()
    T.set_hand({ 'KS', 'KH', 'JH', 'JC', '2D' })
    local r = T.play({ 'KS', 'KH', 'JH', 'JC' })
    T.eq(r.chips, 60)
    T.eq(r.mult, 2 + 4)
    T.eq(r.score, 360)
end)

T.test('Greedy Joker: +3 Mult per scored Diamond', function()
    T.start_run({ jokers = { 'greedy_joker' } })
    T.select_blind()
    T.set_hand({ 'AD', 'KD', '9D', '5D', '2D' })
    local r = T.play({ 'AD', 'KD', '9D', '5D', '2D' })
    T.eq(r.hand, 'Flush')
    T.eq(r.chips, 35 + 11 + 10 + 9 + 5 + 2)
    T.eq(r.mult, 4 + 3 * 5)
end)

T.test('Scary Face: +30 Chips per scored face card', function()
    T.start_run({ jokers = { 'scary_face' } })
    T.select_blind()
    T.set_hand({ 'KS', 'KH', '7C', '4D', '2D' })
    local r = T.play({ 'KS', 'KH' })
    T.eq(r.hand, 'Pair')
    T.eq(r.chips, 10 + 10 + 10 + 30 * 2)
    T.eq(r.mult, 2)
end)

T.test('Blueprint copies the joker to its right', function()
    T.start_run({ jokers = { 'blueprint', 'joker' } })
    T.select_blind()
    T.set_hand({ 'KS', 'KH', 'JH', 'JC', '2D' })
    local r = T.play({ 'KS', 'KH', 'JH', 'JC' })
    T.eq(r.mult, 2 + 4 + 4)
end)

T.test('Golden Joker: +$4 at end of round', function()
    -- With $0 there is no interest: blind reward $3 + $1 per unused hand (4) + Golden Joker $4
    T.start_run({ dollars = 0, jokers = { 'golden' } })
    T.select_blind()
    T.win_blind()
    T.eq(T.cash_out(), 3 + 4 + 4)
end)
