-- Spec: plannig/specs/jokers/j_drunkard.yaml
BPlus.Joker({
    key = 'drunkard_plus',
    loc_txt = {
        name = 'Barfly',
        text = { '{C:red}+#1#{} discards', 'each round' },
    },
    config = { extra = { d_size = 2 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_drunkard', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.d_size } }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.d_size
        ease_discard(card.ability.extra.d_size)
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.d_size
        ease_discard(-card.ability.extra.d_size)
    end,
})
