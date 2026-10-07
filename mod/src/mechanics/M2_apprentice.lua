-- Spec: plannig/specs/mechanics/M2_apprentice.yaml
BPlus.dict({
    k_bplus_nothing_to_upgrade = 'Nothing to upgrade!',
})

SMODS.Joker({
    key = 'apprentice',
    loc_txt = {
        name = 'Apprentice',
        text = {
            'After {C:attention}#1#{} rounds, sell this',
            'card to {C:attention}Upgrade{} a',
            'random {C:attention}Joker',
            '{C:inactive}(Currently {C:attention}#2#{C:inactive}/#1#)',
        },
    },
    atlas = 'placeholder',
    pos = { x = 0, y = 0 },
    rarity = BPlus.balance.apprentice.rarity,
    cost = BPlus.balance.apprentice.cost,
    blueprint_compat = false,
    eternal_compat = false,
    unlocked = true,
    discovered = false,
    config = { extra = { rounds = BPlus.balance.apprentice.rounds, count = 0 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds, card.ability.extra.count } }
    end,

    calculate = function(self, card, context)
        if context.blueprint then return end
        if context.end_of_round and context.game_over == false and context.main_eval
            and card.ability.extra.count < card.ability.extra.rounds then
            card.ability.extra.count = card.ability.extra.count + 1
            if card.ability.extra.count >= card.ability.extra.rounds then
                juice_card_until(card, function(c) return not c.REMOVED end, true)
                return { message = localize('k_active_ex'), colour = G.C.FILTER }
            end
            return { message = card.ability.extra.count .. '/' .. card.ability.extra.rounds, colour = G.C.FILTER }
        end
        if context.selling_self and card.ability.extra.count >= card.ability.extra.rounds then
            local target = pseudorandom_element(BPlus.eligible_jokers(), pseudoseed('bplus_apprentice'))
            if target then
                BPlus.upgrade_card(target)
            else
                return { message = localize('k_bplus_nothing_to_upgrade'), colour = G.C.FILTER }
            end
        end
    end,
})
