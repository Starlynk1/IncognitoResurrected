-- Version 1.4.0
local L = LibStub("AceLocale-3.0"):NewLocale("IncognitoResurrected", "enUS",
                                             true)

if not L then return end

L["Loaded"] = "Geladen."

L["name"] = "Name"
L["name_desc"] = "Name, der bei deinen Chatnachrichten angezeigt werden soll."

L["enable"] = "Aktivieren"
L["enable_desc"] = "Aktiviert das Anzeigen deines Namens bei deinen Chatnachrichten."

L["guild"] = "Gilde"
L["guild_desc"] = "Deinen Namen bei Gildenchatnachrichten anzeigen (/g und /o)."
L["guildinfo"] = "Gildenchat-Nachrichten werden aus dem Chatfenster erzeugt, nicht aus dem Gildenfenster."

L["party"] = "Gruppe"
L["party_desc"] = "Deinen Namen bei Gruppenchatnachrichten anzeigen (/p)."

L["raid"] = "Schlachtzug"
L["raid_desc"] = "Deinen Namen bei Schlachtzugschatnachrichten anzeigen (/raid)."

L["lfr"] = "LFR"
L["lfr_desc"] = "Deinen Namen bei LFR-Chatnachrichten anzeigen (/raid oder /i)."

L["instance_chat"] = "Instanz"
L["instance_chat_desc"] = "Deinen Namen bei Instanznachrichten anzeigen, z.B. im Schlachtzugsbrowser und im Schlachtfeld (/i)."

L["world_chat"] = "Weltchat"
L["world_chat_desc"] = "Deinen Namen zu Nachrichten im Weltchat hinzufügen, z. B. Allgemein, Handel, Lokale Verteidigung und Dienstleistungen.\n-- Dies ist eine Alles-oder-nichts-Option, du kannst nicht auswählen, welche Weltkanäle aktiviert/deaktiviert werden."

L["world_chat_info"] = "Weltchat"
L["world_chat_info_desc"] = "Deinen Namen zu Nachrichten im Weltchat hinzufügen, z. B. Allgemein, Handel, Lokale Verteidigung und Dienstleistungen.\n-- Dies ist eine Alles-oder-nichts-Option, du kannst nicht auswählen, welche Weltkanäle aktiviert/deaktiviert werden."

L["config"] = "Konfiguration"
L["config_desc"] = "Konfigurationsdialog öffnen."

L["debug"] = "Debug"
L["debug_desc"] = "Aktiviert die Ausgabe von Debugnachrichten. Am besten deaktiviert lassen."

L["channel"] = "Kanal"
L["channel_desc"] = "Fügen Sie Chatnachrichten in diesem benutzerdefinierten Kanal einen Namen hinzu. Verwenden Sie Kommas, um die Kanalnamen zu trennen."

L["community"] = "Gemeinschaft"
L["community_desc"] = "Fügen Sie Chat-Nachrichten in den Community-Kanälen einen Namen hinzu."

L["hideOnMatchingCharName"] = "Name nicht anzeigen, wenn er mit dem Charakternamen übereinstimmt"
L["hideOnMatchingCharName_desc"] = "Wenn der oben angegebene Name gleich dem Namen deines aktuellen Charakters ist, fügt ihn IncognitoResurrected nicht hinzu, wenn diese Option ausgewählt ist."

L["channel_info_text"] = "Say Channel ist keine Option. Dies ist eine Einschränkung innerhalb der Blizzard-API."
L["community_info_text"] = "Derzeit ist dies eine Alles-oder-Nichts-Option für Community-Kanäle."

L["colorizePrefix"] = "Namenspräfix in Klassenfarbe färben"
L["colorizePrefix_desc"] = "Färbt jedes führende eingeklammerte Namenspräfix ((), [], {}, <>) in der Klassenfarbe des Absenders auf deinem Client."

L["partialMatchMode"] = "Teilweiser Abgleich"
L["partialMatchMode_desc"] = "Blendet das Präfix aus, wenn der Charaktername gemäß der ausgewählten Regel mit dem konfigurierten Namen übereinstimmt (Groß-/Kleinschreibung ignoriert). Erfordert, dass 'Name nicht anzeigen, wenn er mit dem Charakternamen übereinstimmt' aktiviert ist."
L["partialMatchMode_disabled"] = "Deaktiviert"
L["partialMatchMode_start"] = "Anfang des Namens"
L["partialMatchMode_anywhere"] = "Irgendwo"
L["partialMatchMode_end"] = "Ende des Namens"
