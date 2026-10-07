local T = BPlus.test

local function near(a, e, what) T.near(a, e, 1e-6, what) end
local function next_round()
    if T.state_name() == 'SELECTING_HAND' then T.win_blind() end
    if T.state_name() == 'ROUND_EVAL' then T.cash_out() end
    if T.state_name() == 'SHOP' then T.leave_shop() end
end

local function begin(main, n)
    T.start_run({ jokers = { main }, ante = 3 })
    T.select_blind()
    G.GAME.current_round.castle_card.suit = 'Hearts'   -- setup: the listed suit
end
local function gain(n)
    T.set_hand({ '2H', '4H', '6H', '8H', 'KH' })
    local d = {}
    for i = 1, n do d[i] = i end
    T.discard(d)
end

T.test('Citadel: listed suit Hearts: discard 3 Hearts -> +6 * 3 = 18 Chips (vanilla: 3 * 3)', function()
    begin('bplus_castle_plus', 3)
    gain(3)
    T.eq(T.joker(1).ability.extra.chips, 6 * 3)
    T.set_hand({ '2S', '3S', '4C', '5D', '7D' })
    T.eq(T.play({ '2S' }).chips, 5 + 2 + 6 * 3)
end)

T.test('Citadel: discard other suits -> no gain', function()
    begin('bplus_castle_plus', 1)
    T.set_hand({ '2S', '3S', '4C', '5D', '7D' })
    T.discard({ '2S', '3S', '4C' })
    T.eq(T.joker(1).ability.extra.chips, 0)
end)

T.test('Citadel: Castle at +6 Chips (2 Hearts), upgrade -> Citadel keeps +6, next gain +6: 6 + 6', function()
    begin({ key = 'castle', edition = 'holo' }, 3)
    gain(2)
    near(T.joker('castle').ability.extra.chips, 0 + 3 * 2, 'vanilla value')
    local card = T.upgrade('castle')
    near(card.ability.extra.chips, 0 + 3 * 2, 'carried over')
    T.truthy(card.edition and card.edition.holo, 'holo kept')
    gain(1)
    near(card.ability.extra.chips, 0 + 3 * 2 + 6)
end)

T.test('Citadel: castle forced to "+" keeps its stored value, only the rate changes', function()
    begin({ key = 'castle' }, 3)
    gain(1)
    near(T.joker('castle').ability.extra.chips, 0 + 3)
    T.force_behavior('castle', 'plus')
    gain(1)
    near(T.joker('castle').ability.extra.chips, 0 + 3 + 6, 'stored on the vanilla card')
    T.force_behavior('castle', nil)
    gain(1)
    near(T.joker('castle').ability.extra.chips, 0 + 3 + 6 + 3)
end)

T.test('Citadel: forced to base gains the vanilla rate and keeps its value', function()
    begin({ key = 'bplus_castle_plus' }, 3)
    gain(1)
    near(T.joker('bplus_castle_plus').ability.extra.chips, 0 + 6)
    T.force_behavior('bplus_castle_plus', 'base')
    gain(1)
    near(T.joker('bplus_castle_plus').ability.extra.chips, 0 + 6 + 3)
    T.force_behavior('bplus_castle_plus', nil)
    gain(1)
    near(T.joker('bplus_castle_plus').ability.extra.chips, 0 + 6 + 3 + 6)
end)

T.test('Citadel JokerDisplay: +36 (Hearts); vanilla forced to "+" and "+" forced to base keep the stored value', function()
    T.start_run({ jokers = { 'bplus_castle_plus', 'castle' }, ante = 3 })
    G.GAME.current_round.castle_card.suit = 'Hearts'   -- setup: the listed suit
    T.joker(1).ability.extra.chips = 36
    T.joker(2).ability.extra.chips = 9
    local d = T.joker_display('bplus_castle_plus')
    T.eq(d.text, '+36')
    T.eq(d.reminder, '(Hearts)')
    T.eq(T.joker_display('castle').text, '+9')
    T.force_behavior('castle', 'plus')
    T.eq(T.joker_display('castle').text, '+9')
    T.eq(T.joker_display('castle').reminder, '(Hearts)')
    T.force_behavior('bplus_castle_plus', 'base')
    T.eq(T.joker_display('bplus_castle_plus').text, '+36')
end)
