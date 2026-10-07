-- Spec: plannig/specs/jokers/j_credit_card.yaml
BPlus.Joker({
    key = 'credit_card_plus',
    loc_txt = {
        name = 'Sam Altman',
        text = { 'Go up to', '{C:red}-$#1#{} in debt' },
    },
    config = { extra = { debt = 100 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_credit_card', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.debt } }
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.bankrupt_at = G.GAME.bankrupt_at - card.ability.extra.debt
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.GAME.bankrupt_at = G.GAME.bankrupt_at + card.ability.extra.debt
    end,
})
