-- Spec: plannig/specs/jokers/j_matador.yaml
BPlus.Joker({
    key = 'matador_plus',
    loc_txt = {
        name = 'Toreador',
        text = { 'Earn {C:money}$#1#{} if played', 'hand triggers the', '{C:attention}Boss Blind{} ability' },
    },
    config = { extra = { dollars = 20 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_matador', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if (context.joker_main or context.debuffed_hand) and G.GAME.blind.triggered then
            return { dollars = card.ability.extra.dollars }
        end
    end,
})
