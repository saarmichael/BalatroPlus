-- Spec: plannig/specs/jokers/j_juggler.yaml
BPlus.Joker({
    key = 'juggler_plus',
    loc_txt = {
        name = 'Knife Juggler',
        text = { '{C:attention}+#1#{} hand size' },
    },
    config = { extra = { h_size = 2 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_juggler', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.h_size } }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(card.ability.extra.h_size)
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.h_size)
    end,
})
