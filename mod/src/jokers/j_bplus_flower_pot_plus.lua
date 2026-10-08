-- Spec: plannig/specs/jokers/j_flower_pot.yaml
BPlus.dict({ k_bplus_suits = 'Suits' })

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

    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = 'X' },
                        { ref_table = 'card.joker_display_values', ref_value = 'x_mult', retrigger_type = 'exp' },
                    },
                },
            },
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text', colour = G.C.ORANGE },
                { text = ')' },
            },
            calc_function = function(card)
                local text, _, scoring_hand = JokerDisplay.evaluate_hand()
                local seen = { Hearts = false, Diamonds = false, Spades = false, Clubs = false }
                local order = { 'Hearts', 'Diamonds', 'Spades', 'Clubs' }
                local n = 0
                if text ~= 'Unknown' then
                    for _, c in ipairs(scoring_hand) do
                        if not SMODS.has_any_suit(c) then
                            for _, s in ipairs(order) do
                                if c:is_suit(s, true) and not seen[s] then seen[s] = true; break end
                            end
                        end
                    end
                    for _, c in ipairs(scoring_hand) do
                        if SMODS.has_any_suit(c) then
                            for _, s in ipairs(order) do
                                if c:is_suit(s) and not seen[s] then seen[s] = true; break end
                            end
                        end
                    end
                    for _, s in ipairs(order) do if seen[s] then n = n + 1 end end
                end
                card.joker_display_values.x_mult = n >= card.ability.extra.suits and card.ability.extra.Xmult or 1
                card.joker_display_values.localized_text = card.ability.extra.suits >= 4 and localize('jdis_all_suits')
                    or (card.ability.extra.suits .. ' ' .. localize('k_bplus_suits'))
            end,
        }
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
