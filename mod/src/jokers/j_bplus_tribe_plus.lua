-- Spec: plannig/specs/jokers/j_tribe.yaml
BPlus.Joker({
    key = 'tribe_plus',
    loc_txt = {
        name = 'The Nation',
        text = { '{X:mult,C:white} X#1# {} Mult if played', 'hand contains', '{C:attention}#2#{}' },
    },
    config = { extra = { Xmult = 3, type = 'Flush' } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_tribe', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult, localize(card.ability.extra.type, 'poker_hands') } }
    end,

    calculate = function(self, card, context)
        if context.joker_main and next(context.poker_hands[card.ability.extra.type]) then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
