local T = BPlus.test

local function ur_suit() return G.GAME.current_round.bplus_ur_card.suit end

local function all_spades()
    for _, c in ipairs(G.playing_cards) do c:change_suit('Spades') end
end

T.test('Ur-Joker: deck of only Spades -> after end of round the suit is Spades', function()
    T.start_run({ jokers = { 'bplus_ancient_plus' }, ante = 3 })
    T.select_blind()
    all_spades()
    G.GAME.current_round.bplus_ur_card.suit = 'Hearts'
    T.win_blind()
    T.eq(ur_suit(), 'Spades')
end)

T.test('Ur-Joker: played card of the current suit -> X1.5; other suit -> nothing', function()
    T.start_run({ jokers = { 'bplus_ancient_plus' }, ante = 3 })
    T.select_blind()
    G.GAME.current_round.bplus_ur_card.suit = 'Hearts'
    T.set_hand({ 'KH', '2C', '3C', '5C', '7D' })
    T.eq(T.play({ 'KH' }).mult, 1 * 1.5)
    G.GAME.current_round.bplus_ur_card.suit = 'Hearts'
    T.set_hand({ 'KC', '2C', '3C', '5C', '7D' })
    T.eq(T.play({ 'KC' }).mult, 1)
end)

T.test("Ur-Joker: vanilla Ancient Joker's suit is unchanged by Ur-Joker's pick", function()
    T.start_run({ jokers = { 'bplus_ancient_plus', 'ancient' }, ante = 3 })
    T.select_blind()
    all_spades()
    G.GAME.current_round.ancient_card.suit = 'Hearts'
    -- vanilla pick always differs from the current suit
    local before = G.GAME.current_round.ancient_card.suit
    T.win_blind()
    T.truthy(G.GAME.current_round.ancient_card.suit ~= before, 'vanilla still rotates to a different suit')
    T.eq(ur_suit(), 'Spades')
end)

T.test('Ur-Joker: vanilla Ancient forced to "+" uses the Ur-Joker suit', function()
    T.start_run({ jokers = { 'ancient' }, ante = 3 })
    T.select_blind()
    T.force_behavior('ancient', 'plus')
    G.GAME.current_round.bplus_ur_card.suit = 'Hearts'
    G.GAME.current_round.ancient_card.suit = 'Clubs'
    T.set_hand({ 'KH', '2C', '3C', '5C', '7D' })
    T.eq(T.play({ 'KH' }).mult, 1 * 1.5)
end)
