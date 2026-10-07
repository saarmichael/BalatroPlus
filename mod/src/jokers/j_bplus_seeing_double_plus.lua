-- Spec: plannig/specs/jokers/j_seeing_double.yaml
BPlus.Joker({
    key = 'seeing_double_plus',
    loc_txt = {
        name = 'Chameleon',
        text = {
            '{X:mult,C:white} X#1# {} Mult if played',
            'hand has a scoring',
            '{C:clubs}Club{} card and a scoring',
            'card of any other {C:attention}suit',
        },
    },
    config = { extra = { Xmult = 3 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_seeing_double', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.joker_main and SMODS.seeing_double_check(context.scoring_hand, 'Clubs') then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
