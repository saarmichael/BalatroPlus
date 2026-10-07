-- Spec: plannig/specs/jokers/j_flower_pot.yaml
BPlus.Joker({
    key = 'flower_pot_plus',
    loc_txt = {
        name = 'Flower Garden',
        text = {
            '{X:mult,C:white} X#1# {} Mult if poker hand',
            'contains at least {C:attention}#2#{} of: a',
            '{C:diamonds}Diamond{} card, {C:clubs}Club{} card,',
            '{C:hearts}Heart{} card, {C:spades}Spade{} card',
        },
    },
    config = { extra = { Xmult = 3, suits = 3 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_flower_pot', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult, card.ability.extra.suits } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            -- same algorithm as vanilla: non-Wild cards claim their suit first, Wild cards fill the gaps
            local seen = { Hearts = false, Diamonds = false, Spades = false, Clubs = false }
            local order = { 'Hearts', 'Diamonds', 'Spades', 'Clubs' }
            for _, c in ipairs(context.scoring_hand) do
                if not SMODS.has_any_suit(c) then
                    for _, s in ipairs(order) do
                        if c:is_suit(s, true) and not seen[s] then seen[s] = true; break end
                    end
                end
            end
            for _, c in ipairs(context.scoring_hand) do
                if SMODS.has_any_suit(c) then
                    for _, s in ipairs(order) do
                        if c:is_suit(s) and not seen[s] then seen[s] = true; break end
                    end
                end
            end
            local n = 0
            for _, s in ipairs(order) do if seen[s] then n = n + 1 end end
            if n >= card.ability.extra.suits then
                return { xmult = card.ability.extra.Xmult }
            end
        end
    end,
})
