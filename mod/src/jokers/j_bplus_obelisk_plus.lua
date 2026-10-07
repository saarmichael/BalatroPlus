-- Spec: plannig/specs/jokers/j_obelisk.yaml
BPlus.Joker({
    key = 'obelisk_plus',
    loc_txt = {
        name = 'Pyramid',
        text = {
            'This Joker gains {X:mult,C:white} X#1# {} Mult',
            'per {C:attention}consecutive{} hand played',
            'without playing your',
            'most played {C:attention}poker hand',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    config = { extra = { Xmult = 1, Xmult_mod = 0.4 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_obelisk', state_transfer = { ['x_mult'] = 'extra.Xmult' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_mod, card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local reset = true
            local played = G.GAME.hands[context.scoring_name].played or 0
            for k, v in pairs(G.GAME.hands) do
                if k ~= context.scoring_name and v.played >= played and SMODS.is_poker_hand_visible(k) then
                    reset = false
                end
            end
            if reset then
                if card.ability.extra.Xmult > 1 then
                    SMODS.reset_card(card, { ref_table = card.ability.extra, ref_value = 'Xmult', reset_value = 1 })
                end
            else
                SMODS.scale_card(card, { ref_table = card.ability.extra, ref_value = 'Xmult', scalar_value = 'Xmult_mod', no_message = true })
            end
        end
        if context.joker_main and card.ability.extra.Xmult > 1 then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
