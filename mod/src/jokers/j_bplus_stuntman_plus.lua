-- Spec: plannig/specs/jokers/j_stuntman.yaml
BPlus.Joker({
    key = 'stuntman_plus',
    loc_txt = {
        name = 'Daredevil',
        text = {
            '{C:chips}+#1#{} Chips,',
            '{C:attention}-#2#{} hand size',
        },
    },
    config = { extra = { chips = 350, h_size = 1 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_stuntman', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.h_size } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = '+', colour = G.C.CHIPS },
                { ref_table = 'card.ability.extra', ref_value = 'chips', colour = G.C.CHIPS, retrigger_type = 'mult' },
            },
            text_config = { colour = G.C.CHIPS },
        }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return { chips = card.ability.extra.chips }
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.h_size)
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(card.ability.extra.h_size)
    end,
})
