local T = BPlus.test

T.test('Cat Burglar: select Blind with 4 hands, 3 (+1 Red Deck) discards -> 4 + 5 = 9 hands, 0 discards', function()
    T.start_run({ jokers = { 'bplus_burglar_plus' } })
    T.eq(G.GAME.current_round.hands_left, 4)
    T.eq(G.GAME.current_round.discards_left, 3 + 1)   -- Red Deck: +1 discard
    T.select_blind()
    T.eq(G.GAME.current_round.hands_left, 4 + 5)
    T.eq(G.GAME.current_round.discards_left, 0)
end)

T.test('Burglar (vanilla): 4 + 3 = 7 hands, 0 discards', function()
    T.start_run({ jokers = { 'burglar' } })
    T.select_blind()
    T.eq(G.GAME.current_round.hands_left, 4 + 3)
    T.eq(G.GAME.current_round.discards_left, 0)
end)

T.test('Cat Burglar: Burglar forced to "+" -> 4 + 5 = 9 hands', function()
    T.start_run({ jokers = { 'burglar' } })
    T.force_behavior('burglar', 'plus')
    T.select_blind()
    T.eq(G.GAME.current_round.hands_left, 4 + 5)
end)

T.test('Cat Burglar: forced to base (The Rust case) -> 4 + 3 = 7 hands, 0 discards', function()
    T.start_run({ jokers = { 'bplus_burglar_plus' } })
    T.force_behavior('bplus_burglar_plus', 'base')
    T.select_blind()
    T.eq(G.GAME.current_round.hands_left, 4 + 3)
    T.eq(G.GAME.current_round.discards_left, 0)
end)
