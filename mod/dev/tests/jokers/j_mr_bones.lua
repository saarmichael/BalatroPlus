local T = BPlus.test

-- Ante 1 small blind needs 300 chips. One hand only, so playing it decides the round.
local function lose_with(cards_spec, play)
    T.select_blind()
    T.set_hand(cards_spec)
    return T.play(play)
end

local TWO_PAIR = { 'KS', 'KH', 'QC', 'QD', '2S' }
local PAIR_ACES = { 'AS', 'AH', '7C', '5D', '3S' }

T.test('Lich: lose with 40% of required chips -> saved (round continues)', function()
    T.start_run({ jokers = { 'bplus_mr_bones_plus' }, hands = 1 })
    local r = lose_with(TWO_PAIR, { 'KS', 'KH', 'QC', 'QD' })
    -- Two Pair: (20 + 10 * 4) chips * 2 mult = 120 of 300
    T.eq(r.score, (20 + 10 * 4) * 2)
    T.eq(r.state, 'ROUND_EVAL')
end)

T.test('Lich: lose with 20% of required chips -> game over', function()
    T.start_run({ jokers = { 'bplus_mr_bones_plus' }, hands = 1 })
    local r = lose_with(PAIR_ACES, { 'AS', 'AH' })
    -- Pair of Aces: (10 + 11 + 11) chips * 2 mult = 64 of 300 (21%)
    T.eq(r.score, (10 + 11 + 11) * 2)
    T.eq(r.state, 'GAME_OVER')
end)

T.test('Lich: seeded runs, saved several times -> sometimes destroyed, sometimes kept', function()
    local kept, destroyed = 0, 0
    for i = 1, 10 do
        T.start_run({ jokers = { 'bplus_mr_bones_plus' }, hands = 1, seed = 'LICH' .. i })
        local r = lose_with(TWO_PAIR, { 'KS', 'KH', 'QC', 'QD' })
        T.eq(r.state, 'ROUND_EVAL', 'saved')
        T.wait_frames(30)
        if T.joker(1) then kept = kept + 1 else destroyed = destroyed + 1 end
    end
    T.truthy(kept > 0, 'kept at least once (kept=' .. kept .. ')')
    T.truthy(destroyed > 0, 'destroyed at least once (destroyed=' .. destroyed .. ')')
end)

T.test('Lich: Oops! All 6s makes the self destruct certain (2 in 2)', function()
    T.start_run({ jokers = { 'bplus_mr_bones_plus', 'oops' }, hands = 1 })
    lose_with(TWO_PAIR, { 'KS', 'KH', 'QC', 'QD' })
    T.wait_frames(30)
    T.falsy(T.joker('bplus_mr_bones_plus'), 'destroyed')
    T.truthy(T.joker('oops'), 'oops stays')
end)

T.test('Lich: vanilla Mr. Bones forced to "+" is destroyed or kept on the roll, still saves', function()
    T.start_run({ jokers = { 'mr_bones' }, hands = 1 })
    T.force_behavior('mr_bones', 'plus')
    local r = lose_with(TWO_PAIR, { 'KS', 'KH', 'QC', 'QD' })
    T.eq(r.state, 'ROUND_EVAL')
end)

T.test('Lich JokerDisplay: (Inactive) at 0 chips, (Active) at 40% of the blind; forced behaviours agree', function()
    T.start_run({ jokers = { 'bplus_mr_bones_plus', 'mr_bones' }, hands = 5, ante = 3 })
    T.select_blind()
    T.eq(T.joker_display('bplus_mr_bones_plus').reminder, '(Inactive)')
    T.set_hand({ 'KS', 'KH', 'QC', 'QD', '2S' })
    T.play({ 'KS', 'KH', 'QC', 'QD' }) -- 120 chips of 300 at ante 3? see ratio below
    local ratio = G.GAME.chips / G.GAME.blind.chips
    local want = ratio >= 0.25 and '(Active)' or '(Inactive)'
    T.eq(T.joker_display('bplus_mr_bones_plus').reminder, want)
    T.force_behavior('mr_bones', 'plus')
    T.eq(T.joker_display('mr_bones').reminder, want)
    T.force_behavior('bplus_mr_bones_plus', 'base')
    T.eq(T.joker_display('bplus_mr_bones_plus').reminder, want)
end)
