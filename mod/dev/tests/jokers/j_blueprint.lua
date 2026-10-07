local T = BPlus.test

local function pair2()
    T.set_hand({ '2S', '2H', '7C', '5D', '3D' })
    return T.play({ '2S', '2H' })
end

T.test('Architect: Architect, Joker+, Joker -> scores +20 + 4 from the copies, plus the originals', function()
    T.start_run({ jokers = { 'bplus_blueprint_plus', 'bplus_joker_plus', 'joker' }, ante = 3 })
    T.select_blind()
    local r = pair2()
    T.eq(r.chips, 10 + 2 + 2)
    T.eq(r.mult, 2 + 20 + 4 + 20 + 4)
end)

T.test('Architect: only one joker to the right -> copies just that one', function()
    T.start_run({ jokers = { 'joker', 'bplus_blueprint_plus', 'bplus_joker_plus' }, ante = 3 })
    T.select_blind()
    T.eq(pair2().mult, 2 + 4 + 20 + 20)
end)

T.test('Architect: right neighbours are not Blueprint-compatible -> nothing', function()
    T.start_run({ jokers = { 'bplus_blueprint_plus', 'invisible', 'chicot' }, ante = 3 })
    T.select_blind()
    T.eq(pair2().mult, 2)
end)

T.test('Architect: Blueprint (vanilla) before Architect copies Architect, which copies 2 more', function()
    T.start_run({ jokers = { 'blueprint', 'bplus_blueprint_plus', 'bplus_joker_plus', 'joker' }, ante = 3 })
    T.select_blind()
    -- Architect: +20 +4; Blueprint copying Architect: +20 +4; Joker+ +20; Joker +4
    T.eq(pair2().mult, 2 + (20 + 4) + (20 + 4) + 20 + 4)
end)

T.test('Architect: vanilla Blueprint forced to "+" copies two jokers', function()
    T.start_run({ jokers = { 'blueprint', 'bplus_joker_plus', 'joker' }, ante = 3 })
    T.select_blind()
    T.force_behavior('blueprint', 'plus')
    T.eq(pair2().mult, 2 + 20 + 4 + 20 + 4)
end)

T.test('Architect: Architect forced to base copies just one joker', function()
    T.start_run({ jokers = { 'bplus_blueprint_plus', 'bplus_joker_plus', 'joker' }, ante = 3 })
    T.force_behavior(1, 'base')
    T.select_blind()
    T.eq(pair2().mult, 2 + 20 + 20 + 4)
end)
