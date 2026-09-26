# Incognito Resurrected

Incognito adds your specified name in front of your chat messages. Incognito Resurrected can be enabled for guild (and officer), party, raid, world, custom, and community chat.

Midnight and Forever API changes limit prefixing while addon restrictions or secret-value chat lockdown is active (encounters, Mythic+, PvP matches, and some maps). Open-world combat still prefixes.

## Example

<pre><code>[Guild] [Yourchar]: Some chat message </code></pre>

becomes

<pre><code>[Guild] [Yourchar]: (Yourname): Some chat message</code></pre>

## Usage

Use the GUI (`/inc` or `/incognito`) or slash commands:

- `/inc` — Open the configuration dialog
- `/inc name <name>` — Set the name shown in front of your messages
- `/inc debug` — Toggle debug output
- `/inc help` — Show slash-command help

`/inc2` and `/incognito2` still open the same panel.

## Options

- **Use global profile** — Share settings across characters, or turn this off for a per-character
  profile
- **Enable** — Add your name to chat messages
- **Name** — The name displayed in your chat messages
- **Color Name by class** — Color the prefix with the sender's class color
- **Hide name if it matches your character's name** — Skip the prefix when it would repeat your
  character name
- **Guild** — Guild and officer chat (`/g`, `/o`)
- **Party / Dungeon / Raid / Battleground / Arena** — Instance toggles are skipped on Retail and
  Forever while restrictions are active
- **World Chat** — General, Trade, LocalDefense, and Services (all or none)
- **Channel** — Custom channels, comma-separated
- **Community** — Community channels (Retail)
- **Debug** — Debug output

## Known Issues

## Features and Bugs

If you have a feature request or find a bug please report them through the Github repository:  
https://github.com/Starlynk1/IncognitoResurrected/issues

## Translations

Translations are initially done using a translation website.  
Please submit a ticket with updated translations if/when there is a better wording.  
New languages are always appreciated.

## Credits

Resurrected Author: Starlynk

### Version: 2.0.1
