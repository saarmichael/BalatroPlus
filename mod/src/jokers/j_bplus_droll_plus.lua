-- Spec: plannig/specs/jokers/j_droll.yaml
BPlus.Joker({
    key = 'droll_plus',
    loc_txt = {
        name = 'Wry Joker',
        text = { '{C:red}+#1#{} Mult if played', 'hand contains', '{C:attention}#2#{}' },
    },
    config = { extra = { t_mult = 25, type = 'Flush' } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_droll', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.t_mult, localize(card.ability.extra.type, 'poker_hands') } }
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
                local value = 0
                local _, poker_hands, _ = JokerDisplay.evaluate_hand()
                if poker_hands[card.ability.extra.type] and next(poker_hands[card.ability.extra.type]) then
                    value = card.ability.extra.t_mult
                end
                card.joker_display_values.mult = value
                card.joker_display_values.localized_text = localize(card.ability.extra.type, 'poker_hands')
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main and next(context.poker_hands[card.ability.extra.type]) then
            return { mult = card.ability.extra.t_mult }
        end
    end,
})
