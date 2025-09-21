-- Version 1.4.0

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
L["channel_desc"] = "Add name to chat messages in this custom channel. Use comma to seperate channel names."

L["community"] = "Community"
L["community_desc"] = "Add name to chat messages in the Community channels."

L["hideOnMatchingCharName"] = "Hide name if it matches your character's name"
L["hideOnMatchingCharName_desc"] = "If the name specified above matches your current character's name, IncognitoResurrected will not add it again if this option is checked."

L["channel_info_text"] = "Say channel is not an option. This is a limitation within the Blizzard API."
L["community_info_text"] = "Currently this is an all or nothing option for community channels."

L["ignoreLeadingSymbols"] = "Ignore leading symbols"
L["ignoreLeadingSymbols_desc"] = "If a message starts with any of these characters (after any spaces), do not add the name prefix."

L["bracketStyle"] = "Bracket style"
L["bracketStyle_desc"] = "Choose which brackets to surround your name with in chat messages."

L["partialMatchMode"] = "Partial match"
L["partialMatchMode_desc"] = "Hide the prefix when your character name matches the configured name by the selected rule (case-insensitive). Requires 'Hide name if it matches your character's name' to be enabled."
L["partialMatchMode_disabled"] = "Disabled"
L["partialMatchMode_start"] = "Start of name"
L["partialMatchMode_anywhere"] = "Anywhere"
L["partialMatchMode_end"] = "End of name"
