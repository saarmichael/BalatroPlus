-- M6 Craftsmanship / Masterwork vouchers. Spec: plannig/specs/mechanics/M6_craftsmanship.yaml
-- The vouchers only set the shop's upgraded-joker rate (BPlus.shop_upgrade.rate reads them live);
-- the upgrade itself is done by the shared helper in shop_upgrade.lua.

SMODS.Atlas({ key = 'mc_vouchers', path = 'bplus_vouchers.png', px = 71, py = 95 })

SMODS.Voucher({
    key = 'craftsmanship',
    atlas = 'mc_vouchers', pos = { x = 0, y = 0 },
    cost = BPlus.balance.craftsmanship.cost,
    unlocked = true, discovered = false,
    config = { extra = BPlus.balance.craftsmanship.upgrade_rate },
    loc_txt = {
        name = 'Craftsmanship',
        text = {
            '{C:attention}Upgraded{} Jokers can appear',
            'in the shop ({C:green}#1#%{} of Jokers),',
            'at their base price',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { BPlus.balance.craftsmanship.upgrade_rate * 100 } }
    end,
})

SMODS.Voucher({
    key = 'masterwork',
    atlas = 'mc_vouchers', pos = { x = 1, y = 0 },
    cost = BPlus.balance.masterwork.cost,
    unlocked = true, discovered = false,
    requires = { 'v_bplus_craftsmanship' },
    config = { extra = BPlus.balance.masterwork.upgrade_rate },
    loc_txt = {
        name = 'Masterwork',
        text = {
            '{C:attention}Upgraded{} Jokers appear',
            'more often in the shop',
            '({C:green}#1#%{} of Jokers)',
        },
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { BPlus.balance.masterwork.upgrade_rate * 100 } }
    end,
})
