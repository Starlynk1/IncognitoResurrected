---------------------------------------------------------------------
-- Instanced.lua
-- Instance detection library for handling taint-sensitive instances
-- 
-- Purpose:
-- Provides unified instance type detection to determine when addon
-- hooks need to be disabled to prevent taint in combat scenarios.
-- Only used in Retail where Secret API taint is a concern.
---------------------------------------------------------------------
local Instanced = {}

---------------------------------------------------------------------
-- Instance Type Detection
---------------------------------------------------------------------

-- Check if player is in a combat-related instance that requires taint protection
-- Returns true for: dungeons (party), mythic+, raids, pvp (battlegrounds), arenas
-- Returns false for: scenarios, world
function Instanced:IsInCombatInstance()
    local _, instanceType = GetInstanceInfo()

    -- Table-based switch for combat instance types
    local combatInstances = {
        party = true, -- 5-man dungeons and mythic+
        raid = true, -- raids (all difficulties including LFR)
        pvp = true, -- battlegrounds
        arena = true -- arenas
    }

    return combatInstances[instanceType] or false
end

-- Get current instance type and combat instance status
function Instanced:GetInstanceInfo()
    local name, instanceType, difficultyID, difficultyName, maxPlayers,
          dynamicDifficulty, isDynamic, instanceID, instanceGroupSize,
          LfgDungeonID = GetInstanceInfo()

    local isInCombatInstance = self:IsInCombatInstance()

    return {
        name = name,
        instanceType = instanceType,
        difficultyID = difficultyID,
        difficultyName = difficultyName,
        maxPlayers = maxPlayers,
        isInCombatInstance = isInCombatInstance,
        instanceID = instanceID
    }
end

-- Get a human-readable description of the current instance
function Instanced:GetInstanceDescription()
    local info = self:GetInstanceInfo()

    -- Table-based switch for instance descriptions
    local descriptions = {
        none = function() return "World" end,
        party = function()
            return "Dungeon" ..
                       (info.difficultyName and " (" .. info.difficultyName ..
                           ")" or "")
        end,
        raid = function()
            return "Raid" ..
                       (info.difficultyName and " (" .. info.difficultyName ..
                           ")" or "")
        end,
        pvp = function()
            return "Battleground" ..
                       (info.name and " (" .. info.name .. ")" or "")
        end,
        arena = function() return "Arena" end,
        scenario = function() return "Scenario" end
    }

    local descFunc = descriptions[info.instanceType]
    if descFunc then
        return descFunc()
    else
        return info.instanceType or "Unknown"
    end
end

---------------------------------------------------------------------
-- Registration as LibStub for other addons
---------------------------------------------------------------------
local MAJOR, MINOR = "Instanced", 1
local InstancedLib = LibStub:NewLibrary(MAJOR, MINOR)

if not InstancedLib then return end

-- Copy all functions to the library table
for k, v in pairs(Instanced) do InstancedLib[k] = v end

return InstancedLib
