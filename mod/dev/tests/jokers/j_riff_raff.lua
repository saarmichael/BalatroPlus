local T = BPlus.test

local function all_plus_commons()
    for i = 2, #G.jokers.cards do
        local c = G.jokers.cards[i]
        T.truthy(BPlus.is_plus(c), c.config.center.key .. ' is a "+" joker')
        T.eq(c.config.center.rarity, 1)
    end
end

T.test('Nobleman: select Blind with 2 free slots -> 2 Common "+" jokers', function()
    T.start_run({ ante = 3, joker_slots = 3, jokers = { 'bplus_riff_raff_plus' } })
    T.select_blind()
    T.eq(#G.jokers.cards, 1 + 2)
    all_plus_commons()
end)

T.test('Nobleman: only 1 free slot -> 1 created', function()
    T.start_run({ ante = 3, joker_slots = 2, jokers = { 'bplus_riff_raff_plus' } })
    T.select_blind()
    T.eq(#G.jokers.cards, 1 + 1)
    all_plus_commons()
end)

T.test('Nobleman: joker slots full -> nothing', function()
    T.start_run({ ante = 3, joker_slots = 1, jokers = { 'bplus_riff_raff_plus' } })
    T.select_blind()
    T.eq(#G.jokers.cards, 1)
end)

T.test('Nobleman: vanilla Riff-Raff forced to "+" -> 2 Common "+" jokers', function()
    T.start_run({ ante = 3, joker_slots = 3, jokers = { 'riff_raff' } })
    T.force_behavior('riff_raff', 'plus')
    T.select_blind()
    T.eq(#G.jokers.cards, 1 + 2)
    all_plus_commons()
end)

T.test('Nobleman JokerDisplay: shows nothing (vanilla definition is empty)', function()
    T.start_run({ dollars = 6, jokers = { 'bplus_riff_raff_plus', 'riff_raff' } })
    T.eq(T.joker_display('bplus_riff_raff_plus').text, '')
    T.force_behavior('riff_raff', 'plus')
    T.eq(T.joker_display('riff_raff').text, '')
    T.force_behavior('bplus_riff_raff_plus', 'base')
    T.eq(T.joker_display('bplus_riff_raff_plus').text, '')
end)
