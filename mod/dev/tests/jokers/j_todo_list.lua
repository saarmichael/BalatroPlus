local T = BPlus.test

local FULL_HOUSE = { 'KS', 'KH', 'KD', '5C', '5D' }
local PAIR = { 'KS', 'KH', '9D', '5C', '2D' }

local function listed(card, hand) card.ability.extra.poker_hand = hand end

T.test('Wishlist: listed hand Pair, play a Full House -> +$5 (vanilla To Do List: $0)', function()
    T.start_run({ dollars = 0, ante = 3, jokers = { 'bplus_todo_list_plus' } })
    listed(T.joker(1), 'Pair')
    T.select_blind()
    T.set_hand(FULL_HOUSE)
    local r = T.play(FULL_HOUSE)
    T.eq(r.hand, 'Full House')
    T.eq(r.dollars, 5)
end)

T.test('Wishlist: vanilla To Do List listing Pair pays $0 on a Full House', function()
    T.start_run({ dollars = 0, ante = 3, jokers = { 'todo_list' } })
    T.joker(1).ability.to_do_poker_hand = 'Pair'
    T.select_blind()
    T.set_hand(FULL_HOUSE)
    T.eq(T.play(FULL_HOUSE).dollars, 0)
end)

T.test('Wishlist: listed hand Pair, play a Pair -> +$5', function()
    T.start_run({ dollars = 0, ante = 3, jokers = { 'bplus_todo_list_plus' } })
    listed(T.joker(1), 'Pair')
    T.select_blind()
    T.set_hand(PAIR)
    T.eq(T.play(PAIR).dollars, 5)
end)

T.test('Wishlist: listed hand Flush, play a Pair -> $0', function()
    T.start_run({ dollars = 0, ante = 3, jokers = { 'bplus_todo_list_plus' } })
    listed(T.joker(1), 'Flush')
    T.select_blind()
    T.set_hand(PAIR)
    T.eq(T.play(PAIR).dollars, 0)
end)

T.test('Wishlist: upgrade To Do List listing Two Pair -> Wishlist lists Two Pair', function()
    T.start_run({ jokers = { 'todo_list' } })
    T.joker(1).ability.to_do_poker_hand = 'Two Pair'
    local card = T.upgrade('todo_list')
    T.eq(card.ability.extra.poker_hand, 'Two Pair')
end)

T.test('Wishlist: To Do List forced to "+" listing Pair pays $5 on a Full House', function()
    T.start_run({ dollars = 0, ante = 3, jokers = { 'todo_list' } })
    T.joker(1).ability.to_do_poker_hand = 'Pair'
    T.force_behavior('todo_list', 'plus')
    T.select_blind()
    T.set_hand(FULL_HOUSE)
    T.eq(T.play(FULL_HOUSE).dollars, 5)
end)

T.test('Wishlist: listed hand changes at end of round', function()
    T.start_run({ ante = 3, jokers = { 'bplus_todo_list_plus' } })
    listed(T.joker(1), 'Pair')
    T.select_blind()
    T.win_blind()
    T.truthy(T.joker(1).ability.extra.poker_hand ~= 'Pair', 'hand changed')
end)
