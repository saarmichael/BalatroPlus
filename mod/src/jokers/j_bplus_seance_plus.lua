-- Spec: plannig/specs/jokers/j_seance.yaml
BPlus.Joker({
    key = 'seance_plus',
    loc_txt = {
        name = 'Spirit Board',
        text = {
            'If {C:attention}poker hand{} is a',
            '{C:attention}#1#{}, create',
            '{C:attention}#2#{} random {C:spectral}Spectral{} cards',
            '{C:inactive}(Must have room)',
        },
    },
    config = { extra = { poker_hand = 'Straight Flush', cards = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_seance', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { localize(card.ability.extra.poker_hand, 'poker_hands'), card.ability.extra.cards } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local free = G.consumeables.config.card_limit - (#G.consumeables.cards + G.GAME.consumeable_buffer)
            local n = math.min(card.ability.extra.cards, free)
            if n <= 0 then return end
            if next(context.poker_hands[card.ability.extra.poker_hand]) then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + n
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.0,
                    func = function()
                        for _ = 1, n do
                            local c = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'bplus_spirit_board')
                            c:add_to_deck()
                            G.consumeables:emplace(c)
                            G.GAME.consumeable_buffer = math.max(0, G.GAME.consumeable_buffer - 1)
                        end
                        return true
                    end,
                }))
                return {
                    message = localize('k_plus_spectral'),
                    colour = G.C.SECONDARY_SET.Spectral,
                    card = card,
                }
            end
        end
    end,
})
