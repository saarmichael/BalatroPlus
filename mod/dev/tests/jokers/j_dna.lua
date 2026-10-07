local T = BPlus.test

local function kings_of_spades()
    local n = 0
    for _, c in ipairs(G.playing_cards) do
        if c.base.value == 'King' and c.base.suit == 'Spades' then n = n + 1 end
    end
    return n
end

T.test('Mitosis: first hand is a single King -> 2 Kings added to deck (52 + 2 = 54)', function()
    T.start_run({ jokers = { 'bplus_dna_plus' }, ante = 3 })
    T.select_blind()
    T.set_hand({ 'KS', '9H', '2C' })
    T.play({ 'KS' })
    T.eq(#G.playing_cards, 52 + 2)
    T.eq(kings_of_spades(), 1 + 2)
end)

T.test('Mitosis: first hand has 2 cards -> no copies', function()
    T.start_run({ jokers = { 'bplus_dna_plus' }, ante = 3 })
    T.select_blind()
    T.set_hand({ 'KS', 'KH', '2C' })
    T.play({ 'KS', 'KH' })
    T.eq(#G.playing_cards, 52)
end)

T.test('Mitosis: second hand of the round is a single card -> no copies', function()
    T.start_run({ jokers = { 'bplus_dna_plus' }, ante = 3 })
    T.select_blind()
    T.set_hand({ 'KS', 'KH', '2C' })
    T.play({ 'KS', 'KH' })
    T.set_hand({ 'QS', '9H', '2C' })
    T.play({ 'QS' })
    T.eq(#G.playing_cards, 52)
end)

T.test('DNA (vanilla): single card -> 1 copy (52 + 1)', function()
    T.start_run({ jokers = { 'dna' }, ante = 3 })
    T.select_blind()
    T.set_hand({ 'KS', '9H', '2C' })
    T.play({ 'KS' })
    T.eq(#G.playing_cards, 52 + 1)
end)

T.test('Mitosis: DNA forced to "+" -> 2 copies (52 + 2)', function()
    T.start_run({ jokers = { 'dna' }, ante = 3 })
    T.force_behavior('dna', 'plus')
    T.select_blind()
    T.set_hand({ 'KS', '9H', '2C' })
    T.play({ 'KS' })
    T.eq(#G.playing_cards, 52 + 2)
end)

T.test('Mitosis JokerDisplay: (Active!) on the first hand, (Inactive) after playing one', function()
    T.start_run({ jokers = { 'bplus_dna_plus', 'dna' }, hands = 3, ante = 3 })
    T.select_blind()
    T.eq(T.joker_display('bplus_dna_plus').reminder, '(Active!)')
    T.force_behavior('dna', 'plus')
    T.eq(T.joker_display('dna').reminder, '(Active!)')
    T.force_behavior('bplus_dna_plus', 'base')
    T.eq(T.joker_display('bplus_dna_plus').reminder, '(Active!)')
    T.force_behavior('bplus_dna_plus', nil)
    T.set_hand({ '2S', '3H', '9C', '5D', '7D' })
    T.play({ '2S', '3H' })
    T.eq(T.joker_display('bplus_dna_plus').reminder, '(Inactive)')
end)
