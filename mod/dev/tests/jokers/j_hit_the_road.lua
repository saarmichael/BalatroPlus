local T = BPlus.test

local function near(a, e, what) T.near(a, e, 1e-6, what) end
local function next_round()
    if T.state_name() == 'SELECTING_HAND' then T.win_blind() end
    if T.state_name() == 'ROUND_EVAL' then T.cash_out() end
    if T.state_name() == 'SHOP' then T.leave_shop() end
end

local JACKS = { 'JS', 'JH', 'JD', 'JC' }
local function begin(main, n)
    T.start_run({ jokers = { main }, ante = 3 })
    T.select_blind()
end
local function gain(n)
    T.set_hand({ 'JS', 'JH', 'JD', 'JC', '2C' })
    local d = {}
    for i = 1, n do d[i] = JACKS[i] end
    T.discard(d)
end

T.test('Hit the Road+: discard 2 Jacks -> X(1 + 1 * 2) = X3 (vanilla: X2)', function()
    begin('bplus_hit_the_road_plus', 2)
    gain(2)
    near(T.joker(1).ability.extra.Xmult, 1 + 1 * 2)
    T.set_hand({ '2S', '3H', '4C', '5D', '7D' })
    near(T.play({ '2S' }).mult, 1 * (1 + 1 * 2))
end)

T.test('Hit the Road+: next round -> back to X1', function()
    begin('bplus_hit_the_road_plus', 2)
    gain(2)
    near(T.joker(1).ability.extra.Xmult, 1 + 1 * 2)
    T.win_blind()
    near(T.joker(1).ability.extra.Xmult, 1)
end)

T.test('Hit the Road+: Hit the Road at X2, upgrade -> Hit the Road+ keeps X2, next gain +1: X(2 + 1)', function()
    begin({ key = 'hit_the_road', edition = 'foil' }, 3)
    gain(2)
    near(T.joker('hit_the_road').ability.x_mult, 1 + 0.5 * 2, 'vanilla value')
    local card = T.upgrade('hit_the_road')
    near(card.ability.extra.Xmult, 1 + 0.5 * 2, 'carried over')
    T.truthy(card.edition and card.edition.foil, 'foil kept')
    gain(1)
    near(card.ability.extra.Xmult, 1 + 0.5 * 2 + 1)
end)

T.test('Hit the Road+: hit_the_road forced to "+" keeps its stored value, only the rate changes', function()
    begin({ key = 'hit_the_road' }, 3)
    gain(1)
    near(T.joker('hit_the_road').ability.x_mult, 1 + 0.5)
    T.force_behavior('hit_the_road', 'plus')
    gain(1)
    near(T.joker('hit_the_road').ability.x_mult, 1 + 0.5 + 1, 'stored on the vanilla card')
    T.force_behavior('hit_the_road', nil)
    gain(1)
    near(T.joker('hit_the_road').ability.x_mult, 1 + 0.5 + 1 + 0.5)
end)

T.test('Hit the Road+: forced to base gains the vanilla rate and keeps its value', function()
    begin({ key = 'bplus_hit_the_road_plus' }, 3)
    gain(1)
    near(T.joker('bplus_hit_the_road_plus').ability.extra.Xmult, 1 + 1)
    T.force_behavior('bplus_hit_the_road_plus', 'base')
    gain(1)
    near(T.joker('bplus_hit_the_road_plus').ability.extra.Xmult, 1 + 1 + 0.5)
    T.force_behavior('bplus_hit_the_road_plus', nil)
    gain(1)
    near(T.joker('bplus_hit_the_road_plus').ability.extra.Xmult, 1 + 1 + 0.5 + 1)
end)
