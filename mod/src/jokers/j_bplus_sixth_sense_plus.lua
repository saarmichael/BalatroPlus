-- Spec: plannig/specs/jokers/j_sixth_sense.yaml
BPlus.Joker({
    key = 'sixth_sense_plus',
    loc_txt = {
        name = 'Second Sixth Sense',
        text = {
            'If {C:attention}first hand{} of round is',
            'a single {C:attention}6{}, destroy it and',
            'create {C:attention}#1#{} {C:spectral}Spectral{} cards',
            '{C:inactive}(Must have room)',
        },
    },
    config = { extra = { cards = 2 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_sixth_sense', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.cards } }
    end,

    calculate = function(self, card, context)
        if context.destroying_card and not context.blueprint
            and #context.full_hand == 1 and context.full_hand[1]:get_id() == 6
            and not context.full_hand[1].sixth_sense
            and G.GAME.current_round.hands_played == 0 then
            context.full_hand[1].sixth_sense = true
            local free = G.consumeables.config.card_limit - (#G.consumeables.cards + G.GAME.consumeable_buffer)
            local n = math.min(card.ability.extra.cards, free)
            if n > 0 then
                G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + n
                G.E_MANAGER:add_event(Event({
                    trigger = 'before',
                    delay = 0.0,
                    func = function()
                        for _ = 1, n do
                            local c = create_card('Spectral', G.consumeables, nil, nil, nil, nil, nil, 'bplus_second_sixth_sense')
                            c:add_to_deck()
                            G.consumeables:emplace(c)
                            G.GAME.consumeable_buffer = math.max(0, G.GAME.consumeable_buffer - 1)
                        end
                        return true
                    end,
                }))
                card_eval_status_text(card, 'extra', nil, nil, nil,
                    { message = localize('k_plus_spectral'), colour = G.C.SECONDARY_SET.Spectral })
            end
            return { remove = true }
        end
    end,
})
