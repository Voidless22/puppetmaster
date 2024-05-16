local mq = require('mq')
local imgui = require('ImGui')

local gui = {}

local window_flags = 0
local no_titlebar = true
local no_scrollbar = true
local no_resize = true
if no_titlebar then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoTitleBar) end
if no_scrollbar then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoScrollbar) end
if no_resize then window_flags = bit32.bor(window_flags, ImGuiWindowFlags.NoResize) end

gui.showGui, gui.openGui = true, true
gui.boxData = {}

local function DrawDebugWindow()
end


function gui.guiLoop()
    if gui.openGui then
        gui.openGui, gui.showGui = ImGui.Begin('Puppetmaster', gui.openGui)
        DrawDebugWindow()
        ImGui.End()
    end
end

return gui
