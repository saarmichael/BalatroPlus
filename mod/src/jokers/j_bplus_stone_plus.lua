-- Spec: plannig/specs/jokers/j_stone.yaml
BPlus.Joker({
    key = 'stone_plus',
    loc_txt = {
        name = 'Monolith',
        text = {
            'Gives {C:chips}+#1#{} Chips for',
            'each {C:attention}Stone Card',
            'in your {C:attention}full deck',
            '{C:inactive}(Currently {C:chips}+#2#{C:inactive} Chips)',
        },
    },
    config = { extra = { chips_per = 50 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_stone', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips_per, card.ability.extra.chips_per * self.stone_count() } }
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            local count = self.stone_count()
            if count > 0 then
                return { chips = card.ability.extra.chips_per * count }
            end
        end
    end,

    stone_count = function()
        local n = 0
        for _, c in ipairs(G.playing_cards or {}) do
            if SMODS.has_enhancement(c, 'm_stone') then n = n + 1 end
        end
        return n
    end,
})
