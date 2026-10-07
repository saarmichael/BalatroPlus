-- Spec: plannig/specs/jokers/j_hologram.yaml
BPlus.Joker({
    key = 'hologram_plus',
    loc_txt = {
        name = 'Holodeck',
        text = {
            'This Joker gains {X:mult,C:white} X#1# {} Mult',
            'every time a {C:attention}playing card{}',
            'is added to your deck',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    config = { extra = { Xmult = 1, Xmult_mod = 0.35 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_hologram', state_transfer = { ['x_mult'] = 'extra.Xmult' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_mod, card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.playing_card_added and not card.getting_sliced and not context.blueprint and context.cards and context.cards[1] then
            SMODS.scale_card(card, { ref_table = card.ability.extra, ref_value = 'Xmult', scalar_value = 'Xmult_mod',
                scalar_factor = #context.cards, message_key = 'a_xmult' })
        end
        if context.joker_main and card.ability.extra.Xmult > 1 then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
