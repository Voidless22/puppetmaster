local mq = require('mq')
local ImGui = require('ImGui')
local msgHandler = require('msgHandler')
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

function loadoutWindow.DrawSpellCategorySelect(charName, charTable)
    if ImGui.BeginListBox("##Category", ImVec2(150, 300)) then
        for i, category in pairs(charTable.spellTable.categories) do
            local _, clicked = ImGui.Selectable(category, currentCategory[charName] == category)
            ImGui.Separator()
            if clicked then
                currentSubcategory[charName] = nil
                currentSpell[charName] = nil
                currentCategory[charName] = category
            end
        end
    end
    ImGui.EndListBox()
end

function loadoutWindow.DrawSpellSubcategorySelect(charName, charTable)
    if ImGui.BeginListBox("##Subcategory", ImVec2(150, 300)) then
        if currentCategory[charName] ~= nil then
            for i, item in pairs(charTable.spellTable[currentCategory[charName]].subcategories) do
                local _, clicked = ImGui.Selectable(item, currentSubcategory[charName] == item)
                ImGui.Separator()
                if clicked then
                    currentSpell[charName] = nil
                    currentSubcategory[charName] = item
                end
            end
        end
    end

    ImGui.EndListBox()
end

function loadoutWindow.DrawSpellSelect(charName, charTable)
    if ImGui.BeginListBox("##Spells", ImVec2(200, 300)) then
        if currentSubcategory[charName] ~= nil and currentCategory[charName] ~= nil then
            for i, item in pairs(charTable.spellTable[currentCategory[charName]][currentSubcategory[charName]]) do
                local _, clicked = ImGui.Selectable('Lvl:' .. item[1] .. ' ' .. item[2],
                    currentSpell[charName] == item[2])
                ImGui.Separator()
                if clicked then
                    currentSpell[charName] = item[2]
                    if mq.TLO.Spell(modifyingGem[charName].id).Name() ~= currentSpell[charName] then
                        modifyingGem[charName].id = mq.TLO.Spell(currentSpell[charName]).Name()
                        msgHandler.DriverActor:send(msgHandler.boxAddress,
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

function loadoutWindow.DrawCurrentSpellbar(charName, charTable)
    local spellIds = charTable.Spellbar
    if spellIds ~= nil then
        for currentGem = 1, #spellIds do
            if spellIds[currentGem] == nil then
                local cursorPos = ImGui.GetCursorPosVec()
                local screenCursorPos = ImGui.GetCursorScreenPosVec()
                drawSquare(screenCursorPos, red)
                ImGui.SetCursorPos(cursorPos)
                gemLoc[currentGem] = ImGui.GetCursorPosVec()
                screenGemLoc[currentGem] = ImGui.GetCursorScreenPosVec()
                gemButtons[currentGem] = ImGui.InvisibleButton((mq.TLO.Spell(spellIds[currentGem]).Name() or 'Empty'), 32,
                    32)
            elseif spellIds[currentGem] ~= nil then
                local cursorPos = ImGui.GetCursorPosVec()
                animSpellIcons:SetTextureCell(mq.TLO.Spell(spellIds[currentGem]).SpellIcon())
                ImGui.DrawTextureAnimation(animSpellIcons, 32, 32)
                ImGui.SetCursorPos(cursorPos)
                gemLoc[currentGem] = ImGui.GetCursorPosVec()
                screenGemLoc[currentGem] = ImGui.GetCursorScreenPosVec()
                gemButtons[currentGem] = ImGui.InvisibleButton(mq.TLO.Spell(spellIds[currentGem]).Name(), 32, 32)
            end

            drawSquare(screenGemLoc[modifyingGem[charName].gem], green)



            if gemButtons[currentGem] then
                printf('gem %s clicked', currentGem)
                modifyingGem[charName] = { gem = currentGem, id = mq.TLO.Spell(currentGem).ID() }
                currentCategory[charName] = mq.TLO.Spell(spellIds[modifyingGem[charName].id]).Category()
                currentSubcategory[charName] = mq.TLO.Spell(spellIds[modifyingGem[charName].id]).Subcategory()
                currentSpell[charName] = mq.TLO.Spell(spellIds[modifyingGem[charName].id]).Name()
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
    -- Draw Spellbar
    loadoutWindow.DrawCurrentSpellbar(charName, charTable)
    ImGui.SetCursorPos(60, 40)
    loadoutWindow.DrawSpellCategorySelect(charName, charTable)
    ImGui.SetCursorPos(212, 40)
    loadoutWindow.DrawSpellSubcategorySelect(charName, charTable)
    ImGui.SetCursorPos(364, 40)
    loadoutWindow.DrawSpellSelect(charName, charTable)

end

function loadoutWindow.DrawTabScreen(tab, charName, charTable)
    if tab == 'Spells' then
        loadoutWindow.DrawSpellsTab(charName, charTable)
    end
end

function loadoutWindow.DrawLoadoutWindow(charName, charTable)
    if modifyingGem[charName] == nil then modifyingGem[charName] = { gem = 1, id = nil } end
    ImGui.SetWindowSize("Loadout-" .. charName, 600, 380,ImGuiCond.FirstUseEver)
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
