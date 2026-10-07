local T = BPlus.test

-- skip Small and Big blind, so the next blind is the Boss
local function to_boss()
    T.skip_blind()
    T.skip_blind()
end

T.test('Chicot+: Small Blind needing 300 -> needs 300 * 0.75 = 225', function()
    T.start_run({ jokers = { 'bplus_chicot_plus' } })
    T.select_blind()
    T.eq(G.GAME.blind.chips, 300 * 0.75)
    T.eq(G.GAME.blind.chip_text, '225')
end)

T.test('Chicot+: Boss Blind: ability disabled and required chips * 0.75', function()
    T.start_run({ jokers = { 'bplus_chicot_plus' }, boss = 'hook' })
    to_boss()
    T.select_blind()
    T.wait_until(function() return G.GAME.blind.disabled end, 'boss disabled')
    T.truthy(G.GAME.blind.disabled)
    T.eq(G.GAME.blind.chips, 600 * 0.75)
end)

T.test('Chicot+: vanilla Chicot still disables the Boss Blind, no chip reduction', function()
    T.start_run({ jokers = { 'chicot' }, boss = 'hook' })
    to_boss()
    T.select_blind()
    T.wait_until(function() return G.GAME.blind.disabled end, 'boss disabled')
    T.eq(G.GAME.blind.chips, 600)
end)

T.test('Chicot+: vanilla Chicot forced to "+" also cuts the chips by 25%', function()
    T.start_run({ jokers = { 'chicot' } })
    T.force_behavior('chicot', 'plus')
    T.select_blind()
    T.eq(G.GAME.blind.chips, 300 * 0.75)
end)

T.test('Chicot+: forced to base (The Rust case) no longer cuts the chips', function()
    T.start_run({ jokers = { 'bplus_chicot_plus' } })
    T.force_behavior(1, 'base')
    T.select_blind()
    T.eq(G.GAME.blind.chips, 300)
end)
