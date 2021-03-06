![Version 3.0](https://img.shields.io/badge/version-v1.0-orange.svg)
![IW4.0 Engine - GSC](https://img.shields.io/badge/IW4.0_Engine-GSC-blue.svg)
![Last Updated](https://img.shields.io/github/last-commit/kyletimmermans/flashback?color=success)
[![kyletimmermans Twitter](http://img.shields.io/twitter/url/http/shields.io.svg?style=social&label=Follow)](https://twitter.com/kyletimmermans)

# <div align="center">Flashback</div>

<div align="center">MW2 Mod Menu (TU6) for Xbox360 with a Button Bind Era Look and Implementation</div>

</br>

To keep in mind:
- [x] https://www.youtube.com/watch?v=qippuizZnYY
- [x] https://www.se7ensins.com/forums/threads/mw2-text-patch-codes.450887/
- [x] https://www.thetechgame.com/Archives/t=5918100/mw2-button-codes.html
- [ ] Airdrop Editor is for care packages and emergency airdrops
- [ ] Put _missions.gsc back into patch_mp.ff
- [ ] Only file left in this repo should be _missions.gsc and release should be zipped up patch_mp.ff file with current title update and default_mp.xex
- [ ] Couldn't have done this without ImACoww from TheTechGame, his Infectable v3 menu is the base / inspiration of my menu

Known bugs:
- [ ] scr dvars unrecognized, bottom left corner messages
- [ ] scr_notify messages overlap
- [ ] Can't see the leave (y/n) message
- [ ] GSC Functions not running

<div>Controls:</div>
<div>DPAD_UP = Open / Scroll Up</div>
<div>DPAD_DOWN = Scroll Down</div>
<div>DPAD_RIGHT = Move Toggle Right</div>
<div>DPAD_LEFT = Move Toggle Right</div>
<div>BUTTON_A = Select</div>
<div>BUTTON_B = Back / Exit</div>

</br>

Main Menu:
- [x] Unlock Menu
- [x] Prestige Menu
- [x] Infection Menu
- [x] Fun Menu
- [x] Map Menu
- [x] Game Menu
- [x] ClanTag Menu

Player Menu:
- [x] Kick Menu
- [x] Infect All 
- [x] Kill All
- [x] Freeze All
- [x] Add Bots

_____________

ToDo:
- [ ] Remove scr_do_notify incorrect msg from Fun Menu, check other menus for similar issue
- [ ] Do Infection Menus
- [ ] Fix GSC functions not working
- [x] Unbind A and B everytime we open menu and bind them to EXEC and BACK so they can be our new select and back button for the menu. Rebind them on menu exit. Also change dpad right and left to be the toggle switches.
- [ ] Add Toggles, even for gsc functions (Fun Menu, Game Menu, Infection Menu, Freeze All)
- [ ] Test everything to make sure it works
- [ ] Make an IW4X version for those w/o JTAG/RGH
- [ ] Release
