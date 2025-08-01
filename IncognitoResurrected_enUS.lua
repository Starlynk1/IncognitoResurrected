------------------------
---		Version      ---
---		 1.2.4       ---
------------------------

local L = LibStub("AceLocale-3.0"):NewLocale("IncognitoResurrected", "enUS", true)

if not L then return end

L["Loaded"] = "Loaded."

L["name"] = "Name"
L["name_desc"] = "The name that should be displayed in your chat messages."

L["enable"] = "Enable"
L["enable_desc"] = "Enable adding your name to chat messages."

L["guild"] = "Guild"
L["guild_desc"] = "Add name to guild chat messages (/g and /o)."
L["guildinfo"] = "Guild chat messages are generated from the Chat frame, not the Guild frame."

L["party"] = "Party"
L["party_desc"] = "Add name to party chat messages (/p)."

L["raid"] = "Raid"
L["raid_desc"] = "Add name to raid chat messages (/raid)."

L["lfr"] = "LFR"
L["lfr_desc"] = "Add name to LFR chat messages (/raid or /i)."

L["instance_chat"] = "Instance"
L["instance_chat_desc"] = "Add name to instance chat messages, e.g., LFR and battlegrounds (/i)."

L["world_chat"] = "World Chat"
L["world_chat_desc"] = "Add name to world chat messages, e.g., General, Trade, LocalDefense and Services.\n-- This is an all or none option, you cannot select which World Channel to enable/disable"

L["world_chat_info"] = "World Chat"
L["world_chat_info_desc"] = "Add name to world chat messages, e.g., General, Trade, LocalDefense and Services.\n-- This is an all or none option, you cannot select which World Channel to enable/disable"

L["config"] = "Configuration"
L["config_desc"] = "Open configuration window."

L["debug"] = "Debug"
L["debug_desc"] = "Enable debugging messages output. You probably don't want to enable this."

L["channel"] = "Channel"
L["channel_desc"] = "Add name to chat messages in this custom channel. Single Channel Only."

L["hideOnMatchingCharName"] = "Hide name if it matches your character's name"
L["hideOnMatchingCharName_desc"] = "If the name specified above matches your current character's name, IncognitoResurrected will not add it again if this option is checked."

L["channel_info_text"] = "World channels (Say, General, Trade, Services) are not acceptable options.\nThis is a limitation within the Blizzard API."