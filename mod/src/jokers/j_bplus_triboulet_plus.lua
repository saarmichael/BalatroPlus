-- Spec: plannig/specs/jokers/j_triboulet.yaml
BPlus.Joker({
    key = 'triboulet_plus',
    loc_txt = {
        name = 'Triboulet+',
        text = {
            'Played {C:attention}Kings{}, {C:attention}Queens{} and',
            '{C:attention}Jacks{} each give',
            '{X:mult,C:white} X#1# {} Mult when scored',
        },
    },
    config = { extra = { Xmult = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_triboulet', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            local id = context.other_card:get_id()
            if id == 11 or id == 12 or id == 13 then
                return { xmult = card.ability.extra.Xmult }
            end
        end
    end,
})
