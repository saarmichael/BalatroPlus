-- Spec: plannig/specs/jokers/j_baseball.yaml
BPlus.Joker({
    key = 'baseball_plus',
    loc_txt = {
        name = 'Slabbed Baseball Card',
        text = {
            '{C:green}Uncommon{} Jokers',
            'each give {X:mult,C:white} X#1# {} Mult',
        },
    },
    config = { extra = { Xmult = 2 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_baseball', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.Xmult } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'count', colour = G.C.ORANGE },
                { text = 'x' },
                { ref_table = 'card.joker_display_values', ref_value = 'localized_text', colour = G.C.GREEN },
                { text = ')' },
            },
            calc_function = function(card)
                local count = 0
                if G.jokers then
                    for _, j in ipairs(G.jokers.cards) do
                        if j ~= card and j:is_rarity('Uncommon') then count = count + 1 end
                    end
                end
                card.joker_display_values.count = count
                card.joker_display_values.localized_text = localize('k_uncommon')
            end,
            mod_function = function(card, mod_joker)
                return { x_mult = (card ~= mod_joker and card:is_rarity('Uncommon')
                    and mod_joker.ability.extra.Xmult ^ JokerDisplay.calculate_joker_triggers(mod_joker) or nil) }
            end,
        }
    end,

    calculate = function(self, card, context)
        if context.other_joker and context.other_joker ~= card and context.other_joker:is_rarity('Uncommon') then
            G.E_MANAGER:add_event(Event({ func = function()
                context.other_joker:juice_up(0.5, 0.5)
                return true
            end }))
            return { xmult = card.ability.extra.Xmult }
        end
    end,
})
