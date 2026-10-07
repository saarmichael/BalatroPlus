-- Spec: plannig/specs/jokers/j_ticket.yaml
BPlus.Joker({
    key = 'ticket_plus',
    loc_txt = {
        name = 'Goldbars',
        text = { 'Played {C:attention}Gold{} cards', 'earn {C:money}$#1#{} when scored' },
    },
    config = { extra = { dollars = 5 } },
    blueprint_compat = true, eternal_compat = true, perishable_compat = true,
    bplus = { vanilla_key = 'j_ticket', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = G.P_CENTERS.m_gold
        return { vars = { card.ability.extra.dollars } }
    end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play
            and SMODS.has_enhancement(context.other_card, 'm_gold') then
            return { dollars = card.ability.extra.dollars }
        end
    end,
})
