-- Spec: plannig/specs/jokers/j_space.yaml
BPlus.Joker({
    key = 'space_plus',
    loc_txt = {
        name = 'Astronaut',
        text = {
            '{C:green}#1# in #2#{} chance to',
            'upgrade level of',
            'played {C:attention}poker hand{}',
        },
    },
    config = { extra = { odds = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_space', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local num, den = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'bplus_astronaut')
        return { vars = { num, den } }
    end,

    calculate = function(self, card, context)
        if context.before and SMODS.pseudorandom_probability(card, 'bplus_astronaut', 1, card.ability.extra.odds) then
            return {
                card = card,
                level_up = true,
                message = localize('k_level_up_ex'),
            }
        end
    end,
})
