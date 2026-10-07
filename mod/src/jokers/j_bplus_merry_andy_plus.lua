-- Spec: plannig/specs/jokers/j_merry_andy.yaml
BPlus.Joker({
    key = 'merry_andy_plus',
    loc_txt = {
        name = 'Merry Andrew',
        text = { '{C:red}+#1#{} discards', 'each round,', '{C:red}#2#{} hand size' },
    },
    config = { extra = { d_size = 4, h_size = -1 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_merry_andy', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.d_size, card.ability.extra.h_size } }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.d_size
        ease_discard(card.ability.extra.d_size)
        G.hand:change_size(card.ability.extra.h_size)
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.d_size
        ease_discard(-card.ability.extra.d_size)
        G.hand:change_size(-card.ability.extra.h_size)
    end,
})
