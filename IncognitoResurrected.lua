------------------------
---		Version      ---
---		 1.1.1       ---
------------------------


------------------------
---		Module       ---
------------------------

IncognitoResurrected  = LibStub("AceAddon-3.0"):NewAddon(	"IncognitoResurrected",
												"AceConsole-3.0",
												"AceEvent-3.0",
												"AceHook-3.0");

----------------------------
--      Localization      --
----------------------------

local L = LibStub("AceLocale-3.0"):GetLocale("IncognitoResurrected", true)

local Options = {
	name = "Incognito Resurrected",
	type = "group",
	args = {
		generalSettings = {
		name = "General Settings",
		type = "group",
		inline = true,
		order = 0,
		get = function(item) return IncognitoResurrected.db.profile[item[#item]] end,
		set = function(item, value) IncognitoResurrected.db.profile[item[#item]] = value end,
		args = {
				name = {
				order = 1,
				type = "input",
				name = L["name"],
				desc = L["name_desc"],
			},
				enable = {	
				order = 2,
				type = "toggle",
				name = L["enable"],
				desc = L["enable_desc"],
				width = "full",
			},	
				hideOnMatchingCharName = {
				order = 3,
				type = "toggle",
				name = L["hideOnMatchingCharName"],
				desc = L["hideOnMatchingCharName_desc"],
				width = "full",
			},
		},
	},
		generalOptions = {
		name = "Options",
		type = "group",
		inline = true,
		order = 1,
		get = function(item) return IncognitoResurrected.db.profile[item[#item]] end,
		set = function(item, value) IncognitoResurrected.db.profile[item[#item]] = value end,
		args = {
			guild = {
				order = 1,
				type = "toggle",
				width = "full",
				name = L["guild"],
				desc = L["guild_desc"],
				},
			guildinfo = {
				order = 2,
				type = "description",
				name = "|cFFFFA500" .. L["guildinfo"],
				},
			party = {
				order = 3,
				type = "toggle",
				width = "full",
				name = L["party"],
				desc = L["party_desc"],	
				},
			raid = {
				order = 4,
				type = "toggle",
				width = "full",
				name = L["raid"],
				desc = L["raid_desc"],
				},
			instance_chat = {
				order = 5,
				type = "toggle",
				width = "full",
				name = L["instance_chat"],
				desc = L["instance_chat_desc"],				
				},
			world_chat = {
				order = 6,
				type = "toggle",
				width = "full",
				name = L["world_chat"],
				desc = L["world_chat_desc"]
			}
			channel = {
				order = 7,
				type = "input",
				name = L["channel"],
				desc = L["channel_desc"],
				},
			channelinfo = {
				order = 8, 
				type = "description",
				name = "|cFFFFA500" .. L["channel_info_text"],
				
				},
			debug = {
				order = 9,
				type = "toggle",
				width = "full",
				name = L["debug"],
				desc = L["debug_desc"],
				},				
			},
		},
	},
}

local Defaults = {
	profile = {
		enable = true,
		guild = true,
		party = false,
		raid = false,
		instance_chat = false,
		world_chat = false,
		debug = false,
		channel = nil,
		hideOnMatchingCharName = true,
	},
}


local SlashOptions = {
	type = "group",
	handler = IncognitoResurrected,
	get = function(item) return IncognitoResurrected.db.profile[item[#item]] end,
	set = function(item, value) IncognitoResurrected.db.profile[item[#item]] = value end,
	args = {
		enable = {
			name = L["enable"],
			desc = L["enable_desc"],
			type = "toggle",
		},
		name = {
			name = L["name"],
			desc = L["name_desc"],
			type = "input",
		},
	 	config = {
			name = L["config"],
			desc = L["config_desc"],
			guiHidden = true,
			type = "execute",
			func = function()
				InterfaceOptionsFrame_OpenToCategory(IncognitoResurrected)
			end,
		},
	},
}


local SlashCmds = {
  "inc",
  "incognito",
  "IncognitoResurrected",
};

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
		main = dialog:AddToBlizOptions(	"IncognitoResurrected Options", "IncognitoResurrected"),
		profiles = dialog:AddToBlizOptions(	"IncognitoResurrected Profiles", "Profiles", "IncognitoResurrected");
	}
	
	-- Hook SendChatMessage function
	self:RawHook("SendChatMessage", true)
	
	-- get current character name
	character_name, _ = UnitName("player")
	
	self:Safe_Print(L["Loaded"])
end

--------------------------------
---      Event Handlers      ---
--------------------------------

function IncognitoResurrected:SendChatMessage(msg, chatType, language, channel)
	if self.db.profile.enable then
		if self.db.profile.name and self.db.profile.name ~= "" then
			if (not self.db.profile.hideOnMatchingCharName) or (self.db.profile.name ~= character_name) then

				if  (self.db.profile.guild and (chatType == "GUILD" or chatType == "OFFICER")) or
					(self.db.profile.raid and chatType == "RAID") or 
					(self.db.profile.party and chatType == "PARTY") or
					(self.db.profile.instance_chat and chatType == "INSTANCE_CHAT")
					(self.db.profile.world_chat and chatType == "WORLD_CHAT")
				then
					msg = "(" .. self.db.profile.name .. ") " .. msg

				elseif self.db.profile.channel and chatType == "CHANNEL" then
					local id, chname = GetChannelName(channel)
					if strupper(self.db.profile.channel) == strupper(chname) then
						msg = "(" .. self.db.profile.name .. ") " .. msg
					end
				end
				
			end
		end
	end
	
	-- Call original function
	self.hooks.SendChatMessage(msg, chatType, language, channel)
end

---------------------------
---      Functions      ---
---------------------------

function IncognitoResurrected:Safe_Print(msg)
	if self.db.profile.debug then
		self:Print(msg)
	end
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