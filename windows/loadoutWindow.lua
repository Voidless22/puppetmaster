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
local SpellTable = {}
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

local function BuildSpellDB(charTable)
    local spellDB = {}
    if charTable.Spellbook then
        for bookIndex, spellData in ipairs(charTable.Spellbook) do
            local spellCategoryFound = false
            local spellSubcategoryFound = false
            local spellFound = false
            if not spellDB[spellData.category] then
                spellDB[spellData.category] = {}
            end

            if not spellDB[spellData.category][spellData.subcategory] then
                spellDB[spellData.category][spellData.subcategory] = {}
            end
            for index, value in ipairs(spellDB[spellData.category][spellData.subcategory]) do
                if value == spellData.id then spellFound = true end
            end
            if not spellFound then
                table.insert(spellDB[spellData.category][spellData.subcategory], spellData.id)
            end
        end
        return spellDB
    end
end





local function BuildSpellCatList(charName, charTable)
    for spellIndex, spellData in ipairs(charTable.Spellbook) do
        local spellEntry = charTable.Spellbook[spellIndex]
        local spellCategory = spellEntry.category
        local spellSubcategory = spellEntry.subcategory
        local spellId = spellEntry.id
        local categoryFound = false
        local subcategoryFound = false
        local spellIdFound = false
        if not spellCatList[charName] then spellCatList[charName] = {} end
        -- search if the category already exists, if it doesn't, create it
        for index, value in pairs(spellCatList[charName]) do
            if index == spellCategory then
                categoryFound = true
            end
        end
        if not categoryFound then
            spellCatList[charName][spellCategory] = {}
            categoryFound = true
        end
        -- now that the category should exist, or already does, search for if the spell's subcategory already exists, if it doesn't create it.
        if categoryFound then
            for index, value in pairs(spellCatList[charName][spellCategory]) do
                if value == spellSubcategory then
                    subcategoryFound = true
                end
            end
        end
        if categoryFound and not subcategoryFound then
            table.insert(spellCatList[charName][spellCategory], spellSubcategory)
            subcategoryFound = true
        end

        for index, value in pairs(spellCatList[charName]) do

        end
    end
end

function loadoutWindow.DrawSpellCategorySelect(charName, charTable)
    if ImGui.BeginListBox("##Category", ImVec2(150, 300)) then
        for index, value in pairs(SpellTable[charName]) do
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
            for i, item in pairs(SpellTable[charName][currentCategory[charName]]) do
                local _, clicked = ImGui.Selectable(i,
                    currentSubcategory[charName] == i)
                ImGui.Separator()
                if clicked then
                    currentSpell[charName] = nil
                    currentSubcategory[charName] = i
                end
            end
        end
        ImGui.EndListBox()
    end
end

function loadoutWindow.DrawSpellSelect(charName, charTable)
    if ImGui.BeginListBox("##Spells", ImVec2(200, 300)) then
        if currentSubcategory[charName] ~= nil and currentCategory[charName] ~= nil then
            for index, value in ipairs(SpellTable[charName][currentCategory[charName]][currentSubcategory[charName]]) do
                local spellLvl = mq.TLO.Spell(value).Level()
                local spellName = mq.TLO.Spell(value).Name()
                local _, clicked = ImGui.Selectable('Lvl:' .. spellLvl .. ' ' .. spellName,
                    currentSpell[charName] == spellName)
                if ImGui.IsItemHovered(ImGuiHoveredFlags.DelayNormal) then
                    if ImGui.BeginItemTooltip() then
                        ImGui.Text(spellName or "Empty")
                        ImGui.Text(("Type: " .. mq.TLO.Spell(spellName).TargetType()) or "Empty")
                        ImGui.EndTooltip()
                    end
                end
                ImGui.Separator()
                if clicked then
                    currentSpell[charName] = spellName
                    if mq.TLO.Spell(modifyingGem[charName].id).Name() ~= currentSpell[charName] then
                        modifyingGem[charName].id = mq.TLO.Spell(currentSpell[charName]).Name()
                        if charName ~= mq.TLO.Me.Name() then
                            utils.driverActor:send(msgHandler.boxAddress,
                                {
                                    id = 'updateSpellbar',
                                    charName = charName,
                                    gem = modifyingGem[charName].gem,
                                    spellId = currentSpell
                                        [charName]
                                })
                        else
                            mq.cmdf('/memspell %i "%s"', modifyingGem[charName].gem, currentSpell[charName])
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
    if not SpellTable[charName] and charTable.Spellbook then SpellTable[charName] = BuildSpellDB(charTable) end
    -- Draw Spellbar
    loadoutWindow.DrawCurrentSpellbar(charName, charTable)
    ImGui.SetCursorPos(60, 40)
    if SpellTable[charName] and charTable.Spellbook then
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
