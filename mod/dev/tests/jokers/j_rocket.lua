local T = BPlus.test

local function defeat_boss()
    T.skip_blind(); T.skip_blind()
    T.select_blind()
    T.win_blind()
end

T.test('Spaceship: end a non-boss round -> +$1', function()
    T.start_run({ dollars = 0, jokers = { 'bplus_rocket_plus' } })
    T.select_blind()
    T.win_blind()
    T.eq(T.cash_out(), 3 + 4 + 1)
    T.eq(T.joker(1).ability.extra.dollars, 1)
end)

T.test('Spaceship: defeat a Boss Blind -> payout becomes $1 + 4 = $5', function()
    T.start_run({ dollars = 0, jokers = { 'bplus_rocket_plus' } })
    defeat_boss()
    T.eq(T.joker(1).ability.extra.dollars, 1 + 4)
end)

T.test('Spaceship: Rocket paying $5, upgrade -> Spaceship pays $5, after the next Boss $5 + 4 = $9', function()
    T.start_run({ dollars = 0, jokers = { 'rocket' } })
    T.joker(1).ability.extra.dollars = 1 + 2 + 2
    local card = T.upgrade('rocket')
    T.eq(card.ability.extra.dollars, 5)
    defeat_boss()
    T.eq(T.joker(1).ability.extra.dollars, 5 + 4)
end)

T.test('Spaceship: Rocket forced to "+" keeps its value, gains +4 per Boss', function()
    T.start_run({ dollars = 0, jokers = { 'rocket' } })
    T.force_behavior('rocket', 'plus')
    defeat_boss()
    T.eq(T.joker(1).ability.extra.dollars, 1 + 4)
end)

T.test('Spaceship: forced to base gains +2 per Boss and keeps its value', function()
    T.start_run({ dollars = 0, jokers = { 'bplus_rocket_plus' } })
    T.joker(1).ability.extra.dollars = 5
    T.force_behavior(1, 'base')
    defeat_boss()
    T.eq(T.joker(1).ability.extra.dollars, 5 + 2)
end)

T.test('Spaceship JokerDisplay: +$1 (Round); after a Boss +$5; stored payout kept across forced behaviours', function()
    T.start_run({ jokers = { 'bplus_rocket_plus', 'rocket' } })
    local d = T.joker_display('bplus_rocket_plus')
    T.eq(d.text, '+$1')
    T.eq(d.reminder, '(Round)')
    T.joker(1).ability.extra.dollars = 1 + 4
    T.joker(2).ability.extra.dollars = 1 + 2
    T.eq(T.joker_display('bplus_rocket_plus').text, '+$' .. (1 + 4))
    T.eq(T.joker_display('rocket').text, '+$' .. (1 + 2))
    T.force_behavior('rocket', 'plus')
    T.eq(T.joker_display('rocket').text, '+$' .. (1 + 2))
    T.force_behavior('bplus_rocket_plus', 'base')
    T.eq(T.joker_display('bplus_rocket_plus').text, '+$' .. (1 + 4))
end)
