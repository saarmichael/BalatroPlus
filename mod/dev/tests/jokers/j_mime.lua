local T = BPlus.test

local function steel(spec) return { spec, enhancement = 'steel' } end

T.test('Marcel Marceau: with Oops! All 6s, a held Steel card triggers 1 + 2 times = X1.5 * 1.5 * 1.5', function()
    T.start_run({ jokers = { 'oops', 'bplus_mime_plus' } })
    T.select_blind()
    T.set_hand({ '2S', steel('KH'), '9C' })
    local r = T.play({ '2S' })
    T.eq(r.chips, 5 + 2)
    T.near(r.mult, 1 * 1.5 * 1.5 * 1.5, 1e-6)
end)

T.test('Marcel Marceau: without Oops!, many held Steel cards -> some trigger twice, some three times', function()
    T.start_run({ jokers = { 'bplus_mime_plus' }, hand_size = 9 })
    T.select_blind()
    T.set_hand({ '2S', steel('KH'), steel('KD'), steel('KS'), steel('KC'), steel('QH'), steel('QD'), steel('QS'), steel('QC') })
    local r = T.play({ '2S' })
    local k = math.floor(math.log(r.mult) / math.log(1.5) + 0.5)
    T.near(r.mult, 1.5 ^ k, 1e-6, 'mult is a power of 1.5')
    -- 8 Steel cards, each triggers 2 or 3 times
    T.truthy(k > 8 * 2 and k < 8 * 3, 'both 2 and 3 triggers seen, total triggers = ' .. k)
end)

T.test('Marcel Marceau: held card with no ability -> no retrigger', function()
    T.start_run({ jokers = { 'oops', 'bplus_mime_plus' } })
    T.select_blind()
    T.set_hand({ '2S', '9H', '9C' })
    local r = T.play({ '2S' })
    T.eq(r.mult, 1)
    T.eq(r.chips, 5 + 2)
end)

T.test('Marcel Marceau: Mime forced to "+" with Oops! All 6s -> Steel triggers 1 + 2 times', function()
    T.start_run({ jokers = { 'oops', 'mime' } })
    T.select_blind()
    T.set_hand({ '2S', steel('KH'), '9C' })
    T.force_behavior('mime', 'plus')
    local r = T.play({ '2S' })
    T.near(r.mult, 1 * 1.5 * 1.5 * 1.5, 1e-6)
end)

T.test('Mime (vanilla): held Steel triggers 1 + 1 times = X1.5 * 1.5', function()
    T.start_run({ jokers = { 'mime' } })
    T.select_blind()
    T.set_hand({ '2S', steel('KH'), '9C' })
    local r = T.play({ '2S' })
    T.near(r.mult, 1 * 1.5 * 1.5, 1e-6)
end)

T.test('Marcel Marceau JokerDisplay: held card triggers 1 + 1 = 2 times, played card 1 time; no text', function()
    T.start_run({ jokers = { 'bplus_mime_plus' }, ante = 3 })
    T.select_blind()
    T.set_hand({ '2S', '3H', '9C', '5D', '7D' })
    local c = G.hand.cards[1]
    T.eq(rawget(_G, 'JokerDisplay').calculate_card_triggers(c, nil, true), 1 + 1)
    T.eq(rawget(_G, 'JokerDisplay').calculate_card_triggers(c, { c }, false), 1)
    T.eq(T.joker_display('bplus_mime_plus').text, '')
end)
