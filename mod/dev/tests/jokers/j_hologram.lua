local T = BPlus.test

local function near(a, e, what) T.near(a, e, 1e-6, what) end
local function next_round()
    if T.state_name() == 'SELECTING_HAND' then T.win_blind() end
    if T.state_name() == 'ROUND_EVAL' then T.cash_out() end
    if T.state_name() == 'SHOP' then T.leave_shop() end
end

-- DNA copies the single card of the first hand: +1 playing card per round, on demand.
local function begin(main, n)
    T.start_run({ jokers = { main, 'dna' }, ante = 3, boss = 'club' })
end
local function gain(n)
    for _ = 1, n do
        next_round()
        T.select_blind()
        T.set_hand({ '2S', '3H', '4C', '5D', '7D' })
        T.play({ '2S' })
    end
end

T.test('Holodeck: add 2 cards (Certificate twice) -> X(1 + 0.35 * 2) = X1.7 (vanilla: X1.5)', function()
    T.start_run({ jokers = { 'bplus_hologram_plus', 'certificate', 'certificate' } })
    T.select_blind()
    T.wait_idle()
    near(T.joker(1).ability.extra.Xmult, 1 + 0.35 * 2)
    T.set_hand({ '2S', '3H', '4C', '5D', '7D' })
    near(T.play({ '2S' }).mult, 1 * (1 + 0.35 * 2))
end)

T.test('Holodeck: Hologram at X1.5, upgrade -> Holodeck keeps X1.5, next gain +0.35: X(1.5 + 0.35)', function()
    begin({ key = 'hologram', edition = 'foil' }, 3)
    gain(2)
    near(T.joker('hologram').ability.x_mult, 1 + 0.25 * 2, 'vanilla value')
    local card = T.upgrade('hologram')
    near(card.ability.extra.Xmult, 1 + 0.25 * 2, 'carried over')
    T.truthy(card.edition and card.edition.foil, 'foil kept')
    gain(1)
    near(card.ability.extra.Xmult, 1 + 0.25 * 2 + 0.35)
end)

T.test('Holodeck: hologram forced to "+" keeps its stored value, only the rate changes', function()
    begin({ key = 'hologram' }, 3)
    gain(1)
    near(T.joker('hologram').ability.x_mult, 1 + 0.25)
    T.force_behavior('hologram', 'plus')
    gain(1)
    near(T.joker('hologram').ability.x_mult, 1 + 0.25 + 0.35, 'stored on the vanilla card')
    T.force_behavior('hologram', nil)
    gain(1)
    near(T.joker('hologram').ability.x_mult, 1 + 0.25 + 0.35 + 0.25)
end)

T.test('Holodeck: forced to base gains the vanilla rate and keeps its value', function()
    begin({ key = 'bplus_hologram_plus' }, 3)
    gain(1)
    near(T.joker('bplus_hologram_plus').ability.extra.Xmult, 1 + 0.35)
    T.force_behavior('bplus_hologram_plus', 'base')
    gain(1)
    near(T.joker('bplus_hologram_plus').ability.extra.Xmult, 1 + 0.35 + 0.25)
    T.force_behavior('bplus_hologram_plus', nil)
    gain(1)
    near(T.joker('bplus_hologram_plus').ability.extra.Xmult, 1 + 0.35 + 0.25 + 0.35)
end)
