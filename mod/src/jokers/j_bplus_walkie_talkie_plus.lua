-- Spec: plannig/specs/jokers/j_walkie_talkie.yaml
BPlus.Joker({
    key = 'walkie_talkie_plus',
    loc_txt = {
        name = 'Ham Radio',
        text = {
            'Each played {C:attention}10{} gives',
            '{C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult,',
            'each played {C:attention}4{} gives',
            '{C:chips}+#3#{} Chips and {C:mult}+#4#{} Mult',
            'when scored',
        },
    },
    config = { extra = { ten_chips = 100, ten_mult = 4, four_chips = 10, four_mult = 40 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_walkie_talkie', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.ten_chips, card.ability.extra.ten_mult, card.ability.extra.four_chips, card.ability.extra.four_mult } }
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
                { text = '(10,4)' },
            },
            calc_function = function(card)
                local chips, mult = 0, 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                if text ~= 'Unknown' then
                    for _, scoring_card in pairs(scoring_hand) do
                        if scoring_card:get_id() == 10 then
                            local retriggers = JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                            chips = chips + card.ability.extra.ten_chips * retriggers
                            mult = mult + card.ability.extra.ten_mult * retriggers
                        elseif scoring_card:get_id() == 4 then
                            local retriggers = JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                            chips = chips + card.ability.extra.four_chips * retriggers
                            mult = mult + card.ability.extra.four_mult * retriggers
                        end
                    end
                end
                card.joker_display_values.chips = chips
                card.joker_display_values.mult = mult
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            if context.other_card:get_id() == 10 then
                return { chips = card.ability.extra.ten_chips, mult = card.ability.extra.ten_mult }
            elseif context.other_card:get_id() == 4 then
                return { chips = card.ability.extra.four_chips, mult = card.ability.extra.four_mult }
            end
        end
    end,
})
