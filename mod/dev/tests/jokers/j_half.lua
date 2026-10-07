local T = BPlus.test

local function play(n)
    local all = { '2S', '3H', '7C', '5D', '9D' }
    T.set_hand(all)
    local picked = {}
    for i = 1, n do picked[i] = all[i] end
    return T.play(picked)
end

T.test('Bigger Half Joker: play 4 cards -> +40 Mult', function()
    T.start_run({ jokers = { 'bplus_half_plus' }, hands = 5, ante = 3 })
    T.select_blind()
    T.eq(play(4).mult, 1 + 40)
end)

T.test('Bigger Half Joker: play 5 cards -> +0 Mult', function()
    T.start_run({ jokers = { 'bplus_half_plus' }, hands = 5, ante = 3 })
    T.select_blind()
    T.eq(play(5).mult, 1 + 0)
end)

T.test('Bigger Half Joker: play 1 card -> +40 Mult', function()
    T.start_run({ jokers = { 'bplus_half_plus' }, hands = 5, ante = 3 })
    T.select_blind()
    T.eq(play(1).mult, 1 + 40)
end)

T.test('Bigger Half Joker: vanilla Half Joker (3 cards: +20, 4 cards: +0), forced to "+" gives +40 for 4', function()
    T.start_run({ jokers = { 'half' }, hands = 5, ante = 3 })
    T.select_blind()
    T.eq(play(3).mult, 1 + 20)
    T.eq(play(4).mult, 1 + 0)
    T.force_behavior('half', 'plus')
    T.eq(play(4).mult, 1 + 40)
end)

T.test('Bigger Half Joker JokerDisplay: 4 cards selected -> +40; vanilla forced to "+" shows +40; "+" forced to base shows +0', function()
    T.start_run({ jokers = { 'bplus_half_plus', 'half' }, hands = 5, ante = 3 })
    T.select_blind()
    T.set_hand({ '2S', '3H', '7C', '5D', '9D' })
    local function sel(n)
        local h = {}
        for i = 1, n do h[i] = G.hand.cards[i] end
        JokerDisplay.current_hand = h -- what JokerDisplay derives from the highlighted cards
    end
    sel(4)
    T.eq(T.joker_display('bplus_half_plus').text, '+40')
    T.eq(T.joker_display('half').text, '+0') -- vanilla: 3 cards or fewer
    T.force_behavior('half', 'plus')
    T.eq(T.joker_display('half').text, '+40')
    T.force_behavior('bplus_half_plus', 'base')
    T.eq(T.joker_display('bplus_half_plus').text, '+0')
    sel(3)
    T.eq(T.joker_display('bplus_half_plus').text, '+20')
end)
