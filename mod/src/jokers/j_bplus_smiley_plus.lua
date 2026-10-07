-- Spec: plannig/specs/jokers/j_smiley.yaml
BPlus.Joker({
    key = 'smiley_plus',
    loc_txt = {
        name = 'Hugging Face',
        text = {
            'Played {C:attention}face{} cards',
            'give {C:mult}+#1#{} Mult',
            'when scored',
        },
    },
    config = { extra = { mult = 10 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_smiley', state_transfer = {}, carpenter_compat = true },

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
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text', colour = G.C.ORANGE },
                { text = ')' },
            },
            calc_function = function(card)
                local mult = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                if text ~= 'Unknown' then
                    for _, scoring_card in pairs(scoring_hand) do
                        if scoring_card:is_face() then
                            mult = mult + card.ability.extra.mult * JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                        end
                    end
                end
                card.joker_display_values.mult = mult
                card.joker_display_values.localized_text = localize('k_face_cards')
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_face() then
            return { mult = card.ability.extra.mult }
        end
    end,
})
