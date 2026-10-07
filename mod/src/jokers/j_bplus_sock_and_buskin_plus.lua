-- Spec: plannig/specs/jokers/j_sock_and_buskin.yaml
BPlus.Joker({
    key = 'sock_and_buskin_plus',
    loc_txt = {
        name = 'Melpomene and Thalia',
        text = {
            'Retrigger all',
            'played {C:attention}face{} cards,',
            '{C:green}#1# in #2#{} chance to',
            'retrigger them again',
        },
    },
    config = { extra = { retriggers = 1, odds = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_sock_and_buskin', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local num, den = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'bplus_melpomene_and_thalia')
        return { vars = { num, den } }
    end,

    calculate = function(self, card, context)
        if context.repetition and context.cardarea == G.play and context.other_card:is_face() then
            local bonus = SMODS.pseudorandom_probability(card, 'bplus_melpomene_and_thalia', 1, card.ability.extra.odds)
            return {
                message = localize('k_again_ex'),
                repetitions = card.ability.extra.retriggers + (bonus and 1 or 0),
                card = card,
            }
        end
    end,
})
