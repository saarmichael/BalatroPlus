-- Spec: plannig/specs/jokers/j_ring_master.yaml, plannig/specs/mechanics/M5_salesman.yaml
BPlus.Joker({
    key = 'ring_master_plus',
    loc_txt = {
        name = 'Salesman',
        text = {
            '{C:attention}Joker{}, {C:tarot}Tarot{}, {C:planet}Planet{}, and',
            '{C:spectral}Spectral{} cards may appear',
            'multiple times',
            '{C:attention}Upgraded{} Jokers appear',
            '{C:green}#1#%{} more often in the shop',
        },
    },
    config = { extra = {} },
    blueprint_compat = false, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_ring_master', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { BPlus.balance.salesman.upgrade_rate * 100 } }
    end,
})

-- Showman effect: smods decides duplicates in SMODS.showman and only looks for j_ring_master.
-- Use find_behaving so Carpenter (vanilla Showman acting as Salesman) and The Rust (Salesman acting as
-- Showman) keep the effect.
local showman_ref = SMODS.showman
function SMODS.showman(card_key)
    if showman_ref(card_key) then return true end
    return G.jokers ~= nil and (next(BPlus.find_behaving('j_bplus_ring_master_plus'))
        or next(BPlus.find_behaving('j_ring_master'))) ~= nil
end
