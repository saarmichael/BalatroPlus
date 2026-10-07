local T = BPlus.test

local function sealed_in_hand()
    local n = 0
    for _, c in ipairs(G.hand.cards) do if c.seal then n = n + 1 end end
    return n
end

T.test('Diploma: start a round -> hand has 8 + 2 cards, both new cards have a seal', function()
    T.start_run({ jokers = { 'bplus_certificate_plus' } })
    T.select_blind()
    T.eq(#G.hand.cards, 8 + 2)
    T.eq(sealed_in_hand(), 2)
end)

T.test('Diploma: deck size grows by 2 per round', function()
    T.start_run({ jokers = { 'bplus_certificate_plus' } })
    T.select_blind()
    T.eq(#G.playing_cards, 52 + 2)
    T.win_blind(); T.cash_out(); T.leave_shop()
    T.select_blind()
    T.eq(#G.playing_cards, 52 + 2 + 2)
end)

T.test('Certificate (vanilla): 1 sealed card per round', function()
    T.start_run({ jokers = { 'certificate' } })
    T.select_blind()
    T.eq(#G.hand.cards, 8 + 1)
    T.eq(sealed_in_hand(), 1)
end)

T.test('Diploma: Certificate forced to "+" -> 2 sealed cards', function()
    T.start_run({ jokers = { 'certificate' } })
    T.force_behavior('certificate', 'plus')
    T.select_blind()
    T.eq(sealed_in_hand(), 2)
end)
