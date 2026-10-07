-- Spec: plannig/specs/jokers/j_yorick.yaml
BPlus.Joker({
    key = 'yorick_plus',
    loc_txt = {
        name = 'Yorick+',
        text = {
            'This Joker gains',
            '{X:mult,C:white} X#1# {} Mult every {C:attention}#2#{C:inactive} [#3#]{}',
            'cards discarded',
            '{C:inactive}(Currently {X:mult,C:white} X#4# {C:inactive} Mult)',
        },
    },
    config = { extra = { Xmult = 1, Xmult_mod = 1, discards = 14, discards_left = 14 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = {
        vanilla_key = 'j_yorick',
        state_transfer = { ['x_mult'] = 'extra.Xmult', ['yorick_discards'] = 'extra.discards_left' },
        carpenter_compat = true,
    },

    loc_vars = function(self, info_queue, card)
        local e = card.ability.extra
        return { vars = { e.Xmult_mod, e.discards, e.discards_left, e.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.discard and not context.blueprint then
            local e = card.ability.extra
            -- the counter may come from another period (upgrade, Carpenter): fit it to ours
            e.discards_left = ((e.discards_left - 1) % e.discards) + 1
            if e.discards_left <= 1 then
                e.discards_left = e.discards
                SMODS.scale_card(card, {
                    ref_table = e,
                    ref_value = 'Xmult',
                    scalar_value = 'Xmult_mod',
                    message_key = 'a_xmult',
                    message_colour = G.C.RED,
                    message_delay = 0.2,
                })
            else
                e.discards_left = e.discards_left - 1
            end
        end
        if context.joker_main and card.ability.extra.Xmult > 1 then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
