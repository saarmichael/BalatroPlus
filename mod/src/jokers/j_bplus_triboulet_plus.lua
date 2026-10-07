-- Spec: plannig/specs/jokers/j_triboulet.yaml
BPlus.Joker({
    key = 'triboulet_plus',
    loc_txt = {
        name = 'Triboulet+',
        text = {
            'Played {C:attention}Kings{}, {C:attention}Queens{} and',
            '{C:attention}Jacks{} each give',
            '{X:mult,C:white} X#1# {} Mult when scored',
        },
    },
    config = { extra = { Xmult = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_triboulet', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = 'X' },
                        { ref_table = 'card.joker_display_values', ref_value = 'x_mult', retrigger_type = 'exp' },
                    },
                },
            },
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text_jack', colour = G.C.ORANGE },
                { text = ',' },
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text_king', colour = G.C.ORANGE },
                { text = ',' },
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text_queen', colour = G.C.ORANGE },
                { text = ')' },
            },
            calc_function = function(card)
                local count = 0
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                if text ~= 'Unknown' then
                    for _, scoring_card in pairs(scoring_hand) do
                        local id = scoring_card:get_id()
                        if id and (id == 11 or id == 12 or id == 13) then
                            count = count + JokerDisplay.calculate_card_triggers(scoring_card, scoring_hand)
                        end
                    end
                end
                card.joker_display_values.x_mult = card.ability.extra.Xmult ^ count
                card.joker_display_values.localized_text_jack = localize('Jack', 'ranks')
                card.joker_display_values.localized_text_king = localize('King', 'ranks')
                card.joker_display_values.localized_text_queen = localize('Queen', 'ranks')
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local id = context.other_card:get_id()
            if id == 11 or id == 12 or id == 13 then
                return { xmult = card.ability.extra.Xmult }
            end
        end
    end,
})
