-- 1 = class
-- 2 = squad
-- 3 = sequential
-- 4 = random
local mode = 1

-- 1 = primary
-- 2 = secondary
local selection = 2

local elements = {
    'neutral',
    'water',
    'fire',
    'grass',
}

local classes = {
    Assault = 'water',
    Engineer = 'fire',
    Support = 'neutral',
    Recon = 'grass'
}

return {
    mode = mode,
    selection = selection,
    elements = elements,
    classes = classes
}