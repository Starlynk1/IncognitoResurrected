# Incognito Resurrected

## [v2.0.0](https://github.com/Starlynk1/IncognitoResurrected/tree/v2.0.0) (2026-09-19)

Authors Note: Sorry for being AFK for a while, but life is always interesting and time was not
available. But in the meantime, I have made a new version. This is a full rewrite of the addon. Ace3
is gone. Chat prefixing, options, and saved variables are all native now.

I just saw today that there is another Incognito made called Incognito 2. Which this is what I was
going to call this rewrite, but will stick with the original naming now. It's just V2 now :D

Thanks for the support and have fun!

**Chat**

- Retail and Forever prefix through the official edit-box send path. `C_ChatInfo.SendChatMessage` is
  never replaced.
- Secret chat text is prefixed by concatenation only. The addon does not compare, match, or measure
  those strings.
- Open-world combat still prefixes. Prefixing is skipped during encounter, Mythic+, PvP match,
  restricted map, or chat messaging lockdown.
- Classic Era still wraps `SendChatMessage`. MoP uses the edit-box path.

**Settings**

- New options panel in `/inc` or `/incognito`.
- Global profile is the default. Turn it off for a per-character profile (different guilds or
  mains).
- Dungeon, raid, battleground, and arena toggles stay disabled on Retail and Forever while those
  restrictions apply.

**Saved variables**

- First load rebuilds old AceDB settings and any Incognito beta profiles into the new 1/0 flag
  schema.
- Your existing name and channel options should carry over. Reload once after updating.

**Support**

- TOC covers Classic Era, Classic, MoP, Retail 12.0/12.1, and Forever.

## [v1.5.1](https://github.com/Starlynk1/IncognitoResurrected/tree/v1.5.1) (2026-02-28)

[Full Changelog](https://github.com/Starlynk1/IncognitoResurrected/compare/v1.5.0...v1.5.1)
[Previous Releases](https://github.com/Starlynk1/IncognitoResurrected/releases)

- Updated to TOC and how the DB saves settings
- Merge pull request #65 from TheIceBadger/main  
   Strip prefix from sent-message history
- Merge pull request #67 from milestorme/develop  
   Update interface version in IncognitoResurrected.toc
- Update interface version in IncognitoResurrected.toc  
   Fix's addon showing out of date in addon list
- Restricted status helper function  
   Added new helper function since I basically used the same check code that was there, but since
  its now used in 2 places its probably best to have it as a function of it own we can re-use.  
   In addition to that, changed the check to use the new  
   C_RestrictedActions.GetAddOnRestrictionState  
   That should return 0 if player is in a non restricted state, whether its in an instance or not,
  currently its in its most strict mode.  
   But ideally this should allow it to add the prefix as often as possible, while stopping errors
  when restricted.  
   Falls back to checking instances (pvp/arena) as before should it be missing.
- Strip prefix from sent-message history  
   When navigating Up or Down in history with how the new update edits the text in the edit box,
  history items will end up with the prefix, doing so results in multiple prefixes being added if
  you want to send one message several times, it also makes copy pasting your message include the
  prefix.  
   This bit of code should strip that prefix out when looking up sent-message history, and only do
  so in the same situations as the send message functionality.
- Fix formatting in credits section of README
