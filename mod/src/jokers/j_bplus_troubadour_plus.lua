-- Spec: plannig/specs/jokers/j_troubadour.yaml
BPlus.Joker({
    key = 'troubadour_plus',
    loc_txt = {
        name = 'Virtuoso',
        text = { '{C:attention}+#1#{} hand size,', '{C:blue}-#2#{} hand each round' },
    },
    config = { extra = { h_size = 3, h_plays = -1 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_troubadour', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.h_size, -card.ability.extra.h_plays } }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.hand:change_size(card.ability.extra.h_size)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.h_plays
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.hand:change_size(-card.ability.extra.h_size)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.h_plays
    end,
})
