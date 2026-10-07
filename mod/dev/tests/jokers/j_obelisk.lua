local T = BPlus.test

local function near(a, e, what) T.near(a, e, 1e-6, what) end
local function next_round()
    if T.state_name() == 'SELECTING_HAND' then T.win_blind() end
    if T.state_name() == 'ROUND_EVAL' then T.cash_out() end
    if T.state_name() == 'SHOP' then T.leave_shop() end
end

local HEARTS = { '2H', '4H', '6H', '8H', 'KH' }
local function flush()
    T.set_hand(HEARTS)
    return T.play(HEARTS)
end
local function begin(main, n)
    T.start_run({ jokers = { main }, hands = 6, ante = 3 })
    T.select_blind()
    G.GAME.hands['Pair'].played = 10   -- setup: Pair is the most played hand
end
local function gain(n)
    for _ = 1, n do flush() end
end

T.test('Pyramid: most played is Pair; play 2 Flushes -> X(1 + 0.4 * 2) = X1.8 (vanilla: X1.4)', function()
    begin('bplus_obelisk_plus', 3)
    T.eq(flush().hand, 'Flush')
    near(T.joker(1).ability.extra.Xmult, 1 + 0.4)
    flush()
    near(T.joker(1).ability.extra.Xmult, 1 + 0.4 * 2)
end)

T.test('Pyramid: then play a Pair -> resets to X1', function()
    begin('bplus_obelisk_plus', 3)
    gain(2)
    near(T.joker(1).ability.extra.Xmult, 1 + 0.4 * 2)
    T.set_hand({ '2S', '2H', '4C', '5D', '7D' })
    T.eq(T.play({ '2S', '2H' }).hand, 'Pair')
    near(T.joker(1).ability.extra.Xmult, 1)
end)

T.test('Pyramid: Obelisk at X1.4, upgrade -> Pyramid keeps X1.4, next gain +0.4: X(1.4 + 0.4)', function()
    begin({ key = 'obelisk', edition = 'foil' }, 3)
    gain(2)
    near(T.joker('obelisk').ability.x_mult, 1 + 0.2 * 2, 'vanilla value')
    local card = T.upgrade('obelisk')
    near(card.ability.extra.Xmult, 1 + 0.2 * 2, 'carried over')
    T.truthy(card.edition and card.edition.foil, 'foil kept')
    gain(1)
    near(card.ability.extra.Xmult, 1 + 0.2 * 2 + 0.4)
end)

T.test('Pyramid: obelisk forced to "+" keeps its stored value, only the rate changes', function()
    begin({ key = 'obelisk' }, 3)
    gain(1)
    near(T.joker('obelisk').ability.x_mult, 1 + 0.2)
    T.force_behavior('obelisk', 'plus')
    gain(1)
    near(T.joker('obelisk').ability.x_mult, 1 + 0.2 + 0.4, 'stored on the vanilla card')
    T.force_behavior('obelisk', nil)
    gain(1)
    near(T.joker('obelisk').ability.x_mult, 1 + 0.2 + 0.4 + 0.2)
end)

T.test('Pyramid: forced to base gains the vanilla rate and keeps its value', function()
    begin({ key = 'bplus_obelisk_plus' }, 3)
    gain(1)
    near(T.joker('bplus_obelisk_plus').ability.extra.Xmult, 1 + 0.4)
    T.force_behavior('bplus_obelisk_plus', 'base')
    gain(1)
    near(T.joker('bplus_obelisk_plus').ability.extra.Xmult, 1 + 0.4 + 0.2)
    T.force_behavior('bplus_obelisk_plus', nil)
    gain(1)
    near(T.joker('bplus_obelisk_plus').ability.extra.Xmult, 1 + 0.4 + 0.2 + 0.4)
end)
