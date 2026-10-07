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

    joker_display_def = function(JokerDisplay)
        return {
            extra = {
                {
                    { text = '(' },
                    { ref_table = 'card.joker_display_values', ref_value = 'odds' },
                    { text = ')' },
                },
            },
            extra_config = { colour = G.C.GREEN, scale = 0.3 },
            calc_function = function(card)
                local numerator, denominator = SMODS.get_probability_vars(card, 1, card.ability.extra.odds, 'bplus_astronaut')
                card.joker_display_values.odds = localize { type = 'variable', key = 'jdis_odds', vars = { numerator, denominator } }
            end,
        }
    end,

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
