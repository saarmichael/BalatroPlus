-- Spec: plannig/specs/jokers/j_raised_fist.yaml
BPlus.Joker({
    key = 'raised_fist_plus',
    loc_txt = {
        name = 'Coup',
        text = {
            'Adds {C:attention}quadruple{} the rank',
            'of {C:attention}lowest{} ranked card',
            'held in hand to Mult',
        },
    },
    config = { extra = { rank_mult = 4 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_raised_fist', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rank_mult } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            -- same selection as vanilla: lowest id wins, ties go to the last such card; Stone cards skipped
            local temp_mult, temp_id, lowest = 15, 15, nil
            for i = 1, #G.hand.cards do
                local c = G.hand.cards[i]
                if temp_id >= c.base.id and not SMODS.has_no_rank(c) then
                    temp_mult, temp_id, lowest = c.base.nominal, c.base.id, c
                end
            end
            if lowest and lowest == context.other_card then
                if lowest.debuff then
                    return { message = localize('k_debuffed'), colour = G.C.RED, card = card }
                end
                return { h_mult = card.ability.extra.rank_mult * temp_mult, card = card }
            end
        end
    end,
})
