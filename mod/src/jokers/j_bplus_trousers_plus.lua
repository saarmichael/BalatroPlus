-- Spec: plannig/specs/jokers/j_trousers.yaml
BPlus.Joker({
    key = 'trousers_plus',
    loc_txt = {
        name = 'Three-Piece Suit',
        text = {
            'This Joker gains {C:mult}+#1#{} Mult',
            'if played hand contains',
            'a {C:attention}#2#',
            '{C:inactive}(Currently {C:red}+#3#{C:inactive} Mult)',
        },
    },
    config = { extra = { mult_gain = 4, mult = 0 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_trousers', state_transfer = { ['mult'] = 'extra.mult' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult_gain, localize('Two Pair', 'poker_hands'), card.ability.extra.mult } }
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
        if context.before and not context.blueprint
            and (next(context.poker_hands['Two Pair']) or next(context.poker_hands['Full House'])) then
            SMODS.scale_card(card, {
                ref_table = card.ability.extra,
                ref_value = 'mult',
                scalar_value = 'mult_gain',
                message_colour = G.C.RED,
            })
        end
        if context.joker_main and card.ability.extra.mult > 0 then
            return { mult = card.ability.extra.mult }
        end
    end,
})
