local T = BPlus.test

local function hand_size() return G.hand.config.card_limit end
local function hands() return G.GAME.round_resets.hands end

T.test('Virtuoso: hand size 8 + 3 = 11, hands per round 4 - 1 = 3 (vanilla: hand size 10)', function()
    T.start_run({ jokers = { 'bplus_troubadour_plus' } })
    T.eq(hand_size(), 8 + 3)
    T.eq(hands(), 4 - 1)
    T.select_blind()
    T.eq(G.GAME.current_round.hands_left, 4 - 1)
end)

T.test('Virtuoso: upgrade Troubadour -> hand size 10 becomes 11, hands stay 3', function()
    T.start_run({ jokers = { 'troubadour' } })
    T.eq(hand_size(), 8 + 2)
    T.eq(hands(), 4 - 1)
    T.upgrade('troubadour')
    T.eq(hand_size(), 8 + 3)
    T.eq(hands(), 4 - 1)
end)

T.test('Virtuoso: Troubadour forced to "+" -> 11, back -> 10; sold while "+" -> 8 and 4 hands', function()
    T.start_run({ jokers = { 'troubadour' } })
    T.force_behavior('troubadour', 'plus')
    T.eq(hand_size(), 8 + 3)
    T.force_behavior('troubadour', nil)
    T.eq(hand_size(), 8 + 2)
    T.force_behavior('troubadour', 'plus')
    T.sell('troubadour')
    T.eq(hand_size(), 8)
    T.eq(hands(), 4)
end)

T.test('Virtuoso: forced to base -> 10', function()
    T.start_run({ jokers = { 'bplus_troubadour_plus' } })
    T.force_behavior(1, 'base')
    T.eq(hand_size(), 8 + 2)
    T.eq(hands(), 4 - 1)
end)

T.test('Virtuoso JokerDisplay: shows nothing, like vanilla (also forced to base / plus)', function()
    T.start_run({ jokers = { 'bplus_troubadour_plus', 'troubadour' } })
    T.eq(T.joker_display('bplus_troubadour_plus').text, '')
    T.force_behavior('troubadour', 'plus')
    T.eq(T.joker_display('troubadour').text, '')
    T.force_behavior('bplus_troubadour_plus', 'base')
    T.eq(T.joker_display('bplus_troubadour_plus').text, '')
end)
