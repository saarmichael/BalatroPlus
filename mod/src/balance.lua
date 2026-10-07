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
    apotheosis = { cost = 4 },                       -- Spectral, same cost as Hex
    salesman = { upgrade_rate = 0.04 },              -- added to the shop's upgraded-joker rate
    craftsmanship = { upgrade_rate = 0.04, cost = 10 },
    masterwork = { upgrade_rate = 0.08, cost = 10 },  -- replaces Craftsmanship's rate (doubles it)
    workshop_pack = {                                -- 1 in `odds` per joker is upgraded
        odds = 3,
        -- same sizes, prices and weights as the Buffoon packs
        normal = { cost = 4, extra = 2, choose = 1, weight = 0.6 },
        jumbo = { cost = 6, extra = 4, choose = 1, weight = 0.6 },
        mega = { cost = 8, extra = 4, choose = 2, weight = 0.15 },
    },
    the_rust = { mult = 2, dollars = 5, min_ante = 2, max_ante = 10 },
    veteran_deck = { rounds = 6 },
}
