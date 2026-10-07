-- Spec: plannig/specs/jokers/j_joker.yaml
BPlus.Joker({
    key = 'joker_plus',
    loc_txt = {
        name = 'Joker+',
        text = { '{C:red,s:1.1}+#1#{} Mult' },
    },
    config = { extra = { mult = 20 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_joker', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.mult } }
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
        if context.joker_main then
            return { mult = card.ability.extra.mult }
        end
    end,
})
