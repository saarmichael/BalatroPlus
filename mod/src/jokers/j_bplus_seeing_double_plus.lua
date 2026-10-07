-- Spec: plannig/specs/jokers/j_seeing_double.yaml
BPlus.Joker({
    key = 'seeing_double_plus',
    loc_txt = {
        name = 'Chameleon',
        text = {
            '{X:mult,C:white} X#1# {} Mult if played',
            'hand has a scoring',
            '{C:clubs}Club{} card and a scoring',
            'card of any other {C:attention}suit',
        },
    },
    config = { extra = { Xmult = 3 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_seeing_double', state_transfer = {}, carpenter_compat = true },

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
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text_clubs', colour = lighten(G.C.SUITS['Clubs'], 0.35) },
                { text = '+' },
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text_other', colour = G.C.ORANGE },
                { text = ')' },
            },
            calc_function = function(card)
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                local active = text ~= 'Unknown' and SMODS.seeing_double_check(scoring_hand, 'Clubs')
                card.joker_display_values.x_mult = active and card.ability.extra.Xmult or 1
                card.joker_display_values.localized_text_clubs = localize('Clubs', 'suits_singular')
                card.joker_display_values.localized_text_other = localize('k_other')
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main and SMODS.seeing_double_check(context.scoring_hand, 'Clubs') then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
