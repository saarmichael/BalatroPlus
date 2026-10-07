-- M7 Masterwork Tag. Spec: plannig/specs/mechanics/M7_masterwork_tag.yaml
-- Works like the Foil Tag: the next eligible joker the shop offers appears upgraded.

SMODS.Atlas({ key = 'mc_tags', path = 'bplus_tags.png', px = 34, py = 34 })

SMODS.Tag({
    key = 'masterwork',
    atlas = 'mc_tags', pos = { x = 0, y = 0 },
    config = { type = 'store_joker_modify' },
    discovered = false,
    loc_txt = {
        name = 'Masterwork Tag',
        text = { 'Shop has an', '{C:attention}upgraded{} Joker' },
    },
    apply = function(self, tag, context)
        if context.type ~= 'store_joker_modify' then return end
        local card = context.card
        if not BPlus.is_eligible(card) or card.bplus_pending_upgrade then return end
        local lock = tag.ID
        G.CONTROLLER.locks[lock] = true
        card.bplus_pending_upgrade = true   -- keep other Masterwork Tags off this card until it is done
        tag:yep('+', G.C.PURPLE, function()
            card.bplus_pending_upgrade = nil
            BPlus.shop_upgrade.upgrade(card)
            card:juice_up(0.8, 0.5)
            G.CONTROLLER.locks[lock] = nil
            return true
        end)
        tag.triggered = true
        return true
    end,
})
