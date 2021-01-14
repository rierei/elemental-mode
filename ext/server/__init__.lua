local ElementalMode = class('ElementalMode')

local ModeConfig = require('__shared/mode-config')

function ElementalMode:__init()
    self:RegisterVars()
    self:RegisterEvents()
end

function ElementalMode:RegisterVars()
    self.m_squadMode = false

    self.m_sequentialCounter = {}

    self.m_getElementFunctions = {
        [1] = self.GetElementClass,
        [2] = self.GetElementSquad,
        [3] = self.GetElementSequential,
        [4] = self.GetElementRandom
    }

    self.m_verbose = 1 -- prints debug information
end

function ElementalMode:RegisterEvents()
    Events:Subscribe('Level:Loaded', function(_, p_mode)
        if
            p_mode == 'SquadRush0' or
            p_mode == 'SquadDeathMatch0'
        then
            self.m_squadMode = true
        else
            self.m_squadMode = false
        end

        self.m_currentMode = p_mode
    end)

    Events:Subscribe('Level:Destroy', function(p_player)
        self.m_sequentialCounter = {}
    end)

    if ModeConfig.selection == 1 then
        Events:Subscribe('Player:Respawn', function(p_player)
            if p_player.soldier.isManDown then
                return
            end

            self:Customize(p_player)
        end)
    else
        NetEvents:Subscribe('ElementalMode:Secondary', function(p_player, p_element)
            if self.m_verbose >= 1 then
                print('NetEvent ElementalMode:Secondary')
                print(p_element)
            end

            self:Customize(p_player, p_element)
        end)
    end
end

-- customising player on respawn
function ElementalMode:Customize(p_player, p_secondary)
    local s_element = self:GetElement(p_player)
    local s_secondary = p_secondary

    if ModeConfig.selection == 1 then
        s_secondary = s_element
    elseif ModeConfig.selection == 2 then
        s_secondary = s_element
        s_element = p_secondary
    end

    if self.m_verbose >= 1 then
        print('Elemental:Customize')
        print(s_element)
        print(s_secondary)
    end

    Events:Dispatch('ElementalFight:Customize', p_player.guid, s_element, s_secondary)
end

function ElementalMode:GetElement(p_player)
    local s_function = self.m_getElementFunctions[ModeConfig.mode]
    local s_element = s_function(self, p_player)

    return s_element
end

-- getting class element
function ElementalMode:GetElementClass(p_player)
    local s_customization = VeniceSoldierCustomizationAsset(p_player.customization)
    local _, _, s_kitName = s_customization.name:match('([^,]+)/([^,]+)/([^,]+)')
    s_kitName = s_kitName:sub(3)

    local s_element = ModeConfig.classes[s_kitName]

    if self.m_verbose >= 1 then
        print('GetElement:Class')
        print(s_kitName)
    end

    return s_element
end

-- getting squad element
function ElementalMode:GetElementSquad(p_player)
    local s_count = #ModeConfig.elements
    local s_squad = p_player.squadId

    if self.m_squadMode then
        s_squad = p_player.teamId
    end

    local s_index = s_squad % s_count + 1
    local s_element = ModeConfig.elements[s_index]

    if self.m_verbose >= 1 then
        print('GetElement:Squad')
        print(s_squad)
    end

    return s_element
end

-- getting sequential element
function ElementalMode:GetElementSequential(p_player)
    local s_counter = self.m_sequentialCounter[p_player.guid:ToString('D')]
    if s_counter == nil then
        s_counter = 0
    end

    local s_count = #ModeConfig.elements
    local s_sequential = s_counter % s_count + 1
    local s_element = ModeConfig.elements[s_sequential]

    self.m_sequentialCounter[p_player.guid:ToString('D')] = s_counter + 1

    if self.m_verbose >= 1 then
        print('GetElement:Sequential')
        print(s_sequential)
    end

    return s_element
end

-- getting random element
function ElementalMode:GetElementRandom()
    local s_count = #ModeConfig.elements
    local s_random = MathUtils:GetRandomInt(1, s_count)
    local s_element = ModeConfig.elements[s_random]

    if self.m_verbose >= 1 then
        print('GetElement:Random')
        print(s_random)
    end

    return s_element
end

g_elementalFight = ElementalMode()