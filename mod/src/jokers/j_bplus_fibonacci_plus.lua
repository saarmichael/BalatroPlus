-- Spec: plannig/specs/jokers/j_fibonacci.yaml
BPlus.Joker({
    key = 'fibonacci_plus',
    loc_txt = {
        name = 'Perfect Storm',
        text = {
            'Each played {C:attention}Ace{},',
            '{C:attention}2{}, {C:attention}3{}, {C:attention}5{}, or {C:attention}8{} gives',
            '{C:mult}+#1#{} Mult when scored',
        },
    },
    config = { extra = { mult = 13 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_fibonacci', state_transfer = {}, carpenter_compat = true },

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
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text' },
            },
            calc_function = function(card)
                local mult = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                if text ~= 'Unknown' then
                    for _, scoring_card in pairs(scoring_hand) do
                        if scoring_card:get_id() and (scoring_card:get_id() == 2 or scoring_card:get_id() == 3 or scoring_card:get_id() == 5 or scoring_card:get_id() == 8 or scoring_card:get_id() == 14) then
                            mult = mult + card.ability.extra.mult * JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                        end
                    end
                end
                card.joker_display_values.mult = mult
                card.joker_display_values.localized_text = '(' .. localize('Ace', 'ranks') .. ',2,3,5,8)'
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and (context.other_card:get_id() == 14 or context.other_card:get_id() == 2 or context.other_card:get_id() == 3 or context.other_card:get_id() == 5 or context.other_card:get_id() == 8) then
            return { mult = card.ability.extra.mult }
        end
    end,
})
