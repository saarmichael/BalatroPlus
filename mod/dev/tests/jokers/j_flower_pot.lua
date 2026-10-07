local T = BPlus.test

local function start(joker)
    T.start_run({ jokers = { joker }, ante = 3 })
    T.select_blind()
end

-- Straight-free, flush-free 5 card hand where all cards score: use a Pair? Only pair cards score.
-- So we play High Card / Pair hands where the scoring cards carry the suits.
-- Three of a kind with 3 different suits: scoring hand is the 3 cards.
local function play_trips(a, b, c)
    T.set_hand({ a, b, c, '2C', '3C' })
    return T.play({ 1, 2, 3 })
end

T.test('Flower Garden: scoring hand with Hearts, Diamonds, Spades -> X3', function()
    start('bplus_flower_pot_plus')
    local r = play_trips('KH', 'KD', 'KS')
    T.eq(r.hand, 'Three of a Kind')
    T.eq(r.mult, 3 * 3)
end)

T.test('Flower Garden: scoring hand with only 2 suits -> no trigger', function()
    start('bplus_flower_pot_plus')
    local r = play_trips('KH', 'KD', 'KD')
    T.eq(r.mult, 3)
end)

T.test('Flower Garden: 2 suits + 1 Wild card -> X3', function()
    start('bplus_flower_pot_plus')
    local r = play_trips('KH', 'KD', { 'KS', enhancement = 'wild' })
    T.eq(r.mult, 3 * 3)
end)

T.test('Flower Garden: vanilla Flower Pot needs all 4 suits (X3), not 3', function()
    start('flower_pot')
    T.eq(play_trips('KH', 'KD', 'KS').mult, 3)
end)

T.test('Flower Garden: vanilla forced to "+" triggers with 3 suits', function()
    start('flower_pot')
    T.force_behavior('flower_pot', 'plus')
    T.eq(play_trips('KH', 'KD', 'KS').mult, 3 * 3)
end)
