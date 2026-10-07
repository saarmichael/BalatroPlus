local T = BPlus.test

local function near(a, e, what) T.near(a, e, 1e-6, what) end
local function next_round()
    if T.state_name() == 'SELECTING_HAND' then T.win_blind() end
    if T.state_name() == 'ROUND_EVAL' then T.cash_out() end
    if T.state_name() == 'SHOP' then T.leave_shop() end
end

local function begin(main, n)
    T.start_run({ jokers = { main, 'joker', 'joker', 'joker', 'joker' }, ante = 3, boss = 'club' })
end
local function gain(n)
    for _ = 1, n do T.sell('joker') end
end

T.test('Burning Man: sell 3 cards -> X(1 + 0.4 * 3) = X2.2 (vanilla: X1.75)', function()
    begin('bplus_campfire_plus', 3)
    gain(3)
    near(T.joker(1).ability.extra.Xmult, 1 + 0.4 * 3)
    T.select_blind()
    T.set_hand({ '2S', '3H', '4C', '5D', '7D' })
    near(T.play({ '2S' }).mult, 1 * (1 + 0.4 * 3) + 4, 'one Joker left: +4 Mult')
end)

T.test('Burning Man: defeat the Boss Blind -> back to X1', function()
    begin('bplus_campfire_plus', 2)
    gain(2)
    near(T.joker(1).ability.extra.Xmult, 1 + 0.4 * 2)
    T.skip_blind()
    T.skip_blind()
    T.select_blind()
    T.win_blind()
    near(T.joker(1).ability.extra.Xmult, 1)
end)

T.test('Burning Man: defeating a non-Boss Blind keeps the Xmult', function()
    begin('bplus_campfire_plus', 2)
    gain(2)
    T.select_blind()
    T.win_blind()
    near(T.joker(1).ability.extra.Xmult, 1 + 0.4 * 2)
end)

T.test('Burning Man: Campfire at X1.5, upgrade -> Burning Man keeps X1.5, next gain +0.4: X(1.5 + 0.4)', function()
    begin({ key = 'campfire', edition = 'foil' }, 3)
    gain(2)
    near(T.joker('campfire').ability.x_mult, 1 + 0.25 * 2, 'vanilla value')
    local card = T.upgrade('campfire')
    near(card.ability.extra.Xmult, 1 + 0.25 * 2, 'carried over')
    T.truthy(card.edition and card.edition.foil, 'foil kept')
    gain(1)
    near(card.ability.extra.Xmult, 1 + 0.25 * 2 + 0.4)
end)

T.test('Burning Man: campfire forced to "+" keeps its stored value, only the rate changes', function()
    begin({ key = 'campfire' }, 3)
    gain(1)
    near(T.joker('campfire').ability.x_mult, 1 + 0.25)
    T.force_behavior('campfire', 'plus')
    gain(1)
    near(T.joker('campfire').ability.x_mult, 1 + 0.25 + 0.4, 'stored on the vanilla card')
    T.force_behavior('campfire', nil)
    gain(1)
    near(T.joker('campfire').ability.x_mult, 1 + 0.25 + 0.4 + 0.25)
end)

T.test('Burning Man: forced to base gains the vanilla rate and keeps its value', function()
    begin({ key = 'bplus_campfire_plus' }, 3)
    gain(1)
    near(T.joker('bplus_campfire_plus').ability.extra.Xmult, 1 + 0.4)
    T.force_behavior('bplus_campfire_plus', 'base')
    gain(1)
    near(T.joker('bplus_campfire_plus').ability.extra.Xmult, 1 + 0.4 + 0.25)
    T.force_behavior('bplus_campfire_plus', nil)
    gain(1)
    near(T.joker('bplus_campfire_plus').ability.extra.Xmult, 1 + 0.4 + 0.25 + 0.4)
end)
