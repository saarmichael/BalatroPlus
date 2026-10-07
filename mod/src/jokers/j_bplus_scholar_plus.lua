-- Spec: plannig/specs/jokers/j_scholar.yaml
BPlus.Joker({
    key = 'scholar_plus',
    loc_txt = {
        name = 'Professor',
        text = {
            'Played {C:attention}Aces{}',
            'give {C:chips}+#1#{} Chips',
            'and {C:mult}+#2#{} Mult',
            'when scored',
        },
    },
    config = { extra = { chips = 40, mult = 10 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_scholar', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.mult } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+', colour = G.C.CHIPS },
                { ref_table = 'card.joker_display_values', ref_value = 'chips', colour = G.C.CHIPS, retrigger_type = 'mult' },
                { text = ' +', colour = G.C.MULT },
                { ref_table = 'card.joker_display_values', ref_value = 'mult', colour = G.C.MULT, retrigger_type = 'mult' },
            },
            reminder_text = {
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text' },
            },
            calc_function = function(card)
                local chips, mult = 0, 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                if text ~= 'Unknown' then
                    for _, scoring_card in pairs(scoring_hand) do
                        if scoring_card:get_id() and scoring_card:get_id() == 14 then
                            local retriggers = JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                            chips = chips + card.ability.extra.chips * retriggers
                            mult = mult + card.ability.extra.mult * retriggers
                        end
                    end
                end
                card.joker_display_values.chips = chips
                card.joker_display_values.mult = mult
                card.joker_display_values.localized_text = '(' .. localize('k_aces') .. ')'
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:get_id() == 14 then
            return { chips = card.ability.extra.chips, mult = card.ability.extra.mult }
        end
    end,
})
