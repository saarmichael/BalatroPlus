local T = BPlus.test

local BASE = 3 + 1   -- discards per round: 3, +1 from the Red Deck

local function hand_size() return G.hand.config.card_limit end
local function discards() return G.GAME.round_resets.discards end

T.test('Merry Andrew: discards per round 3 + 4 (+1 Red Deck), hand size 8 - 1 = 7 (vanilla: 3 + 3)', function()
    T.start_run({ jokers = { 'bplus_merry_andy_plus' } })
    T.eq(discards(), BASE + 4)
    T.eq(hand_size(), 8 - 1)
end)

T.test('Merry Andrew: upgrade Merry Andy -> discards 3 + 3 becomes 3 + 4, hand size stays 7', function()
    T.start_run({ jokers = { 'merry_andy' } })
    T.eq(discards(), BASE + 3)
    T.eq(hand_size(), 8 - 1)
    T.upgrade('merry_andy')
    T.eq(discards(), BASE + 4)
    T.eq(hand_size(), 8 - 1)
end)

T.test('Merry Andrew: Merry Andy forced to "+" -> 3 + 4 discards, back -> 3 + 3; sold while "+" -> 3 and hand size 8', function()
    T.start_run({ jokers = { 'merry_andy' } })
    T.force_behavior('merry_andy', 'plus')
    T.eq(discards(), BASE + 4)
    T.eq(hand_size(), 8 - 1)
    T.force_behavior('merry_andy', nil)
    T.eq(discards(), BASE + 3)
    T.force_behavior('merry_andy', 'plus')
    T.sell('merry_andy')
    T.eq(discards(), BASE)
    T.eq(hand_size(), 8)
end)

T.test('Merry Andrew: forced to base -> 3 + 3 discards', function()
    T.start_run({ jokers = { 'bplus_merry_andy_plus' } })
    T.force_behavior(1, 'base')
    T.eq(discards(), BASE + 3)
    T.eq(hand_size(), 8 - 1)
end)

T.test('Merry Andrew JokerDisplay: shows nothing, like vanilla (also forced to base / plus)', function()
    T.start_run({ jokers = { 'bplus_merry_andy_plus', 'merry_andy' } })
    T.eq(T.joker_display('bplus_merry_andy_plus').text, '')
    T.force_behavior('merry_andy', 'plus')
    T.eq(T.joker_display('merry_andy').text, '')
    T.force_behavior('bplus_merry_andy_plus', 'base')
    T.eq(T.joker_display('bplus_merry_andy_plus').text, '')
end)
