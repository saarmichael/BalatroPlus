local T = BPlus.test

local BASE = 3 + 1   -- discards per round: 3, +1 from the Red Deck

local function discards() return G.GAME.round_resets.discards end

T.test('Barfly: discards per round 3 + 2 (+1 Red Deck) (vanilla: 3 + 1)', function()
    T.start_run({ jokers = { 'bplus_drunkard_plus' } })
    T.eq(discards(), BASE + 2)
    T.select_blind()
    T.eq(G.GAME.current_round.discards_left, BASE + 2)
end)

T.test('Barfly: sell it -> back to the base 3 (+1 Red Deck)', function()
    T.start_run({ jokers = { 'bplus_drunkard_plus' } })
    T.sell('bplus_drunkard_plus')
    T.eq(discards(), BASE)
end)

T.test('Barfly: upgrade Drunkard -> 3 + 1 becomes 3 + 2', function()
    T.start_run({ jokers = { 'drunkard' } })
    T.eq(discards(), BASE + 1)
    T.upgrade('drunkard')
    T.eq(discards(), BASE + 2)
end)

T.test('Barfly: Drunkard forced to "+" -> 3 + 2, back -> 3 + 1; sold while "+" -> base', function()
    T.start_run({ jokers = { 'drunkard' } })
    T.force_behavior('drunkard', 'plus')
    T.eq(discards(), BASE + 2)
    T.force_behavior('drunkard', nil)
    T.eq(discards(), BASE + 1)
    T.force_behavior('drunkard', 'plus')
    T.sell('drunkard')
    T.eq(discards(), BASE)
end)

T.test('Barfly: forced to base -> 3 + 1', function()
    T.start_run({ jokers = { 'bplus_drunkard_plus' } })
    T.force_behavior(1, 'base')
    T.eq(discards(), BASE + 1)
end)

T.test('Barfly JokerDisplay: shows nothing, like vanilla (also forced to base / plus)', function()
    T.start_run({ jokers = { 'bplus_drunkard_plus', 'drunkard' } })
    T.eq(T.joker_display('bplus_drunkard_plus').text, '')
    T.force_behavior('drunkard', 'plus')
    T.eq(T.joker_display('drunkard').text, '')
    T.force_behavior('bplus_drunkard_plus', 'base')
    T.eq(T.joker_display('bplus_drunkard_plus').text, '')
end)
