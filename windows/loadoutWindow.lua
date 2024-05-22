local mq = require('mq')
local ImGui = require('ImGui')
local msgHandler = require('msgHandler')
local utils = require('utils')
local modifyingGem = {}
local gemButtons = {}
local gemLoc = {}
local screenGemLoc = {}
local red = ImGui.GetColorU32(ImVec4(255, 0, 0, 255))
local green = ImGui.GetColorU32(ImVec4(0, 255, 0, 255))
local animSpellIcons = mq.FindTextureAnimation('A_SpellIcons')

local loadoutWindow = {}

local spells = {}
loadoutWindow.loadoutSections = { 'Spells', 'AAs', 'Items' }
local spellCatList
local subcategories
local selectedCategory
local currentCategory = {}
local currentSubcategory = {}
local currentSpell = {}
local loadoutData = {}
local function drawSquare(screenCursorPos, color)
    local drawlist = ImGui.GetWindowDrawList()
    local x = screenCursorPos.x + 31
    local y = screenCursorPos.y + 31
    drawlist:AddRect(screenCursorPos, ImVec2(x, y), color, 0, ImDrawFlags.None, 2)
end


local function loadLoadoutData(charName)
    local loadoutFile, err = loadfile('mimicLoadouts-' .. charName)
    if err then
        mq.pickle('mimicLoadouts-' .. charName, loadoutData[charName])
    end
    if loadoutFile then
        loadoutData[charName] = loadoutFile()
    end
end
local function BuildSpellCatList(charTable)
    for spellIndex, spellData in ipairs(charTable.Spellbook) do
        local spellEntry = charTable.Spellbook[spellIndex]
        local spellCategory = spellEntry.category
        local spellSubcategory = spellEntry.subcategory
        local categoryFound = false
        local subcategoryFound = false
        if not spellCatList then spellCatList = {} end
        -- search if the category already exists, if it doesn't, create it
        for index, value in pairs(spellCatList) do
            if index == spellCategory then
                categoryFound = true
            end
        end
        if not categoryFound then
            spellCatList[spellCategory] = {}
            categoryFound = true
        end
-- now that the category should exist, or already does, search for if the spell's subcategory already exists, if it doesn't create it.
        if categoryFound then
            for index, value in pairs(spellCatList[spellCategory]) do
                if value == spellSubcategory then
                    subcategoryFound = true
                end
            end
        end
        if categoryFound and not subcategoryFound then
            table.insert(spellCatList[spellCategory], spellSubcategory)
            subcategoryFound = true
        end
    end
end

function loadoutWindow.DrawSpellCategorySelect(charName, charTable)
    if ImGui.BeginListBox("##Category", ImVec2(150, 300)) then
        for index, value in pairs(spellCatList) do
            local _, clicked = ImGui.Selectable(index, currentCategory[charName] == index)
            ImGui.Separator()
            if clicked then
                currentSubcategory[charName] = nil
                currentSpell[charName] = nil
                currentCategory[charName] = index
            end
        end

        ImGui.EndListBox()
    end
end

function loadoutWindow.DrawSpellSubcategorySelect(charName, charTable)
    if ImGui.BeginListBox("##Subcategory", ImVec2(150, 300)) then
        if currentCategory[charName] ~= nil then
            for i, item in pairs(spellCatList) do
                if i == currentCategory[charName] then
                    for index, value in pairs(spellCatList[i]) do
                        local _, clicked = ImGui.Selectable(value,
                            currentSubcategory[charName] == value)
                        ImGui.Separator()
                        if clicked then
                            currentSpell[charName] = nil
                            currentSubcategory[charName] = value
                        end
                    end
                end
            end
        end
        ImGui.EndListBox()

    end

end

function loadoutWindow.DrawSpellSelect(charName, charTable)
    if ImGui.BeginListBox("##Spells", ImVec2(200, 300)) then
        if currentSubcategory[charName] ~= nil and currentCategory[charName] ~= nil then
            for index, value in ipairs(charTable.Spellbook) do
                if value.category == currentCategory[charName] and value.subcategory == currentSubcategory[charName] then
                    local _, clicked = ImGui.Selectable('Lvl:' .. value.level .. ' ' .. value.name,
                        currentSpell[charName] == value.name)
                    ImGui.Separator()
                    if clicked then
                        currentSpell[charName] = value.name
                        if mq.TLO.Spell(modifyingGem[charName].id).Name() ~= currentSpell[charName] then
                            modifyingGem[charName].id = mq.TLO.Spell(currentSpell[charName]).Name()
                            utils.driverActor:send(msgHandler.boxAddress,
                                {
                                    id = 'updateSpellbar',
                                    charName = charName,
                                    gem = modifyingGem[charName].gem,
                                    spellId = currentSpell
                                        [charName]
                                })
                        end
                    end
                end
            end
        end
        ImGui.EndListBox()

    end
end

function loadoutWindow.DrawCurrentSpellbar(charName, charTable)
    local spellIds = charTable.Spellbar
    if spellIds ~= nil then
        for currentGem = 1, #spellIds do
            if spellIds[currentGem] == nil then
                local cursorPos = ImGui.GetCursorPosVec()
                local screenCursorPos = ImGui.GetCursorScreenPosVec()
                drawSquare(screenCursorPos, red)
                ImGui.SetCursorPos(cursorPos)
                screenGemLoc[currentGem] = ImGui.GetCursorScreenPosVec()
                gemButtons[currentGem] = ImGui.InvisibleButton((mq.TLO.Spell(spellIds[currentGem]).Name() or 'Empty'), 32,
                    32)
            elseif spellIds[currentGem] ~= nil then
                local cursorPos = ImGui.GetCursorPosVec()
                animSpellIcons:SetTextureCell(mq.TLO.Spell(spellIds[currentGem]).SpellIcon())
                ImGui.DrawTextureAnimation(animSpellIcons, 32, 32)
                ImGui.SetCursorPos(cursorPos)
                screenGemLoc[currentGem] = ImGui.GetCursorScreenPosVec()
                gemButtons[currentGem] = ImGui.InvisibleButton((mq.TLO.Spell(spellIds[currentGem]).Name() or "Empty"), 32,
                    32)
            end

            drawSquare(screenGemLoc[modifyingGem[charName].gem], green)



            if gemButtons[currentGem] then
                printf('gem %s clicked', currentGem)
                modifyingGem[charName] = { gem = currentGem, id = charTable.Spellbar[currentGem] }
                currentCategory[charName] = mq.TLO.Spell(charTable.Spellbar[currentGem]).Category()
                currentSubcategory[charName] = mq.TLO.Spell(charTable.Spellbar[currentGem]).Subcategory()
                currentSpell[charName] = mq.TLO.Spell(charTable.Spellbar[currentGem]).Name()
            end
            if ImGui.IsItemHovered() then
                if ImGui.BeginTooltip() then
                    if mq.TLO.Spell(spellIds[currentGem]).Name() == nil then
                        ImGui.Text("Empty")
                    else
                        ImGui.Text(mq.TLO.Spell(spellIds[currentGem]).Name())
                    end
                end
                ImGui.EndTooltip()
            end
        end
    end
end

function loadoutWindow.DrawSpellsTab(charName, charTable)
    if not spellCatList and charTable.Spellbook then BuildSpellCatList(charTable) end
    -- Draw Spellbar
    loadoutWindow.DrawCurrentSpellbar(charName, charTable)
    ImGui.SetCursorPos(60, 40)
    if spellCatList and charTable.Spellbook then
        loadoutWindow.DrawSpellCategorySelect(charName, charTable)
        ImGui.SetCursorPos(212, 40)
        loadoutWindow.DrawSpellSubcategorySelect(charName, charTable)
        ImGui.SetCursorPos(364, 40)
        loadoutWindow.DrawSpellSelect(charName, charTable)
    end
end

function loadoutWindow.DrawTabScreen(tab, charName, charTable)
    if tab == 'Spells' then
        loadoutWindow.DrawSpellsTab(charName, charTable)
    end
end

function loadoutWindow.DrawLoadoutWindow(charName, charTable)
    if modifyingGem[charName] == nil then modifyingGem[charName] = { gem = 1, id = nil } end
    ImGui.SetWindowSize("Loadout-" .. charName, 600, 380, ImGuiCond.FirstUseEver)
    if ImGui.BeginTabBar("##loadoutSections") then
        for i = 1, #loadoutWindow.loadoutSections do
            if ImGui.BeginTabItem(loadoutWindow.loadoutSections[i]) then
                loadoutWindow.DrawTabScreen(loadoutWindow.loadoutSections[i], charName, charTable)
                ImGui.EndTabItem()
            end
        end
    end
    ImGui.EndTabBar()
end

return loadoutWindow
