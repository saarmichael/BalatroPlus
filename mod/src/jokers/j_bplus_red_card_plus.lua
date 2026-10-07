-- Spec: plannig/specs/jokers/j_red_card.yaml
BPlus.Joker({
    key = 'red_card_plus',
    loc_txt = {
        name = 'Crimson Card',
        text = {
            'This Joker gains',
            '{C:red}+#1#{} Mult when any',
            '{C:attention}Booster Pack{} is skipped',
            '{C:inactive}(Currently {C:red}+#2#{C:inactive} Mult)',
        },
    },
    config = { extra = { mult_gain = 5, mult = 0 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_red_card', state_transfer = { ['mult'] = 'extra.mult' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_gain, card.ability.extra.mult } }
    end,

    calculate = function(self, card, context)
        if context.skipping_booster and not context.blueprint then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = 'mult',
                scalar_value = 'mult_gain',
                message_key = 'a_mult',
                message_colour = G.C.RED,
                message_delay = 0.45,
            })
        end
        if context.joker_main and card.ability.extra.mult > 0 then
            return { mult = card.ability.extra.mult }
        end
    end,
})
