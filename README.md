# Incognito Resurrected
Incognito adds your specified name in front of your chat messages. Incognito Resurrected can be enabled for guild (and officer), party and raid chat messages.

**Examples:**  
[Guild] [Yourchar]: Some chat message  
becomes  
[Guild] [Yourchar]: (Yourname): Some chat message  
(Brackets are configurable.)

Usage  

**You can use the GUI config dialog or the slash commands /incognito or /inc
slash options**
- /incognito config - Open configuration dialog
- /incognito enable - Enable or disable adding your name to chat messages
- /incognito name - The name that should be displayed in your chat messages

**AddOns Options**
- Enable - Enable adding your name to chat messages.
- Name - The name that should be displayed in your chat messages.
- Hide name if it matches your character's name - Do not add your name if it matches your character.
- Partial match - Choose how matches are detected when hiding the name:
  - Disabled (default)
  - Start of name
  - Anywhere
  - End of name
- Color Name by class - Color the Incognito name with the sender's class color.
- Ignore leading symbols - If a message starts with any of these characters (after any spaces), do not add the name prefix.
- Bracket style - Choose which brackets to surround your name with.
- Guild - Add name to guild chat messages.
- Party - Add name to party chat messages.
- Raid - Add name to raid chat messages.
- LFR - Add name to LFR chat messages (/raid or /i).
- Instance - Add name to instance chat messages, e.g., LFR and battlegrounds (/i).
- World - Add name to world chat messages, e.g., General, Trade, LocalDefense and Services  
  (This is an all or none option, you cannot select which World Channel to enable/disable.)
- Channel - Add name to chat messages in a custom channel (single channel only).  
  Note: World channels (Say, General, Trade, Services) are not acceptable options. This is a limitation within the Blizzard API.
- Debug - Enable debugging messages output. You probably don't want to enable this.

**Known Issues**
LFR option was disabled temporarily. Will be working on adding that option again soon.

**Features and Bugs**
If you have a feature request of find a bug please report them through the Github repository:
https://github.com/Starlynk1/IncognitoResurrected/issues
