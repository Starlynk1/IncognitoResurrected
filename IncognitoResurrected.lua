--  Version: 1.5.1
IncognitoResurrected = LibStub("AceAddon-3.0"):NewAddon("IncognitoResurrected",
                                                        "AceConsole-3.0",
                                                        "AceEvent-3.0");
--  Localization
local L = LibStub("AceLocale-3.0"):GetLocale("IncognitoResurrected", true)
local ChatCompat = LibStub("ChatCompat")
--  Main Section
local Options = {
    name = "Incognito Resurrected",
    type = "group",
    args = {
        generalSettings = {
            name = "General Settings",
            type = "group",
            inline = true,
            order = 0,
            get = function(item)
                return IncognitoResurrected.db.profile[item[#item]]
            end,
            set = function(item, value)
                IncognitoResurrected.db.profile[item[#item]] = value
            end,
            args = {
                name = {
                    order = 1,
                    type = "input",
                    width = "normal",
                    name = L["name"],
                    desc = L["name_desc"]
                },
                spacerName = {
                    order = 1.2,
                    type = "description",
                    width = 0.5,
                    name = ""
                },
                enable = {
                    order = 1.5,
                    type = "toggle",
                    name = L["enable"],
                    desc = L["enable_desc"],
                    width = 1.5
                },
                colorizePrefix = {
                    order = 2,
                    type = "toggle",
                    name = "Color Name by class",
                    desc = "Color the Incognito Name with the sender's class color.",
                    width = 1.5
                },
                hideOnMatchingCharName = {
                    order = 2.5,
                    type = "toggle",
                    name = L["hideOnMatchingCharName"],
                    desc = L["hideOnMatchingCharName_desc"],
                    width = 1.5
                },
                partialMatchMode = {
                    order = 4,
                    type = "select",
                    name = L["partialMatchMode"],
                    desc = L["partialMatchMode_desc"],
                    values = {
                        disabled = L["partialMatchMode_disabled"],
                        start = L["partialMatchMode_start"],
                        anywhere = L["partialMatchMode_anywhere"],
                        ["end"] = L["partialMatchMode_end"]
                    },
                    sorting = {"disabled", "start", "anywhere", "end"},
                    width = "normal",
                    disabled = function()
                        return not IncognitoResurrected.db.profile
                                   .hideOnMatchingCharName
                    end
                },
                spacerBracket = {
                    order = 4.2,
                    type = "description",
                    width = 0.5,
                    name = ""
                },
                bracketStyle = {
                    order = 4.5,
                    type = "select",
                    name = L["bracketStyle"],
                    desc = L["bracketStyle_desc"],
                    values = {
                        paren = "(round)",
                        square = "[square]",
                        curly = "{curly}",
                        angle = "<angle>"
                    },
                    width = "normal"
                },
                specialCharsInfo = {
                    order = 5,
                    type = "description",
                    width = "full",
                    name = "|cFFFFA500Messages starting with / ! # @ ? are automatically ignored.|r"
                }
            }
        },
        generalOptions = {
            name = "Options",
            type = "group",
            inline = true,
            order = 1,
            get = function(item)
                return IncognitoResurrected.db.profile[item[#item]]
            end,
            set = function(item, value)
                IncognitoResurrected.db.profile[item[#item]] = value
            end,
            args = {
                guild = {
                    order = 1,
                    type = "toggle",
                    width = "full",
                    name = L["guild"],
                    desc = L["guild_desc"]
                },
                guildinfo = {
                    order = 1.5,
                    type = "description",
                    name = "|cFFFFA500" .. L["guildinfo"]
                },
                dungeon = {
                    order = 2,
                    type = "toggle",
                    width = 0.6,
                    name = L["dungeon"],
                    desc = L["dungeon_desc"],
                    disabled = function()
                        return IncognitoResurrected:IsModernRetail()
                    end
                },
                raid = {
                    order = 3,
                    type = "toggle",
                    width = 0.6,
                    name = L["raid"],
                    desc = L["raid_desc"],
                    disabled = function()
                        return IncognitoResurrected:IsModernRetail()
                    end
                },
                battleground = {
                    order = 5,
                    type = "toggle",
                    width = 0.6,
                    name = L["battleground"],
                    desc = L["battleground_desc"],
                    disabled = function()
                        return IncognitoResurrected:IsModernRetail()
                    end
                },
                arena = {
                    order = 5.5,
                    type = "toggle",
                    width = 0.6,
                    name = L["arena"],
                    desc = L["arena_desc"],
                    disabled = function()
                        return IncognitoResurrected:IsModernRetail()
                    end,
                    hidden = function()
                        return not IncognitoResurrected:HasArenas()
                    end
                },
                world_chat = {
                    order = 6,
                    type = "toggle",
                    width = "full",
                    name = L["world_chat"],
                    desc = L["world_chat_desc"]
                },
                world_chat_info = {
                    order = 6.5,
                    type = "description",
                    name = "|cFFFFA500" .. L["world_chat_info_desc"]
                },
                channel = {
                    order = 7,
                    type = "input",
                    name = L["channel"],
                    desc = L["channel_desc"]
                },
                channelinfo = {
                    order = 7.5,
                    type = "description",
                    name = "|cFFFFA500" .. L["channel_info_text"]
                },
                community = {
                    order = 8,
                    type = "toggle",
                    width = "full",
                    name = L["community"],
                    desc = L["community_desc"],
                    hidden = function()
                        return not IncognitoResurrected:IsRetailAPI()
                    end
                },
                communityinfo = {
                    order = 8.5,
                    type = "description",
                    name = "|cFFFFA500" .. L["community_info_text"],
                    hidden = function()
                        return not IncognitoResurrected:IsRetailAPI()
                    end
                },
                debug = {
                    order = 9,
                    type = "toggle",
                    width = "full",
                    name = L["debug"],
                    desc = L["debug_desc"]
                },
                party = {
                    order = 1.7,
                    type = "toggle",
                    width = 0.6,
                    name = L["party"],
                    desc = L["party_desc"]
                }
            }
        }
    }
}
local Defaults = {
    profile = {
        enable = true,
        name = "",
        guild = true,
        party = false,
        dungeon = false,
        raid = false,
        battleground = false,
        arena = false,
        world_chat = false,
        debug = false,
        channel = nil,
        community = false,
        hideOnMatchingCharName = true,
        partialMatchMode = "disabled",
        -- Default bracket style
        bracketStyle = "paren",
        -- Class-color the bracketed prefix in chat frames
        colorizePrefix = true
    }
}
local character_name
--  Init
function IncognitoResurrected:OnInitialize()
    -- Load our database.
    self.db = LibStub("AceDB-3.0"):New("IncognitoResurrectedDB", Defaults, true)
    -- Set up our config options.
    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
    local registry = LibStub("AceConfigRegistry-3.0")
    registry:RegisterOptionsTable("IncognitoResurrected Options", Options)
    registry:RegisterOptionsTable("IncognitoResurrected Profiles", profiles);
    local dialog = LibStub("AceConfigDialog-3.0");
    self.optionFrames = {
        main = dialog:AddToBlizOptions("IncognitoResurrected Options",
                                       "IncognitoResurrected"),
        profiles = dialog:AddToBlizOptions("IncognitoResurrected Profiles",
                                           "Profiles", "IncognitoResurrected")
    }
    -- Slash commands: /inc and /incognito open the config window
    self:RegisterChatCommand("inc", "SlashCommand")
    self:RegisterChatCommand("incognito", "SlashCommand")
    self:RegisterChatCommand("debug", "SlashDebug")
    -- Profile change callbacks — re-apply state when switching/resetting profiles
    local function onProfileChanged()
        -- Refresh the config UI so get() reads from the new profile
        LibStub("AceConfigRegistry-3.0"):NotifyChange(
            "IncognitoResurrected Options")
    end
    self.db.RegisterCallback(self, "OnProfileChanged", onProfileChanged)
    self.db.RegisterCallback(self, "OnProfileCopied", onProfileChanged)
    self.db.RegisterCallback(self, "OnProfileReset", onProfileChanged)
    self.db.RegisterCallback(self, "OnNewProfile", onProfileChanged)
    -- Store API detection flags
    self._useCChatInfo = ChatCompat.api.useCChatInfo
    self._useCClubInfo = ChatCompat.api.useCClub
    -- get current character name
    character_name, _ = UnitName("player")
    self:Safe_Print(L["Loaded"])
end
--  Event Handlers
function IncognitoResurrected:SendChatMessage(msg, chatType, language, target)
    -- Early out: ignore messages starting with special characters (after spaces)
    if self.db and self.db.profile and self.db.profile.enable and type(msg) ==
        "string" then
        local symbols = "/!#@?"
        local firstChar = msg:match("^%s*(.)")
        if firstChar and symbols:find(firstChar, 1, true) then
            ChatCompat:CallOriginalSendChatMessage(msg, chatType, language,
                                                   target)
            return
        end
    end
    if self.db.profile.enable and self.db.profile.community and chatType ==
        "CHANNEL" then
        local id, chname = GetChannelName(target)
        self:Safe_Print("Channel name: " .. (chname or "nil"))
        if chname and chname:match("^Community:") then
            local clubId, streamId = chname:match("^Community:(.-):(.-)$")
            self:Safe_Print("Parsed clubId: " .. (clubId or "nil") ..
                                ", streamId: " .. (streamId or "nil"))
            if clubId and streamId then
                self:Safe_Print(
                    "Detected community channel, calling SendMessage")
                self:SendMessage(clubId, streamId, msg)
                return
            end
        end
    end
    if self.db.profile.enable then
        if self.db.profile.name and self.db.profile.name ~= "" then
            -- Determine if we should suppress adding the prefix based on exact/partial match
            local shouldAddPrefix = true
            if self.db.profile.hideOnMatchingCharName and character_name then
                local nLower = string.lower(self.db.profile.name)
                local cLower = string.lower(character_name or "")
                if nLower == cLower then
                    shouldAddPrefix = false
                else
                    local mode = self.db.profile.partialMatchMode or "disabled"
                    if mode ~= "disabled" and #nLower > 0 then
                        if mode == "start" then
                            if cLower:sub(1, #nLower) == nLower then
                                shouldAddPrefix = false
                            end
                        elseif mode == "anywhere" then
                            if cLower:find(nLower, 1, true) ~= nil then
                                shouldAddPrefix = false
                            end
                        elseif mode == "end" then
                            if cLower:sub(-#nLower) == nLower then
                                shouldAddPrefix = false
                            end
                        end
                    end
                end
            end
            if shouldAddPrefix then
                if (self.db.profile.guild and
                    (chatType == "GUILD" or chatType == "OFFICER")) or
                    (self.db.profile.raid and chatType == "RAID") or
                    (self.db.profile.dungeon and chatType == "PARTY") or
                    self:IsInstanceChatAllowed(chatType) then
                    msg = self:GetNamePrefix() .. msg
                    -- Use World Chat Channels
                elseif self.db.profile.world_chat and chatType == "CHANNEL" then
                    msg = self:GetNamePrefix() .. msg
                    -- Use Specified Chat Channel, commas are allowed
                elseif self.db.profile.channel and chatType == "CHANNEL" then
                    for i in string.gmatch(self.db.profile.channel, '([^,]+)') do
                        local nameToMatch = strtrim(i)
                        local id, chname = GetChannelName(target)
                        if chname and strupper(nameToMatch) == strupper(chname) then
                            msg = self:GetNamePrefix() .. msg
                        end
                    end
                end
            end
        end
    end
    -- Call original function
    ChatCompat:CallOriginalSendChatMessage(msg, chatType, language, target)
end
function IncognitoResurrected:SendMessage(clubID, streamID, msg)
    self:Safe_Print("Entering SendMessage with clubID: " .. clubID ..
                        ", streamID: " .. streamID)
    if self.db and self.db.profile and self.db.profile.enable and type(msg) ==
        "string" then
        local symbols = "/!#@?"
        local firstChar = msg:match("^%s*(.)")
        if firstChar and symbols:find(firstChar, 1, true) then
            self:Safe_Print("Ignoring due to leading symbol")
            ChatCompat:CallOriginalClubSendMessage(clubID, streamID, msg)
            return
        end
    end
    if self.db.profile.enable and self.db.profile.community then
        self:Safe_Print("Community option enabled")
        local clubInfo = C_Club.GetClubInfo(clubID)
        if clubInfo then
            self:Safe_Print("Club type: " .. clubInfo.clubType)
        else
            self:Safe_Print("No clubInfo")
        end
        if clubInfo and
            (clubInfo.clubType == Enum.ClubType.BattleNet or clubInfo.clubType ==
                Enum.ClubType.Character) then
            self:Safe_Print("Is community club")
            local shouldAddPrefix = true
            if self.db.profile.hideOnMatchingCharName and character_name then
                local nLower = string.lower(self.db.profile.name or "")
                local cLower = string.lower(character_name or "")
                self:Safe_Print("Configured name lower: " .. nLower)
                self:Safe_Print("Character name lower: " .. cLower)
                if nLower == cLower then
                    shouldAddPrefix = false
                    self:Safe_Print("Names match exactly")
                else
                    local mode = self.db.profile.partialMatchMode or "disabled"
                    self:Safe_Print("Partial match mode: " .. mode)
                    if mode ~= "disabled" and #nLower > 0 then
                        if mode == "start" then
                            if cLower:sub(1, #nLower) == nLower then
                                shouldAddPrefix = false
                                self:Safe_Print("Matches start")
                            end
                        elseif mode == "anywhere" then
                            if cLower:find(nLower, 1, true) ~= nil then
                                shouldAddPrefix = false
                                self:Safe_Print("Matches anywhere")
                            end
                        elseif mode == "end" then
                            if cLower:sub(-#nLower) == nLower then
                                shouldAddPrefix = false
                                self:Safe_Print("Matches end")
                            end
                        end
                    end
                end
            end
            self:Safe_Print("shouldAddPrefix: " .. tostring(shouldAddPrefix))
            if shouldAddPrefix then
                local prefix = self:GetNamePrefix()
                self:Safe_Print("Adding prefix: " .. prefix)
                msg = prefix .. msg
            end
        end
    end
    ChatCompat:CallOriginalClubSendMessage(clubID, streamID, msg)
end
--  Functions
function IncognitoResurrected:Safe_Print(msg)
    if self.db.profile.debug then self:Print(msg) end
end
function IncognitoResurrected:IsRetailAPI()
    return type(C_ChatInfo) == "table" and type(C_ChatInfo.SendChatMessage) ==
               "function"
end

-- Returns true only on modern Retail (TWW 11.x / Midnight 12.x+) where
-- SetText() taint in combat instances causes ADDON_ACTION_FORBIDDEN.
-- MoP Classic (5.x) has C_ChatInfo but no taint restrictions.
function IncognitoResurrected:IsModernRetail()
    local _, _, _, tocVersion = GetBuildInfo()
    return tocVersion and tocVersion >= 110000
end

-- Arenas were introduced in TBC (2.0).  Classic Era (1.x) has none.
function IncognitoResurrected:HasArenas()
    local _, _, _, tocVersion = GetBuildInfo()
    return tocVersion and tocVersion >= 20000
end
---------------------------------------------------------------------
-- Slash Commands
---------------------------------------------------------------------
function IncognitoResurrected:SlashCommand(input)
    input = input and input:trim() or ""
    local cmd, rest = input:match("^(%S+)%s*(.*)$")
    cmd = cmd and cmd:lower() or ""
    if cmd == "help" then
        self:PrintHelp()
        return
    elseif cmd == "name" then
        local newName = rest:match('^"(.-)"$') or rest
        if newName and newName ~= "" then
            self.db.profile.name = newName
            self:Print("Incognito name set to: |cFF00FF00" .. newName .. "|r")
        else
            self:Print("Usage: /inc name <name>")
        end
        return
    end
    -- /inc or /incognito opens the config window
    local categoryID = self.optionFrames and self.optionFrames.main and
                           self.optionFrames.main.name
    if categoryID then Settings.OpenToCategory(categoryID) end
end

function IncognitoResurrected:SlashDebug(input)
    self.db.profile.debug = not self.db.profile.debug
    if self.db.profile.debug then
        self:Print("Debug mode |cFF00FF00enabled|r")
    else
        self:Print("Debug mode |cFFFF0000disabled|r")
    end
end
function IncognitoResurrected:GetNamePrefix()
    local style =
        (self.db and self.db.profile and self.db.profile.bracketStyle) or
            "paren"
    local pairs = {
        paren = {"(", ")"},
        square = {"[", "]"},
        curly = {"{", "}"},
        angle = {"<", ">"}
    }
    local pair = pairs[style] or pairs.paren
    return pair[1] .. (self.db.profile.name or "") .. pair[2] .. ": "
end
---------------------------------------------------------------------
-- Instance-type check for INSTANCE_CHAT
-- Maps current instance type to the corresponding user toggle.
---------------------------------------------------------------------
function IncognitoResurrected:IsInstanceChatAllowed(chatType)
    if chatType ~= "INSTANCE_CHAT" then return false end
    local _, instanceType = GetInstanceInfo()
    self:Safe_Print(
        "[Instance] type=" .. tostring(instanceType) .. " chatType=" ..
            tostring(chatType))
    if instanceType == "pvp" then
        self:Safe_Print("[Instance] BG check: battleground=" ..
                            tostring(self.db.profile.battleground))
        return self.db.profile.battleground
    elseif instanceType == "arena" then
        return self.db.profile.arena
    elseif instanceType == "party" then
        -- LFG dungeon /i chat
        return self.db.profile.dungeon
    elseif instanceType == "raid" then
        return self.db.profile.raid
    end
    return false
end
---------------------------------------------------------------------
-- Process outgoing text for EditBox hook (Retail)
-- Returns the modified text (with prefix) or the original text unchanged.
-- This is the Retail equivalent of the Classic SendChatMessage hook.
---------------------------------------------------------------------
function IncognitoResurrected:ProcessOutgoingText(text, chatType, target)
    if not self.db or not self.db.profile or not self.db.profile.enable then
        return text
    end
    if not text or text == "" or type(text) ~= "string" then return text end

    -- Ignore messages starting with special characters
    local symbols = "/!#@?"
    local firstChar = text:match("^%s*(.)")
    if firstChar and symbols:find(firstChar, 1, true) then return text end

    -- No name configured
    if not self.db.profile.name or self.db.profile.name == "" then
        return text
    end

    -- Name matching: suppress prefix if character name matches configured name
    local shouldAddPrefix = true
    if self.db.profile.hideOnMatchingCharName and character_name then
        local nLower = string.lower(self.db.profile.name)
        local cLower = string.lower(character_name or "")
        if nLower == cLower then
            shouldAddPrefix = false
        else
            local mode = self.db.profile.partialMatchMode or "disabled"
            if mode ~= "disabled" and #nLower > 0 then
                if mode == "start" then
                    if cLower:sub(1, #nLower) == nLower then
                        shouldAddPrefix = false
                    end
                elseif mode == "anywhere" then
                    if cLower:find(nLower, 1, true) ~= nil then
                        shouldAddPrefix = false
                    end
                elseif mode == "end" then
                    if cLower:sub(-#nLower) == nLower then
                        shouldAddPrefix = false
                    end
                end
            end
        end
    end
    if not shouldAddPrefix then return text end

    -- Community channels (checked before world_chat to avoid double-prefix)
    if self.db.profile.community and chatType == "CHANNEL" and target then
        local id, chname = GetChannelName(target)
        if chname and chname:match("^Community:") then
            return self:GetNamePrefix() .. text
        end
    end

    -- Standard channel types
    if (self.db.profile.guild and (chatType == "GUILD" or chatType == "OFFICER")) or
        (self.db.profile.raid and chatType == "RAID") or
        (self.db.profile.dungeon and chatType == "PARTY") or
        self:IsInstanceChatAllowed(chatType) then
        return self:GetNamePrefix() .. text
    elseif self.db.profile.world_chat and chatType == "CHANNEL" then
        return self:GetNamePrefix() .. text
    elseif self.db.profile.channel and chatType == "CHANNEL" then
        for i in string.gmatch(self.db.profile.channel, '([^,]+)') do
            local nameToMatch = strtrim(i)
            local id, chname = GetChannelName(target)
            if chname and strupper(nameToMatch) == strupper(chname) then
                return self:GetNamePrefix() .. text
            end
        end
    end

    -- Party chat prefix (disabled only in combat instances)
    if self.db.profile.party and chatType == "PARTY" then
        local _, instanceType = GetInstanceInfo()
        if instanceType ~= "pvp" and instanceType ~= "arena" then
            return self:GetNamePrefix() .. text
        end
    end

    return text
end
-- Class-color prefix rendering (client-side)
local OPEN_TO_CLOSE = {["("] = ")", ["["] = "]", ["{"] = "}", ["<"] = ">"}
local function ExtractPlayerGUID(...)
    local n = select("#", ...)
    for i = 1, n do
        local v = select(i, ...)
        if type(v) == "string" and v:match("^Player%-") then return v end
    end
end
function IncognitoResurrected:ChatPrefixColorFilter(frame, event, msg, author, ...)
    if not (self.db and self.db.profile and self.db.profile.enable and
        self.db.profile.colorizePrefix) then return false end
    -- Skip Secret Values from Midnight Retail instances
    if type(msg) ~= "string" then return false end
    if type(issecretvalue) == "function" and issecretvalue(msg) then
        return false
    end
    -- Guard against secret-value author (e.g. CHAT_MSG_CURRENCY in Midnight)
    if type(author) ~= "string" then return false end
    if type(issecretvalue) == "function" and issecretvalue(author) then
        return false
    end
    -- Match a leading bracketed name, requiring a colon after the closing bracket.
    -- Supports optional spaces before and after the colon.
    -- Examples: "(Name):msg", "(Name): msg", "(Name) :msg", "(Name) : msg"
    local pre, open, name, close, spacesAfterClose, colonSpaces, rest =
        msg:match(
            "^(%s*)([%(%[%{%<])([^%(%[%{%<%]%}%>]+)([%)%]%}%>])(%s*):(%s*)(.*)$")
    if not open then return false end
    if OPEN_TO_CLOSE[open] ~= close then return false end
    -- Resolve class color of the sender (pcall to prevent taint in Midnight)
    local guid = ExtractPlayerGUID(...)
    local classFile
    if guid and GetPlayerInfoByGUID then
        local ok, _, cf = pcall(GetPlayerInfoByGUID, guid)
        if ok then classFile = cf end
    end
    if not classFile and author and UnitClass then
        local unit = author
        if Ambiguate then
            local ok, result = pcall(Ambiguate, author, "none")
            if ok and result then unit = result end
        end
        local ok, _, cf = pcall(UnitClass, unit)
        if ok then classFile = cf end
    end
    if not classFile then return false end
    local colors =
        (type(CUSTOM_CLASS_COLORS) == "table" and CUSTOM_CLASS_COLORS) or
            RAID_CLASS_COLORS
    local c = colors and colors[classFile]
    if not c then return false end
    local hex = string.format("|cff%02x%02x%02x",
                              math.floor((c.r or 1) * 255 + 0.5),
                              math.floor((c.g or 1) * 255 + 0.5),
                              math.floor((c.b or 1) * 255 + 0.5))
    local newMsg = string.format("%s%s%s%s|r%s%s:%s%s", pre or "", open, hex,
                                 name or "", close, spacesAfterClose or "",
                                 colonSpaces or "", rest or "")
    return false, newMsg, author, ...
end
function IncognitoResurrected:_EnsureChatFilterSetup()
    if self._ChatFilterFunc then return end
    self._filterEvents = {
        "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_EMOTE",
        "CHAT_MSG_TEXT_EMOTE", "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER",
        "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID",
        "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
        "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
        "CHAT_MSG_CHANNEL", "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM"
    }
    self._ChatFilterFunc = function(frame, event, msg, author, ...)
        return IncognitoResurrected:ChatPrefixColorFilter(frame, event, msg,
                                                          author, ...)
    end
end
function IncognitoResurrected:RegisterChatFilters()
    self:_EnsureChatFilterSetup()
    if self._filtersRegistered then return end
    for _, ev in ipairs(self._filterEvents) do
        ChatFrame_AddMessageEventFilter(ev, self._ChatFilterFunc)
    end
    self._filtersRegistered = true
end
function IncognitoResurrected:UnregisterChatFilters()
    if not self._filtersRegistered then return end
    for _, ev in ipairs(self._filterEvents) do
        ChatFrame_RemoveMessageEventFilter(ev, self._ChatFilterFunc)
    end
    self._filtersRegistered = false
end
---------------------------------------------------------------------
-- Lifecycle: OnEnable / OnDisable
---------------------------------------------------------------------
function IncognitoResurrected:OnEnable()
    -- Register chat filters for class coloring
    self:RegisterChatFilters()

    -- Set up hooks based on API version
    if self._useCChatInfo then
        -- Retail: EditBox pre-hook approach.
        -- Hooks chat editbox OnKeyDown to modify outgoing text before
        -- Enter triggers Blizzard's secure send path.
        -- Skips prefix in combat instances (BG/arena) to avoid taint.
        ChatCompat:HookChatEditBoxes(self)
        self._prefixEnabled = true
    else
        -- Classic: manual table-swap hooks (no taint issues in Classic)
        ChatCompat:HookSendChatMessage(self)
        if self._useCClubInfo then ChatCompat:HookClubSendMessage(self) end
    end
end

function IncognitoResurrected:OnDisable()
    if self._useCChatInfo then
        -- Retail: disable prefix flag (HookScript hooks are permanent)
        self._prefixEnabled = false
    else
        -- Classic: remove table-swap hooks
        ChatCompat:UnhookAll()
    end
    -- Unregister chat filters
    self:UnregisterChatFilters()
end

function IncognitoResurrected:PrintHelp()
    self:Print("Incognito Resurrected Slash Commands:")
    self:Print("/inc - Open the config window")
    self:Print("/inc help - Show this help message")
    self:Print("/inc name <name> - Set your incognito name prefix")
    self:Print("/debug - Toggle debug mode")
end

