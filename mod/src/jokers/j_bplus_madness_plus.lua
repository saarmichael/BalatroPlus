-- Spec: plannig/specs/jokers/j_madness.yaml
BPlus.Joker({
    key = 'madness_plus',
    loc_txt = {
        name = 'Lunacy',
        text = {
            'When {C:attention}Small Blind{} or {C:attention}Big Blind{}',
            'is selected, gain {X:mult,C:white} X#1# {} Mult',
            'and {C:attention}destroy{} a random Joker',
            '{C:inactive}(Currently {X:mult,C:white} X#2# {C:inactive} Mult)',
        },
    },
    config = { extra = { Xmult = 1, Xmult_mod = 0.75 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = false,
    bplus = { vanilla_key = 'j_madness', state_transfer = { ['x_mult'] = 'extra.Xmult' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult_mod, card.ability.extra.Xmult } }
    end,

    calculate = function(self, card, context)
        if context.setting_blind and not context.blueprint and not context.blind.boss then
            local destructable = {}
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card and not SMODS.is_eternal(j, card) and not j.getting_sliced then destructable[#destructable + 1] = j end
            end
            local victim = #destructable > 0 and pseudorandom_element(destructable, pseudoseed('bplus_lunacy')) or nil
            if victim and not card.getting_sliced then
                victim.getting_sliced = true
                G.E_MANAGER:add_event(Event({ func = function()
                    card:juice_up(0.8, 0.8)
                    victim:start_dissolve({ G.C.RED }, nil, 1.6)
                    return true
                end }))
            end
            if not card.getting_sliced then
                SMODS.scale_card(card, { ref_table = card.ability.extra, ref_value = 'Xmult', scalar_value = 'Xmult_mod', message_key = 'a_xmult' })
            end
        end
        if context.joker_main and card.ability.extra.Xmult > 1 then
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
