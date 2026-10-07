-- Spec: plannig/specs/jokers/j_bloodstone.yaml
BPlus.Joker({
    key = 'bloodstone_plus',
    loc_txt = {
        name = 'Fire Opal',
        text = {
            '{C:green}#1# in #2#{} chance for',
            'played cards with',
            '{C:hearts}Heart{} suit to give',
            '{X:mult,C:white} X#3# {} Mult when scored',
        },
    },
    config = { extra = { num = 2, odds = 3, Xmult = 1.5 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_bloodstone', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        local a, b = SMODS.get_probability_vars(card, card.ability.extra.num, card.ability.extra.odds, 'bplus_fire_opal')
        return { vars = { a, b, card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play and context.other_card:is_suit('Hearts')
            and SMODS.pseudorandom_probability(card, 'bplus_fire_opal', card.ability.extra.num, card.ability.extra.odds) then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
