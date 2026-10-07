-- Spec: plannig/specs/jokers/j_caino.yaml
BPlus.Joker({
    key = 'caino_plus',
    loc_txt = {
        name = 'Canio+',
        text = {
            'This Joker gains {X:mult,C:white} X#1# {} Mult',
            'when a {C:attention}face{} card',
            'is destroyed',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    config = { extra = { Xmult = 1, Xmult_mod = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_caino', state_transfer = { ['caino_xmult'] = 'extra.Xmult' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_mod, card.ability.extra.Xmult } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = 'X' },
                        { ref_table = 'card.ability.extra', ref_value = 'Xmult', retrigger_type = 'exp' },
                    },
                },
            },
        }
    end,

    calculate = function(self, card, context)
        if context.remove_playing_cards and not context.blueprint then
            local faces = 0
            for _, c in ipairs(context.removed) do
                if c:is_face() then faces = faces + 1 end
            end
            if faces > 0 then
                SMODS.scale_card(card, {
                    ref_table = card.ability.extra,
                    ref_value = 'Xmult',
                    scalar_value = 'Xmult_mod',
                    scalar_factor = faces,
                    message_key = 'a_xmult',
                })
            end
        end
        if context.joker_main and card.ability.extra.Xmult > 1 then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
