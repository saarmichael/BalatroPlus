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

local function highlight(...)
    for _, c in ipairs(T.hand_cards({ ... })) do G.hand:add_to_highlighted(c, true) end
end

T.test('Flower Garden JokerDisplay: "+" shows X3(3 Suits); vanilla forced to "+" matches; "+" forced to base shows vanilla X1', function()
    T.start_run({ jokers = { 'bplus_flower_pot_plus', 'flower_pot' }, ante = 3 })
    T.select_blind()
    T.set_hand({ 'KH', 'KD', 'KS', '2C', '3C' })
    highlight(1, 2, 3)
    local d = T.joker_display('bplus_flower_pot_plus')
    T.eq(d.text, 'X3')
    T.eq(d.reminder, '(3 Suits)')
    local v = T.joker_display('flower_pot')
    T.eq(v.text, 'X1')
    T.eq(v.reminder, '(All Suits)')
    T.force_behavior('flower_pot', 'plus')
    v = T.joker_display('flower_pot')
    T.eq(v.text, 'X3')
    T.eq(v.reminder, '(3 Suits)')
    T.force_behavior('bplus_flower_pot_plus', 'base')
    d = T.joker_display('bplus_flower_pot_plus')
    T.eq(d.text, 'X1')
    T.eq(d.reminder, '(All Suits)')
    G.hand:unhighlight_all()
end)
