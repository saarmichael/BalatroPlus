local T = BPlus.test

local function near(a, e, what) T.near(a, e, 1e-6, what) end
local function next_round()
    if T.state_name() == 'SELECTING_HAND' then T.win_blind() end
    if T.state_name() == 'ROUND_EVAL' then T.cash_out() end
    if T.state_name() == 'SHOP' then T.leave_shop() end
end

local LUCKY = { 'KH', 'KS', 'KD' }
-- three Oops! All 6s make every Lucky roll succeed
local function begin(main, n)
    T.start_run({ jokers = { main, 'oops', 'oops', 'oops' }, hands = 6, ante = 8 })
    T.select_blind()
end
local function gain(n)
    local specs = {}
    for i = 1, 5 do specs[i] = { ({ 'KH', 'KS', 'KD', 'QC', 'QH' })[i], enhancement = 'lucky' } end
    T.set_hand(specs)
    local play = {}
    for i = 1, n do play[i] = LUCKY[i] end
    T.play(play)
end

T.test('Maneki-neko: with Oops! All 6s, 2 Lucky cards trigger -> X(1 + 0.4 * 2) = X1.8 (vanilla: X1.5)', function()
    begin('bplus_lucky_cat_plus', 2)
    gain(2)
    near(T.joker(1).ability.extra.Xmult, 1 + 0.4 * 2)
end)

T.test('Maneki-neko: Lucky Cat at X1.5, upgrade -> Maneki-neko keeps X1.5, next gain +0.4: X(1.5 + 0.4)', function()
    begin({ key = 'lucky_cat', edition = 'foil' }, 3)
    gain(2)
    near(T.joker('lucky_cat').ability.x_mult, 1 + 0.25 * 2, 'vanilla value')
    local card = T.upgrade('lucky_cat')
    near(card.ability.extra.Xmult, 1 + 0.25 * 2, 'carried over')
    T.truthy(card.edition and card.edition.foil, 'foil kept')
    gain(1)
    near(card.ability.extra.Xmult, 1 + 0.25 * 2 + 0.4)
end)

T.test('Maneki-neko: lucky_cat forced to "+" keeps its stored value, only the rate changes', function()
    begin({ key = 'lucky_cat' }, 3)
    gain(1)
    near(T.joker('lucky_cat').ability.x_mult, 1 + 0.25)
    T.force_behavior('lucky_cat', 'plus')
    gain(1)
    near(T.joker('lucky_cat').ability.x_mult, 1 + 0.25 + 0.4, 'stored on the vanilla card')
    T.force_behavior('lucky_cat', nil)
    gain(1)
    near(T.joker('lucky_cat').ability.x_mult, 1 + 0.25 + 0.4 + 0.25)
end)

T.test('Maneki-neko: forced to base gains the vanilla rate and keeps its value', function()
    begin({ key = 'bplus_lucky_cat_plus' }, 3)
    gain(1)
    near(T.joker('bplus_lucky_cat_plus').ability.extra.Xmult, 1 + 0.4)
    T.force_behavior('bplus_lucky_cat_plus', 'base')
    gain(1)
    near(T.joker('bplus_lucky_cat_plus').ability.extra.Xmult, 1 + 0.4 + 0.25)
    T.force_behavior('bplus_lucky_cat_plus', nil)
    gain(1)
    near(T.joker('bplus_lucky_cat_plus').ability.extra.Xmult, 1 + 0.4 + 0.25 + 0.4)
end)
