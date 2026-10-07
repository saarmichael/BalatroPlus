-- Every tunable number of the upgrade mechanics (brief: "Upgrade mechanics", M1-M10).
-- Change values here only; logic files read BPlus.balance.<mechanic>.<field>.
-- Starting values chosen by the human on 2026-10-07, to be tuned after playtesting.
return {
    carpenter = { rarity = 2, cost = 8 },
    apprentice = { rounds = 3, rarity = 2, cost = 6 },
    wheel_of_fortune = {
        -- outcome shares on a success (sum to 1); vanilla editions keep their 50/35/15 proportions
        upgrade = 0.25, foil = 0.375, holo = 0.2625, polychrome = 0.1125,
    },
    salesman = { upgrade_rate = 0.04 },              -- added to the shop's upgraded-joker rate
    craftsmanship = { upgrade_rate = 0.04, cost = 10 },
    masterwork = { upgrade_rate = 0.08, cost = 10 },  -- replaces Craftsmanship's rate (doubles it)
    workshop_pack = { odds = 3 },                    -- 1 in `odds` per joker is upgraded
    veteran_deck = { rounds = 6 },
}
