--  Version: 1.3.3
IncognitoResurrected = LibStub("AceAddon-3.0"):NewAddon("IncognitoResurrected",
                                                        "AceConsole-3.0",
                                                        "AceEvent-3.0",
                                                        "AceHook-3.0");

--  Localization
local L = LibStub("AceLocale-3.0"):GetLocale("IncognitoResurrected", true)

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
                    name = L["name"],
                    desc = L["name_desc"]
                },
                enable = {
                    order = 2,
                    type = "toggle",
                    name = L["enable"],
                    desc = L["enable_desc"],
                    width = "full"
                },
                hideOnMatchingCharName = {
                    order = 3,
                    type = "toggle",
                    name = L["hideOnMatchingCharName"],
                    desc = L["hideOnMatchingCharName_desc"],
                    width = "full"
                },
                -- Matching mode for character vs configured name
                partialMatchMode = {
                    order = 3.5,
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
                -- New option: Colorize prefix by class color
                colorizePrefix = {
                    order = 4,
                    type = "toggle",
                    name = "Color Name by class",
                    desc = "Color the Incognito Name with the sender's class color.",
                    width = "full"
                },
                -- New option: Ignore leading symbols
                ignoreLeadingSymbols = {
                    order = 5,
                    type = "input",
                    name = L["ignoreLeadingSymbols"],
                    desc = L["ignoreLeadingSymbols_desc"],
                    width = "normal"
                },
                spacer = {
                    order = 6,
                    type = "description",
                    name = "",
                    width = "half"
                },
                -- New option: Bracket style selector
                bracketStyle = {
                    order = 7,
                    type = "select",
                    name = L["bracketStyle"],
                    desc = L["bracketStyle_desc"],
                    values = {
                        paren = "(round)",
                        square = "[square]",
                        curly = "{curly}",
                        angle = "<angle>"
                    }
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
                party = {
                    order = 2,
                    type = "toggle",
                    width = "full",
                    name = L["party"],
                    desc = L["party_desc"]
                },
                raid = {
                    order = 3,
                    type = "toggle",
                    width = "full",
                    name = L["raid"],
                    desc = L["raid_desc"]
                },
                lfr = {
                    order = 4,
                    type = "toggle",
                    width = "full",
                    name = L["lfr"],
                    desc = L["lfr_desc"],
                    hidden = function()
                        return not IncognitoResurrected:IsLFRAvailable()
                    end
                },
                instance_chat = {
                    order = 5,
                    type = "toggle",
                    width = "full",
                    name = L["instance_chat"],
                    desc = L["instance_chat_desc"]
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
                    type = "input",
                    name = L["community"],
                    desc = L["community_desc"]
                },
                communityinfo = {
                    order = 8.5,
                    type = "description",
                    name = "|cFFFFA500" .. L["community_info_text"]
                },
                debug = {
                    order = 9,
                    type = "toggle",
                    width = "full",
                    name = L["debug"],
                    desc = L["debug_desc"]
                }
            }
        }
    }
}

local Defaults = {
    profile = {
        enable = true,
        guild = true,
        party = false,
        raid = false,
        lfr = false,
        instance_chat = false,
        world_chat = false,
        debug = false,
        channel = nil,
        community = nil,
        hideOnMatchingCharName = true,
        -- Default ignored leading symbols
        ignoreLeadingSymbols = "/!#@?",
        -- Default bracket style
        bracketStyle = "paren",
        -- Class-color the bracketed prefix in chat frames
        colorizePrefix = true
    }
}

local SlashOptions = {
    type = "group",
    handler = IncognitoResurrected,
    get = function(item) return IncognitoResurrected.db.profile[item[#item]] end,
    set = function(item, value)
        IncognitoResurrected.db.profile[item[#item]] = value
    end,
    args = {
        enable = {name = L["enable"], desc = L["enable_desc"], type = "toggle"},
        name = {name = L["name"], desc = L["name_desc"], type = "input"},
        config = {
            name = L["config"],
            desc = L["config_desc"],
            guiHidden = true,
            type = "execute",
            func = function()
                InterfaceOptionsFrame_OpenToCategory(IncognitoResurrected)
            end
        }
    }
}

local SlashCmds = {"inc", "incognito", "IncognitoResurrected"};
local character_name

--  Init

function IncognitoResurrected:OnInitialize()

    -- Load our database.
    self.db = LibStub("AceDB-3.0"):New("IncognitoResurrectedDB", Defaults, true)

    -- Set up our config options.
    local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

    local config = LibStub("AceConfig-3.0")
    config:RegisterOptionsTable("IncognitoResurrected", SlashOptions, SlashCmds)

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

    -- Hook SendChatMessage function using feature detection
    self._useCChatInfo = type(C_ChatInfo) == "table" and
                             type(C_ChatInfo.SendChatMessage) == "function"
    self._useCClubInfo = type(C_Club) == "table" and type(C_Club.SendMessage) ==
                             "function"

    if self._useCChatInfo then
        self:RawHook(C_ChatInfo, "SendChatMessage", true)
    elseif self._useCClubInfo then
        self:RawHook(C_Club, "SendMessage", true)
    else
        self:RawHook("SendChatMessage", true)
    end

    -- get current character name
    character_name, _ = UnitName("player")

    self:Safe_Print(L["Loaded"])
end

--  Event Handlers
function IncognitoResurrected:SendChatMessage(msg, chatType, language, target)
    -- Early out: ignore messages starting with configured symbols (after spaces)
    if self.db and self.db.profile and self.db.profile.enable and type(msg) ==
        "string" then
        local symbols = self.db.profile.ignoreLeadingSymbols or "/!#"
        local firstChar = msg:match("^%s*(.)")
        if firstChar and symbols:find(firstChar, 1, true) then
            if self._useCChatInfo then
                self.hooks[C_ChatInfo].SendChatMessage(msg, chatType, language,
                                                       target)
            else
                self.hooks.SendChatMessage(msg, chatType, language, target)
            end
            return
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
                    (self.db.profile.party and chatType == "PARTY") or
                    (self.db.profile.instance_chat and chatType ==
                        "INSTANCE_CHAT") then
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

                    -- LFR
                elseif self.db.profile.lfr and IsInLFR() then
                    msg = self:GetNamePrefix() .. msg
                end
            end
        end
    end

    -- Call original function
    if self._useCChatInfo then
        self.hooks[C_ChatInfo].SendChatMessage(msg, chatType, language, target)
    else
        self.hooks.SendChatMessage(msg, chatType, language, target)
    end
end

function IncognitoResurrected:SendMessage(clubID, streamID, msg)
    if self.db and self.db.profile and self.db.profile.enable and type(msg) ==
        "string" then
        local symbols = self.db.profile.ignoreLeadingSymbols or "/!#"
        local firstChar = msg:match("^%s*(.)")
        if firstChar and symbols:find(firstChar, 1, true) then
            self.hooks[C_Club].SendMessage(clubID, streamID, msg)
            return
        end
    end
    if self.db.profile.enable and self.db.profile.community then
        local clubInfo = C_Club.GetClubInfo(clubID)
        if clubInfo and clubInfo.clubType == Enum.ClubType.Character then
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
            for i in string.gmatch(self.db.profile.community, '([^,]+)') do
                local nameToMatch = strtrim(i)
                if strupper(nameToMatch) == strupper(clubInfo.name) then
                    if shouldAddPrefix then
                        msg = self:GetNamePrefix() .. msg
                    end
                    break
                end
            end
        end
    end
    self.hooks[C_Club].SendMessage(clubID, streamID, msg)
end

--  Functions
function IncognitoResurrected:Safe_Print(msg)
    if self.db.profile.debug then self:Print(msg) end
end

function InterfaceOptionsFrame_OpenToCategory(IncognitoResurrected)
    if type(IncognitoResurrected) == "string" then
        return Settings.OpenToCategory(IncognitoResurrected);
    elseif type(IncognitoResurrected) == "table" then
        local frame = IncognitoResurrected;
        local category = frame.name;
        if category and type(category) == "string" then
            return Settings.OpenToCategory(category);
        end
    end
end

function IsInLFR()
    local _, instanceType, difficultyID = GetInstanceInfo()
    return instanceType == "raid" and difficultyID == 17
end

function IncognitoResurrected:IsLFRAvailable()
    if type(GetDifficultyInfo) == "function" then
        local name = GetDifficultyInfo(17)
        return name ~= nil
    end
    return false
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

    -- Match a leading bracketed name, requiring a colon after the closing bracket.
    -- Supports optional spaces before and after the colon.
    -- Examples: "(Name):msg", "(Name): msg", "(Name) :msg", "(Name) : msg"
    local pre, open, name, close, spacesAfterClose, colonSpaces, rest =
        msg:match(
            "^(%s*)([%(%[%{%<])([^%(%[%{%<%]%}%>]+)([%)%]%}%>])(%s*):(%s*)(.*)$")
    if not open then return false end
    if OPEN_TO_CLOSE[open] ~= close then return false end

    -- Resolve class color of the sender
    local guid = ExtractPlayerGUID(...)
    local classFile
    if guid and GetPlayerInfoByGUID then
        local _, cf = GetPlayerInfoByGUID(guid)
        classFile = cf
    end
    if not classFile and author and UnitClass then
        local unit = Ambiguate and Ambiguate(author, "none") or author
        local _, cf = UnitClass(unit)
        classFile = cf
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

function IncognitoResurrected:OnEnable() self:RegisterChatFilters() end

function IncognitoResurrected:OnDisable() self:UnregisterChatFilters() end

