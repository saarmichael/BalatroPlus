local T = BPlus.test

local function near(a, e, what) T.near(a, e, 1e-6, what) end
local function next_round()
    if T.state_name() == 'SELECTING_HAND' then T.win_blind() end
    if T.state_name() == 'ROUND_EVAL' then T.cash_out() end
    if T.state_name() == 'SHOP' then T.leave_shop() end
end

local function begin(main, n)
    T.start_run({ jokers = { main }, hands = 6, ante = 3 })
    T.select_blind()
end
local function gain(n)
    for _ = 1, n do
        T.set_hand({ '2S', '3H', '4C', '5D', '7D' })
        T.play({ '2S' })
    end
end

T.test('Wee Wee Joker: score a Pair of 2s -> gains +16 + 16 = 32 Chips (vanilla: 8 + 8)', function()
    begin('bplus_wee_plus', 1)
    T.set_hand({ '2S', '2H', '4C', '5D', '7D' })
    T.eq(T.play({ '2S', '2H' }).chips, 10 + 2 + 2 + 16 + 16)
    T.eq(T.joker(1).ability.extra.chips, 16 + 16)
end)

T.test('Wee Wee Joker: score a 3 -> no gain', function()
    begin('bplus_wee_plus', 1)
    T.set_hand({ '3S', '4H', '6C', '5D', '7D' })
    T.play({ '3S' })
    T.eq(T.joker(1).ability.extra.chips, 0)
end)

T.test('Wee Wee Joker: Wee Joker at +16 Chips (two 2s), upgrade -> Wee Wee Joker keeps +16, next gain +16: 16 + 16', function()
    begin({ key = 'wee', edition = 'holo' }, 3)
    gain(2)
    near(T.joker('wee').ability.extra.chips, 0 + 8 * 2, 'vanilla value')
    local card = T.upgrade('wee')
    near(card.ability.extra.chips, 0 + 8 * 2, 'carried over')
    T.truthy(card.edition and card.edition.holo, 'holo kept')
    gain(1)
    near(card.ability.extra.chips, 0 + 8 * 2 + 16)
end)

T.test('Wee Wee Joker: wee forced to "+" keeps its stored value, only the rate changes', function()
    begin({ key = 'wee' }, 3)
    gain(1)
    near(T.joker('wee').ability.extra.chips, 0 + 8)
    T.force_behavior('wee', 'plus')
    gain(1)
    near(T.joker('wee').ability.extra.chips, 0 + 8 + 16, 'stored on the vanilla card')
    T.force_behavior('wee', nil)
    gain(1)
    near(T.joker('wee').ability.extra.chips, 0 + 8 + 16 + 8)
end)

T.test('Wee Wee Joker: forced to base gains the vanilla rate and keeps its value', function()
    begin({ key = 'bplus_wee_plus' }, 3)
    gain(1)
    near(T.joker('bplus_wee_plus').ability.extra.chips, 0 + 16)
    T.force_behavior('bplus_wee_plus', 'base')
    gain(1)
    near(T.joker('bplus_wee_plus').ability.extra.chips, 0 + 16 + 8)
    T.force_behavior('bplus_wee_plus', nil)
    gain(1)
    near(T.joker('bplus_wee_plus').ability.extra.chips, 0 + 16 + 8 + 16)
end)

T.test('Wee Wee Joker JokerDisplay: +40 stored; vanilla forced to "+" shows its stored +24; "+" forced to base shows +40', function()
    T.start_run({ jokers = { 'bplus_wee_plus', 'wee' }, ante = 3 })
    T.joker(1).ability.extra.chips = 40   -- setup: stored value
    T.joker(2).ability.extra.chips = 24
    T.eq(T.joker_display('bplus_wee_plus').text, '+40')
    T.eq(T.joker_display('wee').text, '+24')
    T.force_behavior('wee', 'plus')
    T.eq(T.joker_display('wee').text, '+24')
    T.force_behavior('bplus_wee_plus', 'base')
    T.eq(T.joker_display('bplus_wee_plus').text, '+40')
end)
