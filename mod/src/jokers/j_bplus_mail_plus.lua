-- Spec: plannig/specs/jokers/j_mail.yaml
BPlus.Joker({
    key = 'mail_plus',
    loc_txt = {
        name = 'Cashback',
        text = {
            'Earn {C:money}$#1#{} for each',
            'discarded {C:attention}#2#{}, rank',
            'changes every round',
        },
    },
    config = { extra = { dollars = 6 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_mail', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local mail = G.GAME and G.GAME.current_round and G.GAME.current_round.mail_card
        return { vars = { card.ability.extra.dollars, localize(mail and mail.rank or 'Ace', 'ranks') } }
    end,

    calculate = function(self, card, context)
        if context.discard and not context.other_card.debuff
            and context.other_card:get_id() == G.GAME.current_round.mail_card.id then
            return { dollars = card.ability.extra.dollars }
        end
    end,
})
