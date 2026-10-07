local T = BPlus.test

-- High Card on a single card: base mult 1, so the mult shown is exactly the joker's X.
local function play_one()
    T.set_hand({ '2S', '3H', '5D', '7C', '9S' })
    return T.play({ '2S' })
end

T.test('Joker Mold: 5 slots, Mold alone -> X1.5 * (4 + 1) = X7.5 (vanilla Stencil: X5)', function()
    T.start_run({ jokers = { 'bplus_stencil_plus' }, ante = 3 })
    T.select_blind()
    T.eq(play_one().mult, 1 * 1.5 * (4 + 1))
end)

T.test('Joker Mold: vanilla Stencil alone gives X(4 + 1)', function()
    T.start_run({ jokers = { 'stencil' }, ante = 3 })
    T.select_blind()
    T.eq(play_one().mult, 1 * (4 + 1))
end)

T.test('Joker Mold: 5 slots, 3 jokers incl. Mold -> X1.5 * (2 + 1) = X4.5', function()
    T.start_run({ jokers = { 'bplus_stencil_plus', 'credit_card', 'chaos' }, ante = 3 })
    T.select_blind()
    T.eq(play_one().mult, 1 * 1.5 * (2 + 1))
end)

T.test('Joker Mold: 5 slots, 4 jokers incl. Mold -> X1.5 * (1 + 1) = X3', function()
    T.start_run({ jokers = { 'bplus_stencil_plus', 'credit_card', 'chaos', 'egg' }, ante = 3 })
    T.select_blind()
    T.eq(play_one().mult, 1 * 1.5 * (1 + 1))
end)

T.test('Joker Mold: all slots full -> no effect', function()
    T.start_run({ jokers = { 'bplus_stencil_plus', 'credit_card', 'chaos', 'egg', 'joker' }, ante = 3 })
    T.select_blind()
    -- Joker adds +4 Mult; the Mold must not add anything
    T.eq(play_one().mult, 1 + 4)
end)

T.test('Joker Mold: a held vanilla Stencil counts as one more slot', function()
    T.start_run({ jokers = { 'bplus_stencil_plus', 'stencil' }, ante = 3 })
    T.select_blind()
    -- Mold: X1.5 * (3 empty + 2 stencils) ; vanilla Stencil: X(3 empty + 1 itself)
    T.eq(play_one().mult, 1 * 1.5 * (3 + 2) * (3 + 1))
end)

T.test('Joker Mold: vanilla Stencil forced to "+" gives X1.5 * (4 + 1)', function()
    T.start_run({ jokers = { 'stencil' }, ante = 3 })
    T.force_behavior('stencil', 'plus')
    T.select_blind()
    T.eq(play_one().mult, 1 * 1.5 * (4 + 1))
end)
