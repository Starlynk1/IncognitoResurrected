------------------------
---		Version      ---
---		 1.2.6       ---
------------------------

------------------------
---		Module       ---
------------------------
IncognitoResurrected = LibStub("AceAddon-3.0"):NewAddon("IncognitoResurrected",
                                                        "AceConsole-3.0",
                                                        "AceEvent-3.0",
                                                        "AceHook-3.0");

----------------------------
--      Localization      --
----------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("IncognitoResurrected", true)

----------------------------
--     Get WoW Version    --
----------------------------

function GetWoWVersion()
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        return "retail"
    elseif WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC then
        return "mists"
    elseif WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
        return "classic"
    else
        return "unknown"
    end
end

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
                -- New option: Ignore leading symbols
                ignoreLeadingSymbols = {
                    order = 4,
                    type = "input",
                    name = L["ignoreLeadingSymbols"],
                    desc = L["ignoreLeadingSymbols_desc"],
                    width = "full"
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
                    order = 2,
                    type = "description",
                    name = "|cFFFFA500" .. L["guildinfo"]
                },
                party = {
                    order = 3,
                    type = "toggle",
                    width = "full",
                    name = L["party"],
                    desc = L["party_desc"]
                },
                raid = {
                    order = 4,
                    type = "toggle",
                    width = "full",
                    name = L["raid"],
                    desc = L["raid_desc"]
                },
                lfr = {
                    order = 5,
                    type = "toggle",
                    width = "full",
                    name = L["lfr"],
                    desc = L["lfr_desc"],
                    hidden = function()
                        return GetWoWVersion() ~= "retail"
                    end
                },
                instance_chat = {
                    order = 6,
                    type = "toggle",
                    width = "full",
                    name = L["instance_chat"],
                    desc = L["instance_chat_desc"]
                },
                world_chat = {
                    order = 7,
                    type = "toggle",
                    width = "full",
                    name = L["world_chat"],
                    desc = L["world_chat_desc"]
                },
                world_chat_info = {
                    order = 8,
                    type = "description",
                    name = "|cFFFFA500" .. L["world_chat_info_desc"]
                },
                channel = {
                    order = 9,
                    type = "input",
                    name = L["channel"],
                    desc = L["channel_desc"]
                },
                channelinfo = {
                    order = 10,
                    type = "description",
                    name = "|cFFFFA500" .. L["channel_info_text"]
                },
                debug = {
                    order = 11,
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
        hideOnMatchingCharName = true,
        -- Default ignored leading symbols
        ignoreLeadingSymbols = "/!#@?."
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

----------------------
---      Init      ---
----------------------

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

    -- Hook SendChatMessage function
    local version = GetWoWVersion()
    if version == "mists" or version == "classic" then
        self:RawHook("SendChatMessage", true)
    else
        self:RawHook(C_ChatInfo, "SendChatMessage", true)
    end

    -- get current character name
    character_name, _ = UnitName("player")

    self:Safe_Print(L["Loaded"])
end

--------------------------------
---      Event Handlers      ---
--------------------------------

function IncognitoResurrected:SendChatMessage(msg, chatType, language, target)
    -- Early out: ignore messages starting with configured symbols (after spaces)
    if self.db and self.db.profile and self.db.profile.enable and type(msg) == "string" then
        local symbols = self.db.profile.ignoreLeadingSymbols or "/!#"
        local firstChar = msg:match("^%s*(.)")
        if firstChar and symbols:find(firstChar, 1, true) then
            local version = GetWoWVersion()
            if version == "mists" or version == "classic" then
                self.hooks.SendChatMessage(msg, chatType, language, target)
            else
                self.hooks[C_ChatInfo].SendChatMessage(msg, chatType, language, target)
            end
            return
        end
    end

    if self.db.profile.enable then
        if self.db.profile.name and self.db.profile.name ~= "" then
            if (not self.db.profile.hideOnMatchingCharName) or
                (self.db.profile.name ~= character_name) then

                if (self.db.profile.guild and
                    (chatType == "GUILD" or chatType == "OFFICER")) or
                    (self.db.profile.raid and chatType == "RAID") or
                    (self.db.profile.party and chatType == "PARTY") or
                    (self.db.profile.instance_chat and chatType ==
                        "INSTANCE_CHAT") then
                    msg = "(" .. self.db.profile.name .. ") " .. msg

                    -- Use World Chat Channels 
                elseif self.db.profile.world_chat and chatType == "CHANNEL" then
                    msg = "(" .. self.db.profile.name .. ") " .. msg

                    -- Use Specified Chat Channel, commas are allowed 
                elseif self.db.profile.channel and chatType == "CHANNEL" then
                    for i in string.gmatch(self.db.profile.channel, '([^,]+)') do
                        local nameToMatch = strtrim(i)
                        local id, chname = GetChannelName(target)
                        if chname and strupper(nameToMatch) == strupper(chname) then
                            msg = "(" .. self.db.profile.name .. ") " .. msg
                        end
                    end

                    -- Check for Retail Version and in LFR
                elseif GetWoWVersion() == "retail" and
                    (self.db.profile.lfr and IsInLFR()) then
                    msg = "(" .. self.db.profile.name .. ") " .. msg
                end
            end
        end
    end

    -- Call original function
    local version = GetWoWVersion()
    if version == "mists" or version == "classic" then
        self.hooks.SendChatMessage(msg, chatType, language, target)
    else
        self.hooks[C_ChatInfo].SendChatMessage(msg, chatType, language, target)
    end
end

---------------------------
---      Functions      ---
---------------------------

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

