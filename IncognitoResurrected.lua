---------------------------------------------------------------------
-- Incognito Resurrected  2.0.1
-- Native ADDON_LOADED / PLAYER_LOGIN (no Ace3).
-- Settings live in IncognitoResurrectedDB (global vs per-character).
-- AceDB (1.5.x) and Incognito2DB (beta) are rebuilt on first load.
---------------------------------------------------------------------
local ADDON_NAME, ns = ...

local I2 = ns.IncognitoResurrected or {}
ns.IncognitoResurrected = I2
_G.IncognitoResurrected = I2

I2.addonName = ADDON_NAME
I2.version = "2.0.1"
I2.SCHEMA_VERSION = 2

-- SavedVariables flags must be 1/0. Forever (and some Retail builds)
-- drop or fail to persist Lua true/false boolean keys.
I2.flagKeys = {
    enable = true,
    guild = true,
    party = true,
    dungeon = true,
    raid = true,
    battleground = true,
    arena = true,
    world_chat = true,
    debug = true,
    community = true,
    hideOnMatchingCharName = true,
    colorizePrefix = true
}

I2.defaults = {
    enable = 1,
    name = "",
    guild = 1,
    party = 0,
    dungeon = 0,
    raid = 0,
    battleground = 0,
    arena = 0,
    world_chat = 0,
    debug = 0,
    channel = nil,
    community = 0,
    hideOnMatchingCharName = 1,
    partialMatchMode = "disabled",
    bracketStyle = "paren",
    colorizePrefix = 1
}

local IGNORE_SYMBOLS = "/!#@?"

---------------------------------------------------------------------
-- Locale
---------------------------------------------------------------------
local function BuildLocale()
    local locales = ns.locales or {}
    local gameLocale = GetLocale()
    local fallback = locales.enUS or {}
    local current = locales[gameLocale] or fallback
    return setmetatable({}, {
        __index = function(_, key)
            return current[key] or fallback[key] or key
        end
    })
end
I2.L = BuildLocale()

---------------------------------------------------------------------
-- Flavor / capability detection
-- Forever shares Midnight (mainline) UI: secret values, C_ChatInfo,
-- C_RestrictedActions. Detect capabilities first, TOC second.
---------------------------------------------------------------------
function I2:DetectFlavor()
    local _, _, _, toc = GetBuildInfo()
    toc = toc or 0
    local hasCChatInfo = type(C_ChatInfo) == "table" and
                             type(C_ChatInfo.SendChatMessage) == "function"
    local hasCClub = type(C_Club) == "table" and
                         type(C_Club.SendMessage) == "function"
    local hasSecrets = type(issecretvalue) == "function"
    local hasRestricted = type(C_RestrictedActions) == "table" and
                              type(C_RestrictedActions.GetAddOnRestrictionState) ==
                              "function"
    local flavor = {
        toc = toc,
        classicEra = toc > 0 and toc < 16000,
        forever = toc >= 16000 and toc < 20000,
        mopClassic = toc >= 50000 and toc < 110000,
        retailTWW = toc >= 110000 and toc < 120000,
        midnightOrForever = toc >= 120000 or (toc >= 16000 and toc < 20000) or
            hasSecrets,
        hasCChatInfo = hasCChatInfo,
        hasCClub = hasCClub,
        hasSecrets = hasSecrets,
        hasRestrictedActions = hasRestricted,
        hasInstanceChat = ChatTypeInfo and ChatTypeInfo["INSTANCE_CHAT"] ~= nil,
        hasArenas = toc >= 16000,
        -- EditBox pre-hook whenever C_ChatInfo exists (MoP / Retail / Forever).
        -- Never replace C_ChatInfo.SendChatMessage on those clients.
        useEditBoxHook = hasCChatInfo,
        useTableSwap = not hasCChatInfo,
        -- Skip SetText while restricted: TWW 11+, Midnight, Forever.
        skipWhenRestricted = toc >= 110000 or hasRestricted or hasSecrets
    }
    self.flavor = flavor
    return flavor
end

function I2:IsModernRetail()
    local f = self.flavor or self:DetectFlavor()
    return f.skipWhenRestricted
end

function I2:IsRetailAPI()
    local f = self.flavor or self:DetectFlavor()
    return f.hasCChatInfo
end

function I2:HasArenas()
    local f = self.flavor or self:DetectFlavor()
    return f.hasArenas
end

---------------------------------------------------------------------
-- Secret-value guards (Retail Midnight + Forever)
-- Tainted code cannot compare, match, or take the length of secrets.
---------------------------------------------------------------------
-- Fast path: clients without issecretvalue never pay the secret check.
function I2.IsSecret(value)
    local flavor = I2.flavor
    if flavor and not flavor.hasSecrets then return false end
    return type(issecretvalue) == "function" and issecretvalue(value)
end

function I2.Usable(value)
    if type(value) ~= "string" then return false end
    local flavor = I2.flavor
    if flavor and not flavor.hasSecrets then return true end
    if type(issecretvalue) ~= "function" then return true end
    if issecretvalue(value) then
        return type(canaccessvalue) == "function" and canaccessvalue(value) or
                   false
    end
    return true
end

function I2.CanUseString(value)
    return I2.Usable(value)
end

---------------------------------------------------------------------
-- Database
---------------------------------------------------------------------
local function CopyDefaults(src)
    if CopyTable then return CopyTable(src) end
    local dst = {}
    for k, v in pairs(src) do
        if type(v) == "table" then
            dst[k] = CopyDefaults(v)
        else
            dst[k] = v
        end
    end
    return dst
end

local function ApplyDefaults(profile, defaults)
    for k, v in pairs(defaults) do
        if profile[k] == nil then
            if type(v) == "table" then
                profile[k] = CopyDefaults(v)
            else
                profile[k] = v
            end
        end
    end
end

function I2.IsFlag(value)
    return value == 1 or value == true
end

function I2:GetFlag(key)
    local profile = self._profile or self:GetProfile()
    return profile and self.IsFlag(profile[key]) or false
end

function I2:SetFlag(key, on)
    local profile = self._profile or self:GetProfile()
    if not profile then return end
    profile[key] = (on == true or on == 1) and 1 or 0
    self:RebuildSendCache()
end

function I2:NormalizeFlags(profile)
    if not profile then return end
    for key in pairs(self.flagKeys) do
        if profile[key] ~= nil then
            profile[key] = self.IsFlag(profile[key]) and 1 or 0
        end
    end
end

I2.GLOBAL_PROFILE_NAME = "Default"

function I2:GetCharacterProfileName()
    local name = UnitName("player")
    local realm = GetRealmName()
    if not self.CanUseString(name) or name == "" then
        name = "Unknown"
    end
    if not self.CanUseString(realm) or not realm or realm == "" then
        realm = "Realm"
    end
    return name .. " - " .. realm
end

function I2:CopyProfileData(src)
    local dst = CopyDefaults(self.defaults)
    if type(src) ~= "table" then return dst end
    if type(src.name) == "string" then dst.name = src.name end
    if type(src.channel) == "string" then dst.channel = src.channel end
    if type(src.bracketStyle) == "string" and src.bracketStyle ~= "" then
        dst.bracketStyle = src.bracketStyle
    end
    if type(src.partialMatchMode) == "string" then
        dst.partialMatchMode = src.partialMatchMode
    end
    for key in pairs(self.flagKeys) do
        if src[key] ~= nil then
            dst[key] = self.IsFlag(src[key]) and 1 or 0
        end
    end
    return dst
end

function I2:HasUsableProfiles(db)
    if type(db) ~= "table" or type(db.profiles) ~= "table" then return false end
    for _, profile in pairs(db.profiles) do
        if type(profile) == "table" and type(profile.name) == "string" and
            profile.name ~= "" then
            return true
        end
    end
    return false
end

function I2:IsCurrentSchema(db)
    return type(db) == "table" and type(db.global) == "table" and
               db.global.schemaVersion == self.SCHEMA_VERSION
end

function I2:AdoptDatabase(src)
    local db = {
        global = {
            useGlobalProfile = 1,
            schemaVersion = self.SCHEMA_VERSION,
            migrated = 1
        },
        profiles = {}
    }
    if type(src) == "table" and type(src.global) == "table" then
        db.global.useGlobalProfile =
            self.IsFlag(src.global.useGlobalProfile) and 1 or 0
    end
    if type(src) == "table" and type(src.profiles) == "table" then
        for name, profile in pairs(src.profiles) do
            if type(name) == "string" and type(profile) == "table" then
                db.profiles[name] = self:CopyProfileData(profile)
            end
        end
    end
    if not db.profiles[self.GLOBAL_PROFILE_NAME] then
        db.profiles[self.GLOBAL_PROFILE_NAME] = CopyDefaults(self.defaults)
    end
    return db
end

function I2:MigrateFromAceDB(ace)
    return self:AdoptDatabase(ace)
end

function I2:EnsureSavedVariables()
    if self._dbReady and type(IncognitoResurrectedDB) == "table" then
        return IncognitoResurrectedDB
    end

    local ace = rawget(_G, "IncognitoResurrectedDB")
    local beta = rawget(_G, "Incognito2DB")
    local db

    if self:IsCurrentSchema(ace) then
        db = ace
    elseif self:HasUsableProfiles(beta) then
        db = self:AdoptDatabase(beta)
        self._dbSource = "Incognito2DB"
    elseif type(ace) == "table" and type(ace.profiles) == "table" then
        db = self:MigrateFromAceDB(ace)
        self._dbSource = "AceDB"
    elseif type(beta) == "table" then
        db = self:AdoptDatabase(beta)
        self._dbSource = "Incognito2DB"
    else
        db = {
            global = {
                useGlobalProfile = 1,
                schemaVersion = self.SCHEMA_VERSION,
                migrated = 1
            },
            profiles = {}
        }
        self._dbSource = "new"
    end

    db.global = db.global or {}
    if db.global.useGlobalProfile == nil then
        db.global.useGlobalProfile = 1
    end
    db.global.useGlobalProfile = self.IsFlag(db.global.useGlobalProfile) and 1 or
                                     0
    db.global.schemaVersion = self.SCHEMA_VERSION
    db.global.migrated = 1
    db.profiles = db.profiles or {}
    -- Drop AceDB leftovers so Forever/Retail persist the new 1/0 schema.
    db.profileKeys = nil
    db.profile = nil
    if db.profiles[self.GLOBAL_PROFILE_NAME] then
        self:NormalizeFlags(db.profiles[self.GLOBAL_PROFILE_NAME])
    end

    IncognitoResurrectedDB = db
    self._dbReady = true
    return IncognitoResurrectedDB
end

function I2:IsUsingGlobalProfile()
    self:EnsureSavedVariables()
    return self.IsFlag(IncognitoResurrectedDB.global.useGlobalProfile)
end

function I2:GetActiveProfileName()
    if self:IsUsingGlobalProfile() then
        return self.GLOBAL_PROFILE_NAME
    end
    return self:GetCharacterProfileName()
end

function I2:GetOrCreateProfile(profileName, seed)
    self:EnsureSavedVariables()
    local profiles = IncognitoResurrectedDB.profiles
    if not profiles[profileName] then
        profiles[profileName] = seed and CopyDefaults(seed) or
                                    CopyDefaults(self.defaults)
    end
    ApplyDefaults(profiles[profileName], self.defaults)
    self:NormalizeFlags(profiles[profileName])
    return profiles[profileName]
end

function I2:SelectActiveProfile()
    self:EnsureSavedVariables()
    local defaultProfile = self:GetOrCreateProfile(self.GLOBAL_PROFILE_NAME)
    if self:IsUsingGlobalProfile() then
        self._profile = defaultProfile
    else
        self._profile = self:GetOrCreateProfile(self:GetCharacterProfileName(),
                                                defaultProfile)
    end
    self._dbSource = self._dbSource or "IncognitoResurrectedDB"
    self._activeProfileName = self:GetActiveProfileName()
    self:RebuildSendCache()
    return self._profile
end

function I2:SetUseGlobalProfile(on)
    self:EnsureSavedVariables()
    IncognitoResurrectedDB.global.useGlobalProfile =
        (on == true or on == 1) and 1 or 0
    self:SelectActiveProfile()
    self:NotifyOptionsChanged()
    local L = self.L
    if self:IsUsingGlobalProfile() then
        self:Print(L.profileNowGlobal)
    else
        self:Print(L.profileNowCharacter .. self:GetCharacterProfileName())
    end
end

function I2:BindDatabase()
    self:SelectActiveProfile()
end

function I2:GetProfile()
    if self._profile then return self._profile end
    self:BindDatabase()
    return self._profile
end

function I2:NotifyOptionsChanged()
    self:RebuildSendCache()
    if self.RefreshOptionsPanel then
        self:RefreshOptionsPanel()
    end
end

function I2:InvalidateWorldState()
    self._instanceDirty = true
    self._restricted = nil
end

---------------------------------------------------------------------
-- Output
---------------------------------------------------------------------
function I2:Print(msg)
    local frame = DEFAULT_CHAT_FRAME or ChatFrame1
    if frame then
        frame:AddMessage("|cff33ff99Incognito|r: " .. tostring(msg))
    end
end

function I2:Debug(msg)
    if self:GetFlag("debug") then
        self:Print(msg)
    end
end

-- Compat alias used by chat hooks
function I2:Safe_Print(msg)
    self:Debug(msg)
end

---------------------------------------------------------------------
-- Prefix policy
-- One decision path for every outgoing send (Classic wrap + Retail editbox).
---------------------------------------------------------------------
local BRACKETS = {
    paren = {"(", ")"},
    square = {"[", "]"},
    curly = {"{", "}"},
    angle = {"<", ">"}
}

local INSTANCE_TOGGLE = {
    pvp = "battleground",
    arena = "arena",
    party = "dungeon",
    raid = "raid"
}

local NAME_MATCH = {
    start = function(character, configured)
        return character:sub(1, #configured) == configured
    end,
    anywhere = function(character, configured)
        return character:find(configured, 1, true) ~= nil
    end,
    ["end"] = function(character, configured)
        return character:sub(-#configured) == configured
    end
}

function I2:GetCharacterName()
    if self.characterName and self.characterName ~= "" then
        return self.characterName
    end
    local name = UnitName("player")
    if self.CanUseString(name) and name ~= "" then
        self.characterName = name
    end
    return self.characterName
end

function I2:RebuildSendCache()
    local profile = self._profile or (self.GetProfile and self:GetProfile())
    if not profile then
        self.sendCache = {enable = false, colorize = false}
        return self.sendCache
    end
    local named
    if type(profile.channel) == "string" and profile.channel ~= "" then
        named = {}
        for raw in profile.channel:gmatch("([^,]+)") do
            local entry = strtrim(raw)
            if entry ~= "" then
                named[strupper(entry)] = true
            end
        end
    end
    local name = profile.name or ""
    local pair = BRACKETS[profile.bracketStyle] or BRACKETS.paren
    local prefix = pair[1] .. name .. pair[2] .. ": "
    self.sendCache = {
        enable = self.IsFlag(profile.enable),
        colorize = self.IsFlag(profile.colorizePrefix),
        community = self.IsFlag(profile.community),
        world = self.IsFlag(profile.world_chat),
        guild = self.IsFlag(profile.guild),
        party = self.IsFlag(profile.party),
        dungeon = self.IsFlag(profile.dungeon),
        raid = self.IsFlag(profile.raid),
        bg = self.IsFlag(profile.battleground),
        arena = self.IsFlag(profile.arena),
        hide = self:ShouldHideForCharacterName(),
        name = name,
        prefix = prefix,
        prefixLen = #prefix,
        named = named
    }
    return self.sendCache
end

function I2:GetSendCache()
    return self.sendCache or self:RebuildSendCache()
end

function I2:GetNamePrefix()
    return self:GetSendCache().prefix or self:RebuildSendCache().prefix
end

function I2:TextAlreadyPrefixed(text)
    if not self.Usable(text) then return false end
    local cache = self:GetSendCache()
    local prefixLen = cache.prefixLen or 0
    return prefixLen > 0 and #text >= prefixLen and
               text:sub(1, prefixLen) == cache.prefix
end

function I2:StripOwnPrefix(text)
    if not self.Usable(text) then return text end
    local cache = self:GetSendCache()
    local prefixLen = cache.prefixLen or 0
    if prefixLen > 0 and #text >= prefixLen and text:sub(1, prefixLen) ==
        cache.prefix then
        return text:sub(prefixLen + 1)
    end
    return text
end

function I2:HasLeadingIgnoreSymbol(text)
    if not self.Usable(text) then return false end
    local first = text:match("^%s*(.)")
    return first ~= nil and IGNORE_SYMBOLS:find(first, 1, true) ~= nil
end

function I2:ShouldHideForCharacterName()
    local profile = self:GetProfile()
    if not profile or not self.IsFlag(profile.hideOnMatchingCharName) then
        return false
    end
    local configured = profile.name
    local character = self:GetCharacterName()
    if not self.Usable(configured) or configured == "" then return false end
    if not self.Usable(character) then return false end
    local configuredLower = configured:lower()
    local characterLower = character:lower()
    if configuredLower == characterLower then return true end
    local matcher = NAME_MATCH[profile.partialMatchMode or "disabled"]
    return matcher ~= nil and matcher(characterLower, configuredLower)
end

function I2:GetChannelNameSafe(target)
    if target == nil or type(GetChannelName) ~= "function" then return nil end
    local ok, _, chname = pcall(GetChannelName, target)
    if ok and self.Usable(chname) then return chname end
    return nil
end

function I2:GetInstanceTypeSafe()
    if self._instanceDirty == false then return self._instanceType end
    self._instanceDirty = false
    if type(GetInstanceInfo) ~= "function" then
        self._instanceType = nil
        return nil
    end
    local ok, _, instanceType = pcall(GetInstanceInfo)
    self._instanceType = (ok and self.Usable(instanceType)) and instanceType or
                             nil
    return self._instanceType
end

function I2:CommunityIdsFromTarget(target)
    local channelName = self:GetChannelNameSafe(target)
    if not channelName then return nil, nil end
    return channelName:match("^Community:([^:]+):(.+)$")
end

function I2:ChannelAllowsPrefix(chatType, target)
    if not self.Usable(chatType) then return false end
    local cache = self:GetSendCache()
    if chatType == "GUILD" or chatType == "OFFICER" then
        return cache.guild
    end
    if chatType == "RAID" then return cache.raid end
    if chatType == "INSTANCE_CHAT" then
        local toggle = INSTANCE_TOGGLE[self:GetInstanceTypeSafe() or ""]
        if toggle == "battleground" then return cache.bg end
        if toggle == "arena" then return cache.arena end
        if toggle == "dungeon" then return cache.dungeon end
        if toggle == "raid" then return cache.raid end
        return false
    end
    if chatType == "PARTY" then
        local instanceType = self:GetInstanceTypeSafe()
        if instanceType == "pvp" or instanceType == "arena" then return false end
        if instanceType == "party" then return cache.dungeon end
        return cache.party
    end
    if chatType == "CHANNEL" then
        local channelName = self:GetChannelNameSafe(target)
        if cache.community and channelName and
            channelName:find("^Community:", 1, true) then
            return true
        end
        if cache.world then return true end
        return channelName ~= nil and cache.named ~= nil and
                   cache.named[strupper(channelName)] ~= nil
    end
    return false
end

function I2:CanAttachPrefix(text)
    local cache = self:GetSendCache()
    if not cache.enable then return false end
    if text == nil then return false end
    if cache.hide or cache.name == "" then return false end
    if self.Usable(text) then
        if text == "" then return false end
        return not self:HasLeadingIgnoreSymbol(text)
    end
    -- Secret editbox text cannot be inspected. Concatenation is allowed.
    return true
end

function I2:AttachPrefix(text, chatType, target)
    if not self:CanAttachPrefix(text) then return text, false end
    if not self:ChannelAllowsPrefix(chatType, target) then return text, false end
    local cache = self.sendCache or self:GetSendCache()
    if self.Usable(text) then
        if cache.prefixLen > 0 and #text >= cache.prefixLen and
            text:sub(1, cache.prefixLen) == cache.prefix then
            return text, false
        end
    end
    return cache.prefix .. text, true
end

---------------------------------------------------------------------
-- Engine gate
---------------------------------------------------------------------
function I2:ShouldActivate()
    return true
end

function I2:IsActive()
    return self._enabled and true or false
end

---------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------
function I2:PrintHelp()
    local L = self.L
    self:Print(L.helpHeader)
    self:Print(L.helpOpen)
    self:Print(L.helpHelp)
    self:Print(L.helpName)
    self:Print(L.helpDebug)
end

function I2:SlashCommand(input)
    input = strtrim(input or "")
    local cmd, rest = input:match("^(%S+)%s*(.*)$")
    cmd = cmd and cmd:lower() or ""
    local L = self.L
    if cmd == "help" then
        self:PrintHelp()
        return
    elseif cmd == "name" then
        local newName = rest:match('^"(.-)"$') or rest
        if newName and newName ~= "" then
            self:GetProfile().name = newName
            self:NotifyOptionsChanged()
            self:Print(L.nameSet .. "|cFF00FF00" .. newName .. "|r")
        else
            self:Print(L.nameUsage)
        end
        return
    elseif cmd == "debug" then
        local on = not self:GetFlag("debug")
        self:SetFlag("debug", on)
        self:NotifyOptionsChanged()
        self:Print(on and L.debugOn or L.debugOff)
        return
    end
    self:OpenOptions()
end

function I2:RegisterSlashCommands()
    if self._slashRegistered then return end
    SLASH_INCOGNITORE1 = "/inc"
    SLASH_INCOGNITORE2 = "/incognito"
    SLASH_INCOGNITORE3 = "/inc2"
    SLASH_INCOGNITORE4 = "/incognito2"
    SlashCmdList["INCOGNITORE"] = function(msg)
        I2:SlashCommand(msg)
    end
    self._slashRegistered = true
end

---------------------------------------------------------------------
-- Lifecycle — called from the native event frame below
---------------------------------------------------------------------
function I2:OnAddonLoaded()
    if self._loaded then return end
    self:DetectFlavor()
    self:BindDatabase()
    self:GetCharacterName()
    self:RegisterSlashCommands()
    self._loaded = true
    if self.CreateOptionsPanel then
        pcall(self.CreateOptionsPanel, self)
    end
    self:Debug("Loaded (" .. (self._dbSource or "?") .. ") toc=" ..
                   tostring(self.flavor.toc) .. " secrets=" ..
                   tostring(self.flavor.hasSecrets) .. " editBox=" ..
                   tostring(self.flavor.useEditBoxHook))
end

function I2:OnPlayerLogin()
    if self._loginHandled then return end
    self._loginHandled = true
    self:GetCharacterName()
    self:Enable()
    self:Print(self.L.Loaded)
end

function I2:Enable()
    if self._enabled then return end
    self:InvalidateWorldState()
    self:RebuildSendCache()
    if self.RegisterChatFilters then
        self:RegisterChatFilters()
    end
    if self.InstallChatHooks then
        self:InstallChatHooks()
    end
    self._prefixEnabled = true
    self._enabled = true
end

function I2:Disable()
    if not self._enabled then return end
    self._prefixEnabled = false
    if self.RemoveChatHooks then
        self:RemoveChatHooks()
    end
    if self.UnregisterChatFilters then
        self:UnregisterChatFilters()
    end
    self._enabled = false
end

---------------------------------------------------------------------
-- Native events (not AceEvent / AceAddon)
---------------------------------------------------------------------
local eventFrame = CreateFrame("Frame", "IncognitoResurrectedEventFrame")
I2.eventFrame = eventFrame

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
if C_EventUtils and C_EventUtils.IsEventValid and
    C_EventUtils.IsEventValid("ADDON_RESTRICTION_STATE_CHANGED") then
    eventFrame:RegisterEvent("ADDON_RESTRICTION_STATE_CHANGED")
else
    pcall(eventFrame.RegisterEvent, eventFrame, "ADDON_RESTRICTION_STATE_CHANGED")
end
eventFrame:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= ADDON_NAME then return end
        I2:OnAddonLoaded()
        if IsLoggedIn() then
            I2:OnPlayerLogin()
        end
    elseif event == "PLAYER_LOGIN" then
        I2:OnPlayerLogin()
    elseif event == "PLAYER_ENTERING_WORLD" or event ==
        "ADDON_RESTRICTION_STATE_CHANGED" then
        I2:InvalidateWorldState()
        if I2._loaded then
            I2:RebuildSendCache()
        end
    end
end)
