local T = BPlus.test

local function count(key)
    local n = 0
    for _, c in ipairs(G.jokers.cards) do
        if c.config.center.key == key then n = n + 1 end
    end
    return n
end

local function two_rounds()
    T.to_shop()
    T.leave_shop()
    T.to_shop()
end

T.test('Phantom: after 2 rounds, sell with Joker held -> Joker becomes Joker+ and a second Joker+ appears', function()
    T.start_run({ jokers = { 'bplus_invisible_plus', 'joker' } })
    two_rounds()
    T.eq(T.joker(1).ability.extra.rounds, 2)
    T.sell('bplus_invisible_plus')
    T.eq(#G.jokers.cards, 2)
    T.eq(count('j_bplus_joker_plus'), 2)
    T.eq(count('j_joker'), 0)
end)

T.test('Phantom: held Joker+ and Joker -> always picks Joker: result Joker+, Joker+, Joker+', function()
    T.start_run({ jokers = { 'bplus_invisible_plus', 'bplus_joker_plus', 'joker' } })
    two_rounds()
    T.sell('bplus_invisible_plus')
    T.eq(#G.jokers.cards, 3)
    T.eq(count('j_bplus_joker_plus'), 3)
end)

T.test('Phantom: all other jokers already upgraded -> one is picked and duplicated', function()
    T.start_run({ jokers = { 'bplus_invisible_plus', 'bplus_joker_plus', 'bplus_golden_plus' } })
    two_rounds()
    T.sell('bplus_invisible_plus')
    T.eq(#G.jokers.cards, 3)
    T.eq(count('j_bplus_joker_plus') + count('j_bplus_golden_plus'), 3)
end)

T.test('Phantom: sold before 2 rounds -> does nothing', function()
    T.start_run({ jokers = { 'bplus_invisible_plus', 'joker' } })
    T.to_shop()
    T.eq(T.joker(1).ability.extra.rounds, 1)
    T.sell('bplus_invisible_plus')
    T.eq(#G.jokers.cards, 1)
    T.eq(count('j_joker'), 1)
end)

T.test('Phantom: Invisible Joker at 1/2, upgrade -> Phantom at 1/2', function()
    T.start_run({ jokers = { 'invisible', 'joker' } })
    T.to_shop()
    T.eq(T.joker(1).ability.invis_rounds, 1)
    local card = T.upgrade('invisible')
    T.eq(card.ability.extra.rounds, 1)
    T.leave_shop()
    T.to_shop()
    T.eq(card.ability.extra.rounds, 2)
    T.sell('bplus_invisible_plus')
    T.eq(count('j_bplus_joker_plus'), 2)
end)

T.test('Phantom: Invisible Joker forced to "+" upgrades and duplicates', function()
    T.start_run({ jokers = { 'invisible', 'joker' } })
    T.force_behavior('invisible', 'plus')
    two_rounds()
    T.sell('invisible')
    T.eq(count('j_bplus_joker_plus'), 2)
    T.eq(count('j_joker'), 0)
end)

T.test('Phantom JokerDisplay: (0/2) -> after a round (1/2); vanilla (1/2); forced behaviours keep the counter', function()
    T.start_run({ jokers = { 'bplus_invisible_plus', 'invisible' } })
    T.eq(T.joker_display('bplus_invisible_plus').reminder, '(0/2)')
    T.to_shop()
    T.eq(T.joker_display('bplus_invisible_plus').reminder, '(1/2)')
    T.eq(T.joker_display('invisible').reminder, '(1/2)')
    T.force_behavior('invisible', 'plus')
    T.eq(T.joker_display('invisible').reminder, '(1/2)')
    T.force_behavior('bplus_invisible_plus', 'base')
    T.eq(T.joker_display('bplus_invisible_plus').reminder, '(1/2)')
end)
