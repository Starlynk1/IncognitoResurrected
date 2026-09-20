# Incognito Resurrected

## [v1.5.1](https://github.com/Starlynk1/IncognitoResurrected/tree/v1.5.1) (2026-02-28)
[Full Changelog](https://github.com/Starlynk1/IncognitoResurrected/compare/v1.5.0...v1.5.1) [Previous Releases](https://github.com/Starlynk1/IncognitoResurrected/releases)

- Updated to TOC and how the DB saves settings  
- Merge pull request #65 from TheIceBadger/main  
    Strip prefix from sent-message history  
- Merge pull request #67 from milestorme/develop  
    Update interface version in IncognitoResurrected.toc  
- Update interface version in IncognitoResurrected.toc  
    Fix's addon showing out of date in addon list  
- Restricted status helper function  
    Added new helper function since I basically used the same check code that was there, but since its now used in 2 places its probably best to have it as a function of it own we can re-use.  
    In addition to that, changed the check to use the new  
    C\_RestrictedActions.GetAddOnRestrictionState  
    That should return 0 if player is in a non restricted state, whether its in an instance or not, currently its in its most strict mode.  
    But ideally this should allow it to add the prefix as often as possible, while stopping errors when restricted.  
    Falls back to checking instances (pvp/arena) as before should it be missing.  
- Strip prefix from sent-message history  
    When navigating Up or Down in history with how the new update edits the text in the edit box, history items will end up with the prefix, doing so results in multiple prefixes being added if you want to send one message several times, it also makes copy pasting your message include the prefix.  
    This bit of code should strip that prefix out when looking up sent-message history, and only do so in the same situations as the send message functionality.  
- Fix formatting in credits section of README  