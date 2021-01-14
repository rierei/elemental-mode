local ElementalMode = class('ElementalMode')

local ModeConfig = require('__shared/mode-config')

function ElementalMode:__init()
    self:RegisterVars()
    self:RegisterEvents()
end

function ElementalMode:RegisterVars()
    self.m_verbose = 1 -- prints debug information

    WebUI:Init()
end

function ElementalMode:RegisterEvents()
    Events:Subscribe('Player:Respawn', function(p_player)
        if p_player ~= PlayerManager:GetLocalPlayer() or p_player.soldier.isManDown then
            return
        end

        WebUI:ExecuteJS('showElementSelection();')
    end)

    Events:Subscribe('ElementalMode:Select', function(p_element)
        if PlayerManager:GetLocalPlayer().soldier.isDead then
            return
        end

        if self.m_verbose >= 1 then
            print('ElementalMode:Select')
            print(p_element)
        end

        NetEvents:Send('ElementalMode:Secondary', p_element)
    end)
end

if ModeConfig.selection ~= 1 then
    g_elementalMode = ElementalMode()
end