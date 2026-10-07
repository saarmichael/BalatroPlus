-- Shared helpers used by every feature file.
--
--   BPlus.dict{ k_bplus_x = 'Text' }   add misc.dictionary strings (localize('k_bplus_x'))
--   BPlus.get_path(t, 'extra.mult')     read a dotted path
--   BPlus.set_path(t, 'extra.mult', v)  write a dotted path (creates missing tables)
--   BPlus.load_dir('src/jokers')        load every .lua file in a folder (sorted)

BPlus.load_errors = {}

-- Dictionary strings ------------------------------------------------------------

local dictionary = {}

function BPlus.dict(entries)
    for k, v in pairs(entries) do dictionary[k] = v end
end

function BPlus.process_loc_text()
    for k, v in pairs(dictionary) do G.localization.misc.dictionary[k] = v end
end

BPlus.dict({
    k_bplus_upgraded = 'Upgraded!',
})

-- Dotted paths ---------------------------------------------------------------------

function BPlus.get_path(t, path)
    for part in path:gmatch('[^.]+') do
        if type(t) ~= 'table' then return nil end
        t = t[part]
    end
    return t
end

function BPlus.set_path(t, path, value)
    local parts = {}
    for part in path:gmatch('[^.]+') do parts[#parts + 1] = part end
    for i = 1, #parts - 1 do
        if type(t[parts[i]]) ~= 'table' then t[parts[i]] = {} end
        t = t[parts[i]]
    end
    t[parts[#parts]] = value
end

function BPlus.copy(v)
    return type(v) == 'table' and copy_table(v) or v
end

-- Loading ----------------------------------------------------------------------------

-- Loads every .lua file in a mod folder, in name order. In dev mode a broken file is logged and
-- skipped (recorded in BPlus.load_errors) so one bad joker can't take the whole mod down.
function BPlus.load_dir(dir)
    local items = NFS.getDirectoryItems(BPlus.path .. dir)
    table.sort(items)
    for _, item in ipairs(items) do
        if item:match('%.lua$') then
            local path = dir .. '/' .. item
            if BPlus.config.dev_mode then
                local ok, err = pcall(BPlus.load, path)
                if not ok then
                    BPlus.load_errors[#BPlus.load_errors + 1] = path .. ': ' .. tostring(err)
                    sendErrorMessage('Skipped ' .. path .. ': ' .. tostring(err), 'BalatroPlus')
                end
            else
                BPlus.load(path)
            end
        end
    end
end
