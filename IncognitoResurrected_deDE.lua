------------------------
---		Version      ---
---		 1.2.4       ---
------------------------
local L = LibStub("AceLocale-3.0"):NewLocale("IncognitoResurrected", "enUS",
                                             true)

if not L then return end

L["Loaded"] = "Geladen."

L["name"] = "Name"
L["name_desc"] = "Name, der bei deinen Chatnachrichten angezeigt werden soll."

L["enable"] = "Aktivieren"
L["enable_desc"] =
    "Aktiviert das Anzeigen deines Namens bei deinen Chatnachrichten."

L["guild"] = "Gilde"
L["guild_desc"] = "Deinen Namen bei Gildenchatnachrichten anzeigen (/g und /o)."
L["guildinfo"] =
    "Guild chat messages are generated from the Chat frame, not the Guild frame."

L["party"] = "Gruppe"
L["party_desc"] = "Deinen Namen bei Gruppenchatnachrichten anzeigen (/p)."

L["raid"] = "Schlachtzug"
L["raid_desc"] =
    "Deinen Namen bei Schlachtzugschatnachrichten anzeigen (/raid)."

L["lfr"] = "LFR"
L["lfr_desc"] = "Add name to LFR chat messages (/raid or /i)."

L["instance_chat"] = "Instanz"
L["instance_chat_desc"] =
    "Deinen Namen bei Instanznachrichten anzeigen, z.B. im Schlachtzugsbrowser und im Schlachtfeld (/i)."

L["world_chat"] = "World Chat"
L["world_chat_desc"] =
    "Add name to world chat messages, e.g., General, Trade, LocalDefense and Services.\n-- This is an all or none option, you cannot select which World Channel to enable/disable"

L["world_chat_info"] = "World Chat"
L["world_chat_info_desc"] =
    "Add name to world chat messages, e.g., General, Trade, LocalDefense and Services.\n-- This is an all or none option, you cannot select which World Channel to enable/disable"

L["config"] = "Konfiguration"
L["config_desc"] = "Konfigurationsdialog öffnen."

L["debug"] = "Debug"
L["debug_desc"] =
    "Aktiviert die Ausgabe von Debugnachrichten. Am besten deaktiviert lassen."

L["channel"] = "Kanal"
L["channel_desc"] = "Deinen Namen in diesem benutzerdefinierten Kanal anzeigen."

L["hideOnMatchingCharName"] =
    "Name nicht anzeigen, wenn er mit dem Charakternamen übereinstimmt"
L["hideOnMatchingCharName_desc"] =
    "Wenn der oben angegebene Name gleich dem Namen deines aktuellen Charakters ist, fügt ihn IncognitoResurrected nicht hinzu, wenn diese Option ausgewählt ist."

L["channel_info_text"] =
    "The World Channels are not an acceptable option.\n-- This is a limitation within the Blizzard API"
