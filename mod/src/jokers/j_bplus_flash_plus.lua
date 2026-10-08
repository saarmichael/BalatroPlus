-- Spec: plannig/specs/jokers/j_flash.yaml
BPlus.Joker({
    key = 'flash_plus',
    loc_txt = {
        name = 'Cheat Sheet',
        text = {
            'This Joker gains {C:mult}+#1#{} Mult',
            'per {C:attention}reroll{} in the shop',
            '{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult)',
        },
    },
    config = { extra = { mult_gain = 4, mult = 0 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_flash', state_transfer = { ['mult'] = 'extra.mult' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_gain, card.ability.extra.mult } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+' },
                { ref_table = 'card.ability.extra', ref_value = 'mult', retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.MULT },
        }
    end,

    calculate = function(self, card, context)
        if context.reroll_shop and not context.blueprint then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = 'mult',
                scalar_value = 'mult_gain',
                message_key = 'a_mult',
                message_colour = G.C.RED,
            })
        end
        if context.joker_main and card.ability.extra.mult > 0 then
            return { mult = card.ability.extra.mult }
        end
    end,
})
