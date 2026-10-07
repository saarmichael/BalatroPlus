-- Spec: plannig/specs/jokers/j_baseball.yaml
BPlus.Joker({
    key = 'baseball_plus',
    loc_txt = {
        name = 'Slabbed Baseball Card',
        text = {
            '{C:green}Uncommon{} Jokers',
            'each give {X:mult,C:white} X#1# {} Mult',
        },
    },
    config = { extra = { Xmult = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_baseball', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.other_joker and context.other_joker ~= card and context.other_joker:is_rarity('Uncommon') then
            G.E_MANAGER:add_event(Event({ func = function()
                context.other_joker:juice_up(0.5, 0.5)
                return true
            end }))
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
