-- Spec: plannig/specs/jokers/j_trading.yaml
BPlus.Joker({
    key = 'trading_plus',
    loc_txt = {
        name = 'Chase Card',
        text = {
            'If {C:attention}first discard{} of round',
            'has only {C:attention}1{} card, destroy',
            'it and earn {C:money}$#1#',
        },
    },
    config = { extra = { dollars = 6 } },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_trading', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if context.discard and not context.blueprint
            and G.GAME.current_round.discards_used <= 0 and #context.full_hand == 1 then
            return { dollars = card.ability.extra.dollars, remove = true }
        end
    end,
})
