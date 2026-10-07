-- Smoke test for the dev environment: every vanilla voucher costs $5 instead of $10.
-- take_ownership edits the vanilla center in place, the same pattern we'll use for jokers.

local VOUCHER_COST = 5

local changed = 0
for key, center in pairs(G.P_CENTERS) do
    if center.set == 'Voucher' and not center.mod then
        SMODS.Voucher:take_ownership(key, { cost = VOUCHER_COST }, true)
        changed = changed + 1
    end
end

sendInfoMessage(('Set %d vanilla vouchers to $%d'):format(changed, VOUCHER_COST), 'BalatroPlus')
