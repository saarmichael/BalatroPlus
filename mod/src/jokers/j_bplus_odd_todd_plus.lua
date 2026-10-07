-- Spec: plannig/specs/jokers/j_odd_todd.yaml
BPlus.Joker({
    key = 'odd_todd_plus',
    loc_txt = {
        name = 'Todd the Odd',
        text = {
            'Played cards with',
            '{C:attention}odd{} rank give',
            '{C:chips}+#1#{} Chips when scored',
            '{C:inactive}(A, 9, 7, 5, 3)',
        },
    },
    config = { extra = { chips = 67 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_odd_todd', state_transfer = {}, carpenter_compat = true },

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
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text' },
            },
            calc_function = function(card)
                local chips = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                if text ~= 'Unknown' then
                    for _, scoring_card in pairs(scoring_hand) do
                        if scoring_card:get_id() and ((scoring_card:get_id() <= 10 and scoring_card:get_id() >= 0 and scoring_card:get_id() % 2 == 1) or scoring_card:get_id() == 14) then
                            chips = chips + card.ability.extra.chips * JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                        end
                    end
                end
                card.joker_display_values.chips = chips
                card.joker_display_values.localized_text = '(' .. localize('Ace', 'ranks') .. ',9,7,5,3)'
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and ((context.other_card:get_id() <= 10 and context.other_card:get_id() >= 0 and context.other_card:get_id() % 2 == 1) or context.other_card:get_id() == 14) then
            return { chips = card.ability.extra.chips }
        end
    end,
})
