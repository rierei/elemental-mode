local ElementalMode = class('ElementalMode')

function ElementalMode:__init()
    self:RegisterVars()
    self:RegisterEvents()
end

function ElementalMode:RegisterVars()
    -- 1 = class
    -- 2 = squad
    -- 3 = sequential
    -- 4 = random
    self.m_mode = 1

    self.m_elementNames = {
        'neutral',
        'water',
        'fire',
        'grass',
    }

    self.m_classElements = {
        Assault = 'water',
        Engineer = 'fire',
        Support = 'neutral',
        Recon = 'grass'
    }

    self.m_sequentialCounter = 1

    self.m_getElementFunctions = {
        [1] = self.GetElementClass,
        [2] = self.GetElementSquad,
        [3] = self.GetElementSequential,
        [4] = self.GetElementRandom
    }

    self.m_verbose = 1 -- prints debug information
end

function ElementalMode:RegisterEvents()
    Events:Subscribe('Player:Respawn', function (p_player)
        self:_PlayerRespawn(p_player)
    end)
end

-- customising player on respawn
function ElementalMode:_PlayerRespawn(p_player)
    local s_element = self:GetElement(p_player)

    if self.m_verbose >= 1 then
        print('Event Player:Respawn')
        print(s_element)
    end

    Events:Dispatch('ElementalFight:Customize', p_player.guid, s_element, 'water')
end

function ElementalMode:GetElement(p_player)
    local s_function = self.m_getElementFunctions[self.m_mode]
    local s_element = s_function(self, p_player)

    return s_element
end

-- getting class element
function ElementalMode:GetElementClass(p_player)
    local s_customization = VeniceSoldierCustomizationAsset(p_player.customization)
    _, _, s_kitName = s_customization.name:match('([^,]+)/([^,]+)/([^,]+)')
    s_kitName = s_kitName:sub(3)

    local s_element = self.m_classElements[s_kitName]

    return s_element
end

-- getting squad element
function ElementalMode:GetElementSquad(p_player)
    local s_count = #self.m_elementNames
    local s_squad = p_player.squadId
    local s_index = s_squad % s_count + 1
    local s_element = self.m_elementNames[s_index]

    return s_element
end

-- getting sequential element
function ElementalMode:GetElementSequential()
    local s_element = self.m_elementNames[self.m_sequentialCounter]
    self.m_sequentialCounter = self.m_sequentialCounter % #self.m_elementNames + 1

    return s_element
end

-- getting random element
function ElementalMode:GetElementRandom()
    local s_count = #self.m_elementNames
    local s_random = MathUtils:GetRandomInt(1, s_count)
    local s_element = self.m_elementNames[s_random]

    return s_element
end

g_elementalFight = ElementalMode()