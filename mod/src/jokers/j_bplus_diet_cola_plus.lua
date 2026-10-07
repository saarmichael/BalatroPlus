-- Spec: plannig/specs/jokers/j_diet_cola.yaml
BPlus.Joker({
    key = 'diet_cola_plus',
    loc_txt = {
        name = 'Cola Zero',
        text = {
            'Sell this card to',
            'create {C:attention}#1#{} free',
            '{C:attention}#2#s',
        },
    },
    config = { extra = { tags = 2 } },
    blueprint_compat = true, eternal_compat = false, perishable_compat = true,
    bplus = { vanilla_key = 'j_diet_cola', state_transfer = {}, carpenter_compat = true },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue + 1] = { key = 'tag_double', set = 'Tag' }
        return { vars = { card.ability.extra.tags, localize { type = 'name_text', set = 'Tag', key = 'tag_double', nodes = {} } } }
    end,

    calculate = function(self, card, context)
        if context.selling_self then
            local n = card.ability.extra.tags
            G.E_MANAGER:add_event(Event({
                func = function()
                    for _ = 1, n do add_tag(Tag('tag_double')) end
                    play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                    play_sound('holo1', 1.2 + math.random() * 0.1, 0.4)
                    return true
                end,
            }))
            return nil, true
        end
    end,
})
