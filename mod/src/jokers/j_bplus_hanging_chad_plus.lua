-- Spec: plannig/specs/jokers/j_hanging_chad.yaml
BPlus.Joker({
    key = 'hanging_chad_plus',
    loc_txt = {
        name = 'Defibrillator',
        text = {
            'Retrigger {C:attention}first{} played',
            'card used in scoring',
            '{C:attention}#1#{} additional times',
        },
    },
    config = { extra = { retriggers = 3 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_hanging_chad', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.retriggers } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card == context.scoring_hand[1] then
            return {
                message = localize('k_again_ex'),
                repetitions = card.ability.extra.retriggers,
                card = card,
            }
        end
    end,
})
