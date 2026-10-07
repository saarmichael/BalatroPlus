local T = BPlus.test

local function near(a, e, what) T.near(a, e, 1e-6, what) end
local function next_round()
    if T.state_name() == 'SELECTING_HAND' then T.win_blind() end
    if T.state_name() == 'ROUND_EVAL' then T.cash_out() end
    if T.state_name() == 'SHOP' then T.leave_shop() end
end

local STRAIGHT = { '5S', '6H', '7C', '8D', '9D' }
local function begin(main, n)
    T.start_run({ jokers = { main }, hands = 6, ante = 8 })
    T.select_blind()
end
local function gain(n)
    for _ = 1, n do
        T.set_hand(STRAIGHT)
        T.play(STRAIGHT)
    end
end

T.test('Sprinter: play 2 Straights -> +30 + 30 = 60 Chips (vanilla: 15 + 15)', function()
    begin('bplus_runner_plus', 2)
    T.set_hand(STRAIGHT)
    T.eq(T.play(STRAIGHT).chips, 30 + (5 + 6 + 7 + 8 + 9) + 30)
    T.set_hand(STRAIGHT)
    T.eq(T.play(STRAIGHT).chips, 30 + (5 + 6 + 7 + 8 + 9) + 30 + 30)
    T.eq(T.joker(1).ability.extra.chips, 30 + 30)
end)

T.test('Sprinter: play a Pair -> no gain', function()
    begin('bplus_runner_plus', 1)
    T.set_hand({ '2S', '2H', '4C', '5D', '7D' })
    T.play({ '2S', '2H' })
    T.eq(T.joker(1).ability.extra.chips, 0)
end)

T.test('Sprinter: Runner at +30 Chips, upgrade -> Sprinter keeps +30, next gain +30: 30 + 30', function()
    begin({ key = 'runner', edition = 'holo' }, 3)
    gain(2)
    near(T.joker('runner').ability.extra.chips, 0 + 15 * 2, 'vanilla value')
    local card = T.upgrade('runner')
    near(card.ability.extra.chips, 0 + 15 * 2, 'carried over')
    T.truthy(card.edition and card.edition.holo, 'holo kept')
    gain(1)
    near(card.ability.extra.chips, 0 + 15 * 2 + 30)
end)

T.test('Sprinter: runner forced to "+" keeps its stored value, only the rate changes', function()
    begin({ key = 'runner' }, 3)
    gain(1)
    near(T.joker('runner').ability.extra.chips, 0 + 15)
    T.force_behavior('runner', 'plus')
    gain(1)
    near(T.joker('runner').ability.extra.chips, 0 + 15 + 30, 'stored on the vanilla card')
    T.force_behavior('runner', nil)
    gain(1)
    near(T.joker('runner').ability.extra.chips, 0 + 15 + 30 + 15)
end)

T.test('Sprinter: forced to base gains the vanilla rate and keeps its value', function()
    begin({ key = 'bplus_runner_plus' }, 3)
    gain(1)
    near(T.joker('bplus_runner_plus').ability.extra.chips, 0 + 30)
    T.force_behavior('bplus_runner_plus', 'base')
    gain(1)
    near(T.joker('bplus_runner_plus').ability.extra.chips, 0 + 30 + 15)
    T.force_behavior('bplus_runner_plus', nil)
    gain(1)
    near(T.joker('bplus_runner_plus').ability.extra.chips, 0 + 30 + 15 + 30)
end)

T.test('Sprinter JokerDisplay: +40 stored; vanilla forced to "+" shows its stored +24; "+" forced to base shows +40', function()
    T.start_run({ jokers = { 'bplus_runner_plus', 'runner' }, ante = 3 })
    T.joker(1).ability.extra.chips = 40   -- setup: stored value
    T.joker(2).ability.extra.chips = 24
    T.eq(T.joker_display('bplus_runner_plus').text, '+40')
    T.eq(T.joker_display('runner').text, '+24')
    T.force_behavior('runner', 'plus')
    T.eq(T.joker_display('runner').text, '+24')
    T.force_behavior('bplus_runner_plus', 'base')
    T.eq(T.joker_display('bplus_runner_plus').text, '+40')
end)
