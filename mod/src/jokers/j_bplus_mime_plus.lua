-- Spec: plannig/specs/jokers/j_mime.yaml
BPlus.Joker({
    key = 'mime_plus',
    loc_txt = {
        name = 'Marcel Marceau',
        text = {
            'Retrigger all card',
            '{C:attention}held in hand{} abilities,',
            '{C:green}#1# in #2#{} chance to',
            'retrigger them again',
        },
    },
    config = { extra = { retriggers = 1, odds = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_mime', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local num, den = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'bplus_marcel_marceau')
        return { vars = { num, den } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.hand
            and (next(context.card_effects[1]) or #context.card_effects > 1) then
            local bonus = SMODS.pseudorandom_probability(card, 'bplus_marcel_marceau', 1, card.ability.extra.odds)
            return {
                message = localize('k_again_ex'),
                repetitions = card.ability.extra.retriggers + (bonus and 1 or 0),
                card = card,
            }
        end
    end,
})
