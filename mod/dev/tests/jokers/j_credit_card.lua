local T = BPlus.test

-- 7 after the first cash-out (blind 3 + 4 unused hands); each Greedy-type joker costs 5.
local function buy_two()
    T.to_shop()
    T.buy('greedy_joker'); T.buy('lusty_joker')
end

T.test('Sam Altman: with $0, buy $5 jokers below $0, limit -$100 (vanilla: -$20)', function()
    T.start_run({ dollars = 0, jokers = { 'bplus_credit_card_plus' },
        shop_queue = { 'greedy_joker', 'lusty_joker' } })
    T.eq(G.GAME.bankrupt_at, -100)
    buy_two()
    T.eq(G.GAME.dollars, 3 + 4 - 5 - 5)
end)

T.test('Sam Altman: sell it -> debt limit back to $0', function()
    T.start_run({ jokers = { 'bplus_credit_card_plus' } })
    T.eq(G.GAME.bankrupt_at, -100)
    T.sell('bplus_credit_card_plus')
    T.eq(G.GAME.bankrupt_at, 0)
end)

T.test('Sam Altman: vanilla Credit Card limit is -$20', function()
    T.start_run({ jokers = { 'credit_card' } })
    T.eq(G.GAME.bankrupt_at, -20)
end)

T.test('Sam Altman: upgrade Credit Card -> limit goes from -$20 to -$100, not -$120', function()
    T.start_run({ jokers = { 'credit_card' } })
    T.eq(G.GAME.bankrupt_at, -20)
    T.upgrade('credit_card')
    T.eq(G.GAME.bankrupt_at, -100)
end)

T.test('Sam Altman: Credit Card forced to "+" -> -$100, back -> -$20, sold while "+" -> $0', function()
    T.start_run({ jokers = { 'credit_card' } })
    T.force_behavior('credit_card', 'plus')
    T.eq(G.GAME.bankrupt_at, -100)
    T.force_behavior('credit_card', nil)
    T.eq(G.GAME.bankrupt_at, -20)
    T.force_behavior('credit_card', 'plus')
    T.sell('credit_card')
    T.eq(G.GAME.bankrupt_at, 0)
end)
