-- Spec: plannig/specs/jokers/j_card_sharp.yaml
BPlus.Joker({
    key = 'card_sharp_plus',
    loc_txt = {
        name = 'Card Shark',
        text = {
            '{X:mult,C:white} X#1# {} Mult if played',
            '{C:attention}poker hand{} has already',
            'been played this round',
        },
    },
    config = { extra = { Xmult = 4 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_card_sharp', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local hand = G.GAME.hands[context.scoring_name]
            if hand and hand.played_this_round > 1 then
                return { xmult = card.ability.extra.Xmult }
            end
        end
    end,
})
