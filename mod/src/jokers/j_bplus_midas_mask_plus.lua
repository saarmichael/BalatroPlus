-- Spec: plannig/specs/jokers/j_midas_mask.yaml
BPlus.Joker({
    key = 'midas_mask_plus',
    loc_txt = {
        name = 'Midas Touch',
        text = {
            'All played cards',
            'become {C:attention}Gold{} cards',
            'when scored',
        },
    },
    config = { extra = {} },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_midas_mask', state_transfer = {}, carpenter_compat = true },

    joker_display_def = function(JokerDisplay)
        return {} -- vanilla Midas Mask shows nothing either
    end,

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
        return { vars = {} }
    end,

    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local changed = 0
            for _, v in ipairs(context.scoring_hand) do
                changed = changed + 1
                v:set_ability(G.P_CENTERS.m_gold, nil, true)
                G.E_MANAGER:add_event(Event({ func = function()
                    v:juice_up()
                    return true
                end }))
            end
            if changed > 0 then
                return { message = localize('k_gold'), colour = G.C.MONEY, card = card }
            end
        end
    end,
})
