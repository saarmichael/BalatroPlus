-- Spec: plannig/specs/jokers/j_invisible.yaml
BPlus.Joker({
    key = 'invisible_plus',
    loc_txt = {
        name = 'Phantom',
        text = {
            'After {C:attention}#1#{} rounds, sell this card to',
            '{C:attention}upgrade{} a random Joker and',
            '{C:attention}Duplicate{} it',
            '{C:inactive}(Currently {C:attention}#2#{C:inactive}/#1#)',
        },
    },
    config = { extra = { rounds_needed = 2, rounds = 0 } },
    blueprint_compat = false, eternal_compat = false, perishable_compat = true,
    bplus = { vanilla_key = 'j_invisible', state_transfer = { ['invis_rounds'] = 'extra.rounds' }, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.rounds_needed, card.ability.extra.rounds } }
    end,

    joker_display_def = function(JokerDisplay)
        return {
            reminder_text = {
                { text = '(' },
                { ref_table = 'card.joker_display_values', ref_value = 'active' },
                { text = ')' },
            },
            calc_function = function(card)
                local e = card.ability.extra
                card.joker_display_values.is_active = e.rounds >= e.rounds_needed
                card.joker_display_values.active = card.joker_display_values.is_active and localize('jdis_active')
                    or (e.rounds .. '/' .. e.rounds_needed)
            end,
            style_function = function(card, text, reminder_text, extra)
                if reminder_text and reminder_text.children and reminder_text.children[2] then
                    reminder_text.children[2].config.colour = card.joker_display_values.is_active and G.C.GREEN
                        or G.C.UI.TEXT_INACTIVE
                end
            end,
        }
    end,

    calculate = function(self, card, context)
        local e = card.ability.extra
        if context.end_of_round and context.main_eval and not context.blueprint then
            e.rounds = e.rounds + 1
            if e.rounds == e.rounds_needed then
                juice_card_until(card, function(c) return not c.REMOVED end, true)
            end
            return {
                message = (e.rounds < e.rounds_needed) and (e.rounds .. '/' .. e.rounds_needed) or localize('k_active_ex'),
                colour = G.C.FILTER,
            }
        end
        if context.selling_self and not context.blueprint and e.rounds >= e.rounds_needed then
            local others, eligible = {}, {}
            for _, j in ipairs(G.jokers.cards) do
                if j ~= card then
                    others[#others + 1] = j
                    if BPlus.is_eligible(j) then eligible[#eligible + 1] = j end
                end
            end
            if #others == 0 then
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = localize('k_no_other_jokers') })
            elseif #G.jokers.cards > G.jokers.config.card_limit then
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = localize('k_no_room_ex') })
            else
                local pool = #eligible > 0 and eligible or others
                local chosen = pseudorandom_element(pool, pseudoseed('bplus_phantom'))
                if #eligible > 0 then BPlus.upgrade_card(chosen) end
                card_eval_status_text(card, 'extra', nil, nil, nil, { message = localize('k_duplicated_ex') })
                local copy = copy_card(chosen, nil, nil, nil, chosen.edition and chosen.edition.negative)
                if copy.ability.invis_rounds then copy.ability.invis_rounds = 0 end
                if type(copy.ability.extra) == 'table' and copy.ability.extra.rounds_needed then copy.ability.extra.rounds = 0 end
                copy:add_to_deck()
                G.jokers:emplace(copy)
            end
        end
    end,
})
