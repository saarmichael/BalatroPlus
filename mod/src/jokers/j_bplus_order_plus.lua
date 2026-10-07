-- Spec: plannig/specs/jokers/j_order.yaml
BPlus.Joker({
    key = 'order_plus',
    loc_txt = {
        name = 'The New Order',
        text = { '{X:mult,C:white} X#1# {} Mult if played', 'hand contains', '{C:attention}#2#{}' },
    },
    config = { extra = { Xmult = 4, type = 'Straight' } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_order', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult, localize(card.ability.extra.type, 'poker_hands') } }
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
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text', colour = G.C.ORANGE },
                { text = ')' },
            },
            calc_function = function(card)
                local value = 1
                local _, poker_hands, _ = JokerDisplay.evaluate_hand()
                if poker_hands[card.ability.extra.type] and next(poker_hands[card.ability.extra.type]) then
                    value = card.ability.extra.Xmult
                end
                card.joker_display_values.x_mult = value
                card.joker_display_values.localized_text = localize(card.ability.extra.type, 'poker_hands')
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main and next(context.poker_hands[card.ability.extra.type]) then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
