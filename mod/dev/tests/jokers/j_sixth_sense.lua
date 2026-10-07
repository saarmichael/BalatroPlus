local T = BPlus.test

local function sets()
    local t = {}
    for _, c in ipairs(G.consumeables.cards) do t[#t + 1] = c.ability.set end
    return t
end

T.test('Second Sixth Sense: first hand a single 6, 2 free slots -> 6 destroyed, 2 Spectral (vanilla: 1)', function()
    T.start_run({ ante = 3, jokers = { 'bplus_sixth_sense_plus' } })
    T.select_blind()
    T.set_hand({ '6S', 'KH', '2D', '3C', '9S' })
    T.play({ '6S' })
    T.eq(sets(), { 'Spectral', 'Spectral' })
    T.eq(#G.playing_cards, 52 - 1)
end)

T.test('Second Sixth Sense: only 1 free slot -> 1 Spectral created', function()
    T.start_run({ ante = 3, consumables = { 'pluto' }, jokers = { 'bplus_sixth_sense_plus' } })
    T.select_blind()
    T.set_hand({ '6S', 'KH', '2D', '3C', '9S' })
    T.play({ '6S' })
    T.eq(sets(), { 'Planet', 'Spectral' })
end)

T.test('Second Sixth Sense: slots full -> 6 still destroyed, nothing created', function()
    T.start_run({ ante = 3, consumables = { 'pluto', 'mercury' }, jokers = { 'bplus_sixth_sense_plus' } })
    T.select_blind()
    T.set_hand({ '6S', 'KH', '2D', '3C', '9S' })
    T.play({ '6S' })
    T.eq(sets(), { 'Planet', 'Planet' })
    T.eq(#G.playing_cards, 52 - 1)
end)

T.test('Second Sixth Sense: second hand of round a single 6 -> nothing', function()
    T.start_run({ ante = 3, jokers = { 'bplus_sixth_sense_plus' } })
    T.select_blind()
    T.set_hand({ 'KH', '6S', '2D', '3C', '9S' })
    T.play({ 'KH' })
    T.play({ '6S' })
    T.eq(#G.consumeables.cards, 0)
    T.eq(#G.playing_cards, 52)
end)

T.test('Second Sixth Sense: vanilla Sixth Sense forced to "+" creates 2 Spectral', function()
    T.start_run({ ante = 3, jokers = { 'sixth_sense' } })
    T.force_behavior('sixth_sense', 'plus')
    T.select_blind()
    T.set_hand({ '6S', 'KH', '2D', '3C', '9S' })
    T.play({ '6S' })
    T.eq(sets(), { 'Spectral', 'Spectral' })
end)

T.test('Second Sixth Sense JokerDisplay: +0 (6); vanilla forced to "+" and "+" forced to base show the same', function()
    T.start_run({ dollars = 6, jokers = { 'bplus_sixth_sense_plus', 'sixth_sense' } })
    local d = T.joker_display('bplus_sixth_sense_plus')
    T.eq(d.text, '+0')
    T.eq(d.reminder, '(6)')
    T.force_behavior('sixth_sense', 'plus')
    T.eq(T.joker_display('sixth_sense').text, '+0')
    T.force_behavior('bplus_sixth_sense_plus', 'base')
    T.eq(T.joker_display('bplus_sixth_sense_plus').text, '+0')
end)
