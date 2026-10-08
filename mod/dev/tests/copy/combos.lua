-- Lineups with several copy jokers. Every lineup plays a Pair of 2s (base 2 Mult) at ante 3 and checks the final Mult.
-- Vanilla Blueprint / Brainstorm only. Symbols: J+ = Joker+ (+20 Mult), J = Joker (+4), BP = Blueprint, BS = Brainstorm,
-- FF = Four Fingers (not copyable, no effect on a Pair), HK = Hack, HK+ = Jerry Seinfeld, OOPS = Oops! All 6s.
--
-- How a copy resolves (smods SMODS.blueprint_effect): copier -> target is skipped when the target is the copier itself,
-- debuffed, not blueprint_compat, or when context.blueprint is already larger than the number of jokers. Otherwise the
-- target's own calculate runs with context.blueprint + 1. Expected values below follow that rule by hand.
local T = BPlus.test

local KEY = {
    ['J+'] = 'bplus_joker_plus', J = 'joker', BP = 'blueprint', BS = 'brainstorm',
    FF = 'four_fingers', HK = 'hack', ['HK+'] = 'bplus_hack_plus', OOPS = 'oops',
}

local function lineup(symbols)
    local keys = {}
    for i, s in ipairs(symbols) do keys[i] = KEY[s] end
    return keys
end

local function play_pair()
    T.set_hand({ '2S', '2H', '7C', '5D', '3D' })
    return T.play({ '2S', '2H' })
end

local function mult_test(title, symbols, expected_mult)
    T.test(('%s [%s]'):format(title, table.concat(symbols, ', ')), function()
        T.start_run({ jokers = lineup(symbols), ante = 3, joker_slots = 8 })
        T.select_blind()
        local r = play_pair()
        T.eq(r.chips, 10 + 2 + 2)
        T.near(r.mult, expected_mult, 1e-6, 'Mult')
    end)
end

mult_test('Blueprint -> Blueprint -> Joker+', { 'BP', 'BP', 'J+' }, 2 + 20 + 20 + 20)
mult_test('Blueprint -> Blueprint -> Blueprint -> Joker+, Joker', { 'BP', 'BP', 'BP', 'J+', 'J' }, 2 + 20 + 20 + 20 + 20 + 4)
mult_test('Blueprint copies a Joker+ that is two slots away only through a Blueprint', { 'BP', 'J', 'J+' }, 2 + 4 + 4 + 20)
mult_test('Blueprint copies Brainstorm which copies the leftmost Joker+', { 'J+', 'BP', 'BS' }, 2 + 20 + 20 + 20)
mult_test('Brainstorm copies the leftmost Blueprint, which copies Joker+', { 'BP', 'J+', 'BS' }, 2 + 20 + 20 + 20)
mult_test('Brainstorm leftmost copies itself (nothing), Blueprint copies the Joker', { 'BS', 'BP', 'J' }, 2 + 4 + 4)
mult_test('Vanilla cycle: Blueprint <-> Brainstorm copies nothing', { 'BP', 'BS', 'J' }, 2 + 4)
mult_test('Vanilla cycle with Joker+ behind: Blueprint <-> Brainstorm copies nothing', { 'BP', 'BS', 'J+' }, 2 + 20)
mult_test('Two Brainstorms behind a Joker+ both copy it', { 'J+', 'BS', 'BS' }, 2 + 20 + 20 + 20)
mult_test('Blueprint at the right end copies nothing', { 'J+', 'J', 'BP' }, 2 + 20 + 4)
mult_test('Blueprint before an incompatible joker copies nothing', { 'BP', 'FF', 'J+' }, 2 + 20)
mult_test('Brainstorm with an incompatible leftmost joker copies nothing', { 'FF', 'J+', 'BS' }, 2 + 20)

-- Retriggers through a chain ----------------------------------------------------------------------------------------
-- Oops! All 6s (not copyable, last slot) makes Jerry Seinfeld's 1 in 2 certain: it retriggers 1 + 1, vanilla Hack 1.
-- Scored 2s score 1 + retriggers times each.
local function retrigger_test(title, symbols, retriggers)
    T.test(('%s [%s]'):format(title, table.concat(symbols, ', ')), function()
        T.start_run({ jokers = lineup(symbols), ante = 3, joker_slots = 8 })
        T.select_blind()
        local r = play_pair()
        T.eq(r.chips, 10 + 2 * (1 + retriggers) + 2 * (1 + retriggers))
        T.eq(r.mult, 2)
    end)
end

retrigger_test('Retriggers: Blueprint -> Blueprint -> Jerry Seinfeld', { 'BP', 'BP', 'HK+', 'OOPS' }, 2 + 2 + 2)
retrigger_test('Retriggers: Blueprint -> Blueprint -> Hack', { 'BP', 'BP', 'HK' }, 1 + 1 + 1)
retrigger_test('Retriggers: Jerry Seinfeld and Hack, Brainstorm copies the leftmost', { 'HK+', 'HK', 'BS', 'OOPS' }, 2 + 1 + 2)
retrigger_test('Retriggers: Blueprint copies Brainstorm which copies Jerry Seinfeld', { 'HK+', 'BP', 'BS', 'OOPS' }, 2 + 2 + 2)

-- JokerDisplay ------------------------------------------------------------------------------------------------------

T.test('JokerDisplay: chains and cycles of Blueprint / Brainstorm do not error', function()
    for _, symbols in ipairs({
        { 'BP', 'BP', 'J+' }, { 'BP', 'BS', 'J+' }, { 'J+', 'BP', 'BS' }, { 'BS', 'BP', 'J' }, { 'BS', 'BS' }, { 'BP' },
    }) do
        T.start_run({ jokers = lineup(symbols), joker_slots = 8 })
        for _ = 1, 2 do
            for i = 1, #symbols do T.joker_display(i) end
        end
        T.select_blind()
        play_pair()
        for i = 1, #symbols do T.joker_display(i) end
    end
end)
