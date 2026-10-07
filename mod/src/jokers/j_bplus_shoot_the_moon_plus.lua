-- Spec: plannig/specs/jokers/j_shoot_the_moon.yaml
BPlus.Joker({
    key = 'shoot_the_moon_plus',
    loc_txt = {
        name = 'Moonshot',
        text = {
            'Each {C:attention}Queen{}',
            'held in hand',
            'gives {C:mult}+#1#{} Mult',
        },
    },
    config = { extra = { mult = 21 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_shoot_the_moon', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'mult', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.MULT },
            calc_function = function(card)
                local playing_hand = next(G.play.cards)
                local mult = 0
                for _, playing_card in ipairs(G.hand.cards) do
                    if playing_hand or not playing_card.highlighted then
                        if playing_card.facing and not (playing_card.facing == 'back') and not playing_card.debuff and playing_card:get_id() == 12 then
                            mult = mult + card.ability.extra.mult * JokerDisplay.calculate_card_triggers(playing_card, nil, true)
                        end
                    end
                end
                card.joker_display_values.mult = mult
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and context.other_card:get_id() == 12 then
            if context.other_card.debuff then
                return { message = localize('k_debuffed'), colour = G.C.RED }
            end
            return { mult = card.ability.extra.mult }
        end
    end,
})
