local T = BPlus.test

-- Lineups with several copy jokers (Architect, Hive Mind, vanilla Blueprint / Brainstorm), D23.
-- Joker = +4 Mult, Joker+ = +20 Mult. Pair of 2s: 10 + 2 + 2 Chips, base Mult 2.

local function run(jokers, extra)
    local s = { jokers = jokers, ante = 3 }
    for k, v in pairs(extra or {}) do s[k] = v end
    T.start_run(s)
    T.select_blind()
end
local function pair2()
    T.set_hand({ '2S', '2H', '7C', '9D', '3D' })
    return T.play({ '2S', '2H' })
end

T.test('Lineup: Architect -> Blueprint -> Joker: Architect runs Blueprint\'s "+" (Architect) on it, copying Joker+', function()
    run({ 'bplus_blueprint_plus', 'blueprint', 'joker' })
    -- Architect: +20 (Joker+ via Blueprint); Blueprint: +4; Joker: +4
    T.eq(pair2().mult, 2 + 20 + 4 + 4)
end)

T.test('Lineup: Blueprint -> Architect -> Joker: Blueprint copies Architect, which copies Joker+', function()
    run({ 'blueprint', 'bplus_blueprint_plus', 'joker' })
    -- Blueprint: +20; Architect: +20; Joker: +4
    T.eq(pair2().mult, 2 + 20 + 20 + 4)
end)

T.test('Lineup: Architect -> Architect -> Joker', function()
    run({ 'bplus_blueprint_plus', 'bplus_blueprint_plus', 'joker' })
    T.eq(pair2().mult, 2 + 20 + 20 + 4)
end)

T.test('Lineup: Architect -> Architect -> Joker+', function()
    run({ 'bplus_blueprint_plus', 'bplus_blueprint_plus', 'bplus_joker_plus' })
    T.eq(pair2().mult, 2 + 20 + 20 + 20)
end)

T.test('Lineup: Joker, Architect, Brainstorm: Architect runs Brainstorm\'s "+" (Hive Mind) on it, copying Joker+', function()
    run({ 'joker', 'bplus_blueprint_plus', 'brainstorm' })
    -- Joker +4; Architect (via Brainstorm as Hive Mind -> leftmost Joker+) +20; Brainstorm (Joker) +4
    T.eq(pair2().mult, 2 + 4 + 20 + 4)
end)

T.test('Lineup: Architect, Joker, Hive Mind -> Hive Mind copies Architect (which copies Joker+)', function()
    run({ 'bplus_blueprint_plus', 'joker', 'bplus_brainstorm_plus' })
    -- Architect: +20 (Joker+); Joker: +4; Hive Mind: Architect -> +20
    T.eq(pair2().mult, 2 + 20 + 4 + 20)
end)

T.test('Lineup: Hive Mind copies an Architect leftmost; Architect copies the next Joker+', function()
    run({ 'bplus_blueprint_plus', 'bplus_joker_plus', 'bplus_brainstorm_plus' })
    T.eq(pair2().mult, 2 + 20 + 20 + 20)
end)

T.test('Lineup: Joker, Architect, Blueprint, Brainstorm, Hive Mind with vanilla and "+" copiers together', function()
    run({ 'joker', 'bplus_blueprint_plus', 'blueprint', 'brainstorm', 'bplus_brainstorm_plus' }, { joker_slots = 6 })
    -- Joker +4
    -- Architect -> Blueprint viewed as Architect -> Brainstorm viewed as Hive Mind -> leftmost Joker+ : +20
    -- Blueprint -> Brainstorm -> Joker: +4;  Brainstorm -> Joker: +4;  Hive Mind -> Joker+: +20
    T.eq(pair2().mult, 2 + 4 + 20 + 4 + 4 + 20)
end)

T.test('Lineup: Architect at the right end copies nothing and is incompatible', function()
    run({ 'joker', 'bplus_blueprint_plus' })
    T.wait_frames(3)
    T.eq(T.joker('bplus_blueprint_plus').ability.blueprint_compat, 'incompatible')
    T.eq(pair2().mult, 2 + 4)
end)

T.test('Lineup: Hive Mind leftmost copies nothing and is incompatible', function()
    run({ 'bplus_brainstorm_plus', 'joker' })
    T.wait_frames(3)
    T.eq(T.joker('bplus_brainstorm_plus').ability.blueprint_compat, 'incompatible')
    T.eq(pair2().mult, 2 + 4)
end)

T.test('Cycle: Architect and Hive Mind copying each other terminates', function()
    run({ 'bplus_blueprint_plus', 'bplus_brainstorm_plus' })
    T.eq(pair2().mult, 2)
end)

T.test('Cycle: Blueprint, Architect, Hive Mind, Brainstorm terminate', function()
    run({ 'blueprint', 'bplus_blueprint_plus', 'bplus_brainstorm_plus', 'brainstorm' })
    pair2()
end)

T.test('Cycle: Brainstorm, Architect, Blueprint, Hive Mind with a Joker+ inside terminate', function()
    run({ 'brainstorm', 'bplus_blueprint_plus', 'blueprint', 'bplus_brainstorm_plus', 'bplus_joker_plus' }, { joker_slots = 6 })
    pair2()
end)

T.test('Retrigger chain: Blueprint -> Architect -> vanilla Hack copies Jerry Seinfeld\'s retriggers', function()
    run({ 'oops', 'blueprint', 'bplus_blueprint_plus', 'hack' })
    T.set_hand({ '5S', '9H' })
    -- 5 scores once + Hack 1 + Architect (Jerry Seinfeld: 1 + certain bonus 1 = 2) + Blueprint (copying Architect) 2
    T.eq(T.play({ '5S' }).chips, 5 + 5 * (1 + 1 + 2 + 2))
end)

T.test('Retrigger chain: Hive Mind -> Architect chain copies vanilla Hack as Jerry Seinfeld', function()
    run({ 'oops', 'bplus_blueprint_plus', 'hack', 'bplus_brainstorm_plus' })
    -- Hive Mind copies the leftmost Joker (Oops: nothing); only Architect + Hack count: 1 + 2
    T.set_hand({ '5S', '9H' })
    T.eq(T.play({ '5S' }).chips, 5 + 5 * (1 + 1 + 2))
end)

T.test('The Rust: Architect forced to base is Blueprint (vanilla Joker copied as +4); Hive Mind too', function()
    run({ 'joker', 'bplus_blueprint_plus', 'bplus_brainstorm_plus' })
    T.force_behavior('bplus_blueprint_plus', 'base')
    T.force_behavior('bplus_brainstorm_plus', 'base')
    -- Joker +4; Blueprint behaviour copies Hive Mind (Brainstorm behaviour -> Joker +4): +4; Brainstorm -> +4
    T.eq(pair2().mult, 2 + 4 + 4 + 4)
end)

T.test('JokerDisplay: Blueprint -> Architect -> Joker shows Joker+ (+20); Hive Mind -> Architect chain too', function()
    run({ 'blueprint', 'bplus_blueprint_plus', 'joker' })
    T.joker_display('joker')
    T.eq(T.joker_display('blueprint').text, '+20')
    T.eq(T.joker_display('bplus_blueprint_plus').text, '+20')
    run({ 'bplus_blueprint_plus', 'joker', 'bplus_brainstorm_plus' })
    T.joker_display('joker')
    T.eq(T.joker_display('bplus_brainstorm_plus').text, '+20')
end)

T.test('JokerDisplay: Architect -> vanilla Blueprint -> Joker shows +20 (Blueprint runs as Architect)', function()
    run({ 'bplus_blueprint_plus', 'blueprint', 'joker' })
    T.joker_display('joker')
    T.eq(T.joker_display('bplus_blueprint_plus').text, '+20')
    T.eq(T.joker_display('blueprint').text, '+4')
end)

T.test('JokerDisplay: a cycle shows (incompatible) and does not hang', function()
    run({ 'bplus_blueprint_plus', 'bplus_brainstorm_plus' })
    T.eq(T.joker_display('bplus_blueprint_plus').reminder, '(incompatible)')
end)
