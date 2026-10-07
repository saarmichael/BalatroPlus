-- Spec: plannig/specs/jokers/j_scary_face.yaml
BPlus.Joker({
    key = 'scary_face_plus',
    loc_txt = {
        name = 'Nightmare',
        text = {
            'Played {C:attention}face{} cards',
            'give {C:chips}+#1#{} Chips',
            'when scored',
        },
    },
    config = { extra = { chips = 60 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_scary_face', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'chips', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.CHIPS },
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text', colour = G.C.ORANGE },
                { text = ')' },
            },
            calc_function = function(card)
                local chips = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                if text ~= 'Unknown' then
                    for _, scoring_card in pairs(scoring_hand) do
                        if scoring_card:is_face() then
                            chips = chips + card.ability.extra.chips * JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                        end
                    end
                end
                card.joker_display_values.chips = chips
                card.joker_display_values.localized_text = localize('k_face_cards')
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_face() then
            return { chips = card.ability.extra.chips }
        end
    end,
})
