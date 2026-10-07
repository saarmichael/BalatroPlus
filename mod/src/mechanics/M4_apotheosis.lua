-- Spec: plannig/specs/mechanics/M4_apotheosis.yaml
SMODS.Consumable({
    key = 'apotheosis',
    set = 'Spectral',
    loc_txt = {
        name = 'Apotheosis',
        text = {
            '{C:attention}Upgrade{} a random {C:attention}Joker{},',
            'destroy all other Jokers',
        },
    },
    atlas = 'placeholder',
    pos = { x = 0, y = 0 },
    cost = BPlus.balance.apotheosis.cost,
    unlocked = true,
    discovered = false,

    can_use = function(self, card)
        return #BPlus.eligible_jokers() > 0
    end,

    use = function(self, card, area, copier)
        local used_tarot = copier or card
        G.E_MANAGER:add_event(Event({ trigger = 'after', delay = 0.4, func = function()
            local chosen = pseudorandom_element(BPlus.eligible_jokers(), pseudoseed('bplus_apotheosis'))
            if chosen then
                BPlus.upgrade_card(chosen)
                local first_dissolve = nil
                for _, joker in pairs(G.jokers.cards) do
                    if joker ~= chosen and not SMODS.is_eternal(joker, card) then
                        joker.getting_sliced = true
                        joker:start_dissolve(nil, first_dissolve)
                        first_dissolve = true
                    end
                end
            end
            used_tarot:juice_up(0.3, 0.5)
            return true
        end }))
        delay(0.6)
    end,
})
