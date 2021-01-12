local ElementalMode = class('ElementalMode')

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
        WebUI:ExecuteJS('showElementSelection();')
    end)

    Events:Subscribe('ElementalMode:Select', function(p_element)
        if self.m_verbose >= 1 then
            print('ElementalMode:Select')
            print(p_element)
        end

        NetEvents:Send('ElementalMode:Secondary', p_element)
    end)
end

g_elementalMode = ElementalMode()