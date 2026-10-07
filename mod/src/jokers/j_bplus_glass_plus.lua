-- Spec: plannig/specs/jokers/j_glass.yaml
BPlus.Joker({
    key = 'glass_plus',
    loc_txt = {
        name = 'Plexiglass Joker',
        text = {
            'This Joker gains {X:mult,C:white} X#1# {} Mult',
            'for every {C:attention}Glass Card',
            'that is destroyed',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    config = { extra = { Xmult = 1, Xmult_mod = 1.5 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_glass', state_transfer = { ['x_mult'] = 'extra.Xmult' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_mod, card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            local glass = 0
            for _, c in ipairs(context.removed) do
                if c.shattered then glass = glass + 1 end
            end
            if glass > 0 then
                SMODS.scale_card(card, { ref_table = card.ability.extra, ref_value = 'Xmult', scalar_value = 'Xmult_mod',
                    scalar_factor = glass, message_key = 'a_xmult' })
            end
        end
        if context.using_consumeable and not context.blueprint and context.consumeable.ability.name == 'The Hanged Man' then
            local glass = 0
            for _, c in ipairs(G.hand.highlighted) do
                if SMODS.has_enhancement(c, 'm_glass') then glass = glass + 1 end
            end
            if glass > 0 then
                SMODS.scale_card(card, { ref_table = card.ability.extra, ref_value = 'Xmult', scalar_value = 'Xmult_mod',
                    scalar_factor = glass, message_key = 'a_xmult' })
            end
        end
        if context.joker_main and card.ability.extra.Xmult > 1 then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
