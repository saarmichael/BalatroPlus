-- Spec: plannig/specs/jokers/j_vampire.yaml
BPlus.Joker({
    key = 'vampire_plus',
    loc_txt = {
        name = 'Dracula',
        text = {
            'This Joker gains {X:mult,C:white} X#1# {} Mult',
            'per scoring {C:attention}Enhanced card{} played,',
            'removes card {C:attention}Enhancement',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    config = { extra = { Xmult = 1, Xmult_mod = 0.2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_vampire', state_transfer = { ['x_mult'] = 'extra.Xmult' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_mod, card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local enhanced = {}
            for _, c in ipairs(context.scoring_hand) do
                if c.config.center ~= G.P_CENTERS.c_base and not c.debuff and not c.vampired then
                    enhanced[#enhanced + 1] = c
                    c.vampired = true
                    c:set_ability(G.P_CENTERS.c_base, nil, true)
                    G.E_MANAGER:add_event(Event({ func = function()
                        c:juice_up()
                        c.vampired = nil
                        return true
                    end }))
                end
            end
            if #enhanced > 0 then
                SMODS.scale_card(card, { ref_table = card.ability.extra, ref_value = 'Xmult', scalar_value = 'Xmult_mod',
                    scalar_factor = #enhanced, message_key = 'a_xmult', message_colour = G.C.MULT })
            end
        end
        if context.joker_main and card.ability.extra.Xmult > 1 then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
