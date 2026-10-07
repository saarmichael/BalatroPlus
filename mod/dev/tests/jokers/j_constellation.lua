local T = BPlus.test

local function near(a, e, what) T.near(a, e, 1e-6, what) end
local function next_round()
    if T.state_name() == 'SELECTING_HAND' then T.win_blind() end
    if T.state_name() == 'ROUND_EVAL' then T.cash_out() end
    if T.state_name() == 'SHOP' then T.leave_shop() end
end

local PLANETS = { 'mercury', 'venus', 'earth', 'mars', 'jupiter' }
local used = 0
local function begin(main, n)
    used = 0
    local cons = {}
    for i = 1, n do cons[i] = PLANETS[i] end
    T.start_run({ jokers = { main }, consumables = cons, consumable_slots = math.max(n, 2) })
    T.select_blind()
end
local function gain(n)
    for _ = 1, n do
        used = used + 1
        T.use(PLANETS[used])
    end
end
local function hit()
    T.set_hand({ '2S', '3H', '4C', '5D', '7D' })
    return T.play({ '2S' })
end

T.test('Galaxy: use 3 Planet cards -> X(1 + 0.2 * 3) = X1.6 (vanilla: X1.3)', function()
    begin('bplus_constellation_plus', 3)
    gain(3)
    near(T.joker(1).ability.extra.Xmult, 1 + 0.2 * 3)
    near(hit().mult, 1 * (1 + 0.2 * 3))
end)

T.test('Galaxy: use a Tarot -> no gain', function()
    T.start_run({ jokers = { 'bplus_constellation_plus' }, consumables = { 'hermit' } })
    T.select_blind()
    T.use('hermit')
    near(T.joker(1).ability.extra.Xmult, 1)
end)

T.test('Galaxy: Constellation at X1.2, upgrade -> Galaxy keeps X1.2, next gain +0.2: X(1.2 + 0.2)', function()
    begin({ key = 'constellation', edition = 'foil' }, 3)
    gain(2)
    near(T.joker('constellation').ability.x_mult, 1 + 0.1 * 2, 'vanilla value')
    local card = T.upgrade('constellation')
    near(card.ability.extra.Xmult, 1 + 0.1 * 2, 'carried over')
    T.truthy(card.edition and card.edition.foil, 'foil kept')
    gain(1)
    near(card.ability.extra.Xmult, 1 + 0.1 * 2 + 0.2)
end)

T.test('Galaxy: constellation forced to "+" keeps its stored value, only the rate changes', function()
    begin({ key = 'constellation' }, 3)
    gain(1)
    near(T.joker('constellation').ability.x_mult, 1 + 0.1)
    T.force_behavior('constellation', 'plus')
    gain(1)
    near(T.joker('constellation').ability.x_mult, 1 + 0.1 + 0.2, 'stored on the vanilla card')
    T.force_behavior('constellation', nil)
    gain(1)
    near(T.joker('constellation').ability.x_mult, 1 + 0.1 + 0.2 + 0.1)
end)

T.test('Galaxy: forced to base gains the vanilla rate and keeps its value', function()
    begin({ key = 'bplus_constellation_plus' }, 3)
    gain(1)
    near(T.joker('bplus_constellation_plus').ability.extra.Xmult, 1 + 0.2)
    T.force_behavior('bplus_constellation_plus', 'base')
    gain(1)
    near(T.joker('bplus_constellation_plus').ability.extra.Xmult, 1 + 0.2 + 0.1)
    T.force_behavior('bplus_constellation_plus', nil)
    gain(1)
    near(T.joker('bplus_constellation_plus').ability.extra.Xmult, 1 + 0.2 + 0.1 + 0.2)
end)
