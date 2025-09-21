-- Version 1.4.0
local L = LibStub("AceLocale-3.0"):NewLocale("IncognitoResurrected", "esES",
                                             true)
if not L then return end

L["Loaded"] = "Cargado."

L["name"] = "Nombre"
L["name_desc"] = "El nombre que debe mostrarse en tus mensajes de chat."

L["enable"] = "Habilitar"
L["enable_desc"] = "Habilitar la adición de tu nombre a los mensajes de chat."

L["guild"] = "Hermandad"
L["guild_desc"] =
    "Añadir nombre a los mensajes de chat de hermandad (/g y /o)."
L["guildinfo"] =
    "Los mensajes de chat de hermandad se generan desde el marco de Chat, no desde el marco de Hermandad."

L["party"] = "Grupo"
L["party_desc"] = "Añadir nombre a los mensajes de chat de grupo (/p)."

L["raid"] = "Banda"
L["raid_desc"] = "Añadir nombre a los mensajes de chat de banda (/raid)."

L["lfr"] = "LFR"
L["lfr_desc"] = "Añadir nombre a los mensajes de chat de LFR (/raid o /i)."

L["instance_chat"] = "Instancia"
L["instance_chat_desc"] =
    "Añadir nombre a los mensajes de chat de instancia, p.ej., LFR y campos de batalla (/i)."

L["world_chat"] = "Chat Mundial"
L["world_chat_desc"] =
    "Añadir nombre a los mensajes de chat mundial, p.ej., General, Comercio, DefensaLocal y Servicios.\n-- Esta es una opción todo o nada, no puedes seleccionar qué Canal Mundial habilitar/deshabilitar"
L["world_chat_info"] = "Chat Mundial"
L["world_chat_info_desc"] =
    "Añadir nombre a los mensajes de chat mundial, p.ej., General, Comercio, DefensaLocal y Servicios.\n-- Esta es una opción todo o nada, no puedes seleccionar qué Canal Mundial habilitar/deshabilitar"

L["config"] = "Configuración"
L["config_desc"] = "Abrir ventana de configuración."

L["debug"] = "Depuración"
L["debug_desc"] =
    "Habilitar salida de mensajes de depuración. Probablemente no quieras habilitar esto."

L["channel"] = "Canal"
L["channel_desc"] =
    "Añadir nombre a los mensajes de chat en este canal personalizado. Usa coma para separar nombres de canales."

L["community"] = "Comunidad"
L["community_desc"] =
    "Añadir nombre a los mensajes de chat en los canales de Comunidad."

L["hideOnMatchingCharName"] =
    "Ocultar nombre si coincide con el nombre de tu personaje"
L["hideOnMatchingCharName_desc"] =
    "Si el nombre especificado arriba coincide con el nombre de tu personaje actual, IncognitoResurrected no lo añadirá de nuevo si esta opción está marcada."

L["channel_info_text"] =
    "El canal Decir no es una opción. Esto es una limitación dentro de la API de Blizzard."
L["community_info_text"] =
    "Actualmente esta es una opción todo o nada para canales de comunidad."

L["ignoreLeadingSymbols"] = "Ignorar símbolos iniciales"
L["ignoreLeadingSymbols_desc"] =
    "Si un mensaje comienza con cualquiera de estos caracteres (después de cualquier espacio), no añadir el prefijo de nombre."
L["bracketStyle"] = "Estilo de corchetes"
L["bracketStyle_desc"] =
    "Elige qué corchetes rodean tu nombre en los mensajes de chat."

L["partialMatchMode"] = "Coincidencia parcial"
L["partialMatchMode_desc"] =
    "Ocultar el prefijo cuando el nombre de tu personaje coincide con el nombre configurado según la regla seleccionada (insensible a mayúsculas). Requiere que 'Ocultar nombre si coincide con el nombre de tu personaje' esté habilitado."
L["partialMatchMode_disabled"] = "Deshabilitado"
L["partialMatchMode_start"] = "Inicio del nombre"
L["partialMatchMode_anywhere"] = "En cualquier lugar"
L["partialMatchMode_end"] = "Fin del nombre"
