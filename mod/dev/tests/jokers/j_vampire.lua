local T = BPlus.test

local function near(a, e, what) T.near(a, e, 1e-6, what) end
local function next_round()
    if T.state_name() == 'SELECTING_HAND' then T.win_blind() end
    if T.state_name() == 'ROUND_EVAL' then T.cash_out() end
    if T.state_name() == 'SHOP' then T.leave_shop() end
end

local STEEL = { 'KH', 'KS', 'KD', 'KC', 'QH' }
local function steel_hand(n)
    local specs = {}
    for i = 1, 5 do specs[i] = { STEEL[i], enhancement = 'steel' } end
    T.set_hand(specs)
    local play = {}
    for i = 1, n do play[i] = STEEL[i] end
    return T.play(play)
end
local function begin(main, n)
    T.start_run({ jokers = { main }, hands = 6, ante = 3 })
    T.select_blind()
end
local function gain(n) steel_hand(n) end
local function steel_count()
    local n = 0
    for _, c in ipairs(G.playing_cards) do
        if c.config.center.key == 'm_steel' then n = n + 1 end
    end
    return n
end

T.test('Dracula: play 2 scoring Steel cards -> X(1 + 0.2 * 2) = X1.4, both become plain cards (vanilla: X1.2)', function()
    begin('bplus_vampire_plus', 2)
    T.eq(steel_hand(2).hand, 'Pair')
    near(T.joker(1).ability.extra.Xmult, 1 + 0.2 * 2)
    T.eq(steel_count(), 3, 'the 3 unplayed Steel cards remain')
    T.set_hand({ '2S', '3H', '4C', '5D', '7D' })
    near(T.play({ '2S' }).mult, 1 * (1 + 0.2 * 2))
end)

T.test('Dracula: play plain cards -> no gain', function()
    begin('bplus_vampire_plus', 1)
    T.set_hand({ '2S', '3H', '4C', '5D', '7D' })
    T.play({ '2S', '3H' })
    near(T.joker(1).ability.extra.Xmult, 1)
end)

T.test('Dracula: Vampire at X1.2, upgrade -> Dracula keeps X1.2, next gain +0.2: X(1.2 + 0.2)', function()
    begin({ key = 'vampire', edition = 'foil' }, 3)
    gain(2)
    near(T.joker('vampire').ability.x_mult, 1 + 0.1 * 2, 'vanilla value')
    local card = T.upgrade('vampire')
    near(card.ability.extra.Xmult, 1 + 0.1 * 2, 'carried over')
    T.truthy(card.edition and card.edition.foil, 'foil kept')
    gain(1)
    near(card.ability.extra.Xmult, 1 + 0.1 * 2 + 0.2)
end)

T.test('Dracula: vampire forced to "+" keeps its stored value, only the rate changes', function()
    begin({ key = 'vampire' }, 3)
    gain(1)
    near(T.joker('vampire').ability.x_mult, 1 + 0.1)
    T.force_behavior('vampire', 'plus')
    gain(1)
    near(T.joker('vampire').ability.x_mult, 1 + 0.1 + 0.2, 'stored on the vanilla card')
    T.force_behavior('vampire', nil)
    gain(1)
    near(T.joker('vampire').ability.x_mult, 1 + 0.1 + 0.2 + 0.1)
end)

T.test('Dracula: forced to base gains the vanilla rate and keeps its value', function()
    begin({ key = 'bplus_vampire_plus' }, 3)
    gain(1)
    near(T.joker('bplus_vampire_plus').ability.extra.Xmult, 1 + 0.2)
    T.force_behavior('bplus_vampire_plus', 'base')
    gain(1)
    near(T.joker('bplus_vampire_plus').ability.extra.Xmult, 1 + 0.2 + 0.1)
    T.force_behavior('bplus_vampire_plus', nil)
    gain(1)
    near(T.joker('bplus_vampire_plus').ability.extra.Xmult, 1 + 0.2 + 0.1 + 0.2)
end)
