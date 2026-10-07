local T = BPlus.test

T.test('Bond: end round -> Joker sells for $1 + 2, Tarot for $1 + 2', function()
    T.start_run({ jokers = { 'bplus_gift_plus', 'joker' }, consumables = { 'fool' } })
    local joker, tarot = T.joker('joker'), T.consumable('fool')
    local j0, t0 = joker.sell_cost, tarot.sell_cost
    T.select_blind()
    T.win_blind()
    T.eq(joker.sell_cost, j0 + 2)
    T.eq(tarot.sell_cost, t0 + 2)
    T.eq(joker.ability.extra_value, 2)
end)

T.test('Bond: vanilla Gift Card adds $1', function()
    T.start_run({ jokers = { 'gift', 'joker' } })
    local joker = T.joker('joker')
    local j0 = joker.sell_cost
    T.select_blind()
    T.win_blind()
    T.eq(joker.sell_cost, j0 + 1)
end)

T.test('Bond: Gift Card forced to "+" adds $2', function()
    T.start_run({ jokers = { 'gift', 'joker' } })
    T.force_behavior('gift', 'plus')
    local joker = T.joker('joker')
    local j0 = joker.sell_cost
    T.select_blind()
    T.win_blind()
    T.eq(joker.sell_cost, j0 + 2)
end)

T.test('Bond JokerDisplay: shows nothing, also for vanilla forced to "+" and "+" forced to base', function()
    T.start_run({ jokers = { 'bplus_gift_plus', 'gift' } })
    T.eq(T.joker_display('bplus_gift_plus').text, '')
    T.force_behavior('gift', 'plus')
    T.eq(T.joker_display('gift').text, '')
    T.force_behavior('bplus_gift_plus', 'base')
    T.eq(T.joker_display('bplus_gift_plus').text, '')
end)
