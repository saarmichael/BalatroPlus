-- Spec: plannig/specs/jokers/j_ticket.yaml
BPlus.Joker({
    key = 'ticket_plus',
    loc_txt = {
        name = 'Goldbars',
        text = { 'Played {C:attention}Gold{} cards', 'earn {C:money}$#1#{} when scored' },
    },
    config = { extra = { dollars = 5 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_ticket', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
        return { vars = { card.ability.extra.dollars } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+$' },
                { ref_table = 'card.joker_display_values', ref_value = 'dollars', retrigger_type = 'mult' },
            },
        text_config = { colour = G.C.GOLD },
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text', colour = G.C.ORANGE, retrigger_type = 'mult' },
                { text = ')' },
            },
            calc_function = function(card)
                local dollars = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                if text ~= 'Unknown' then
                    for _, sc in pairs(scoring_hand) do
                        if SMODS.has_enhancement(sc, 'm_gold') then
                            dollars = dollars + card.ability.extra.dollars * JokerDisplay.calculate_card_triggers(sc, scoring_hand)
                        end
                    end
                end
                card.joker_display_values.dollars = dollars
                card.joker_display_values.localized_text = localize('k_gold')
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play
            and SMODS.has_enhancement(context.other_card, 'm_gold') then
            return { dollars = card.ability.extra.dollars }
        end
    end,
})
