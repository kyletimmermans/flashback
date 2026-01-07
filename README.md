![Version 1.0](https://img.shields.io/badge/Version-1.0-orange.svg)
![IW4.0 Engine - GSC](https://img.shields.io/badge/IW4.0_Engine-GSC-blue.svg)
![Latest Commit](https://img.shields.io/github/last-commit/kyletimmermans/flashback?color=success&label=Latest%20Commit)
[![kyletimmermans Twitter](http://img.shields.io/twitter/url/http/shields.io.svg?style=social&label=Follow)](https://twitter.com/kyletimmermans)

# <div align="center">Flashback</div>

<div align="center">MW2 Mod Menu (TU6) for the Xbox360 with a Button Bind Era Look and Implementation</div>

</br>

<p align="center">
  <img src="https://github.com/kyletimmermans/flashback/blob/main/media/checkerboard.png?raw=true" alt="Opening Menu"/>
</p>

<p align="center">
  <img src="https://github.com/kyletimmermans/flashback/blob/main/media/opening.png?raw=true" alt="Main Menu"/>
</p>

<p align="center">
  <img src="https://github.com/kyletimmermans/flashback/blob/main/media/main.png?raw=true" alt="Player Menu"/>
</p>

<p align="center">
  <img src="https://github.com/kyletimmermans/flashback/blob/main/media/player.png?raw=true" alt="Checkerboard Map"/>
</p>

</br>

----------------------------------------------
### <div align="center">Video Showcase: https://youtu.be/GghpvnZ5l7c</div>
----------------------------------------------

</br>


### <div>Mod Menu Controls:</div>
<div>BUTTON_BACK = Activate Binds / Menu</div>
<div>DPAD_UP = Open Menu / Scroll Up</div>
<div>DPAD_DOWN = Scroll Down</div>
<div>DPAD_RIGHT = Select</div>
<div>DPAD_LEFT = Go Back / Exit Menu</div>
<div>RB = Move Toggle Right</div>
<div>LB = Move Toggle Left</div>

</br>

#### Main Menu:
- [x] Unlock Menu
  - [x] Unlock All Challenges
  - [x] Instant Level 70
  - [x] Set Insane Leaderboard Stats
  - [x] Set Insane Accolades
  - [x] Colored Classes
  - [x] Big XP Lobby [On Off] 
- [x] Prestige Menu
  - [x] 11th Prestige
  - [x] 10th Prestige
  - [x] 9th Prestige
  - [x] 8th Prestige
  - [x] 7th Prestige
  - [x] 6th Prestige
  - [x] 5th Prestige
  - [x] 4th Prestige
  - [x] 3rd Prestige
  - [x] 2nd Prestige
  - [x] 1st Prestige
  - [x] 0 / No Prestige
- [x] Infection Menu
  - [x] Aimbot [On Off]
  - [x] Wallhack [On Off]
  - [x] Big Minimap / UAV Always On [On Off]
  - [x] Laser [On Off]
  - [x] Far Knife [On Off]
  - [x] Show FPS [On Off]
  - [x] Force Host [On Off]
  - [x] Color Mods [On Off]
  - [x] Auto 3-Round Burst [On Off]
  - [x] Promod [75 80 85 90 Default]
  - [x] Chrome Vision [On Off]
  - [x] Cartoon Vision [On Off]
  - [x] Lucky Care Packages Only [On Off]
  - [x] Nuke Timer [999 0 10]
  - [x] Small Crosshair (Steady Aim) [On Off]
  - [x] Flash/Stun No Effect [On Off]
  - [x] Instant Reload (Sleight of Hand) [On Off]
- [x] Fun Menu
  - [x] Infinite Ammo [On Off]
  - [x] Godmode [On Off]
  - [x] UFO [On Off]
  - [x] Raining Money [On Off]
  - [x] Advertisement
  - [x] Give Dev Sphere [On Off]
  - [x] Give Finger Weapon (Default Weapon) 
- [x] Map Menu
  - [x] Rust
  - [x] Terminal
  - [x] Highrise
  - [x] Estate
  - [x] Karachi
  - [x] Skidrow
  - [x] Scrapyard
- [x] Game Menu
  - [x] Toggle Jump Height [999 0 Default]
  - [x] Toggle Gravity [99 1 999 Default]
  - [x] Toggle Speed [900 800 400 100 0 Default]
  - [x] Toggle Friction [0.001 999 2 Default]
  - [x] Toggle Timescale [0.1 0.5 2 5 10 Default]
  - [x] Toggle Allow Team Change [On Off]
  - [x] Toggle Knockback [99999 0 -999 Default]
  - [x] Toggle Killcam Time [999 1 Default]
  - [x] Toggle Dropshot Time [0.001 99 0 Default]
  - [x] Toggle Melee Range [999 0 1 Default]
  - [x] Toggle Glass Fall Gravity [9999 400 1 Default]
  - [x] Toggle Third Person [On Off]
  - [x] Toggle Persks [On Off]
- [x] ClanTag Menu
  - [x] CowW
  - [x] {Ky}
  - [x] Unbound
  - [x] {7s}
  - [x] {HI}
  - [x] FUCK

#### Player Menu:
- [x] Kick Menu
  - [x] Kick Player 0
  - [x] Kick Player 1
  - [x] Kick Player 2
  - [x] Kick Player 3
  - [x] Kick Player 4
  - [x] Kick Player 5
  - [x] Kick Player 6
  - [x] Kick Player 7
  - [x] Kick Player 8
  - [x] Kick Player 9
  - [x] Kick Player 10
  - [x] Kick Player 11
  - [x] Kick Player 12
  - [x] Kick Player 13
  - [x] Kick Player 14
  - [x] Kick Player 15
  - [x] Kick Player 16
  - [x] Kick Player 17
- [x] Infect All 
- [x] Kill All
- [x] Freeze All [On Off]
- [x] Add Bots [Ally Enemy]

</br>

| Notes |
| --- |
| Only run this patch with the default_mp.xex file provided in the release download folder as I've edited some hex offsets in the file to prevent level 70, prestige mods, or bot mods from causing the "Security Problem on Host - Disconnecting for Safety." error |
| At the beginning of every game, there will be about 3-4 seconds of lag just because it's loading a lot of Dvars |
| There are more instructions on how to load the menu in the README in the release download folder |
| Menu base thanks to Coww from TTG |

</br>

## How Does It All Work?

### The Mod Menu:
Each option in the menu has a collection of pointers associated with each of the DPAD buttons. Starting from the "Main Menu" and "Player Menu". Each of these pointers will point to another menu option e.g. when on the Main Menu option, DPAD_DOWN points to the Player Menu, and when on Player Menu, DPAD_UP points to the Main Menu. So when you move throughout the menu, you are constantly moving along the pointer paths that point to other options and rebinding the DPAD buttons. And when you move to a given menu item, the menu is redrawn on the screen to make the selected item one color, and the rest of the other menu options another single color, to indicate which option you are currently on. Finally, each menu item is binded to a specific function that allows you to run it, e.g. DPAD_RIGHT to infinite_ammo() or noclip().

### Binds Infection:
How can we pass on the infection to other players that don't have a modified console so that they can also use it? The modder with the modified console will set their name to the actual code of the menu, e.g. instead of the map being just something like mp_rust, it will be now be mp_rust; init infection… This works like an injection attack, since you can actually load that map name and it will load the map you specified, as well as load and run the code after the semi colon. The modder will then sit in a private lobby with their map set to: map name + code. It will show some of the code where the preview of the map would be, and the game doesn't have an image of this map since map name + code is not recognized by the game, so it sets it to a checkerboard pattern. Now, someone can join this lobby, back out, start their own game, and since MW2 will set your new lobby map to be the map of the last lobby you were in, it carries over to your lobby. So you got the code into the map name without needing to have a modded console. Start the game without changing the map, and voila, the code from the map name will execute and you'll have the mod menu.

### Modified default_mp.xex:
I honestly can't remember exactly how I removed the restrictions since I made this a few years ago, but I’m pretty sure it went something like this: Get the vanilla TU6 default_mp.xex file online, decompile it with IDA Pro and the [idaxex plugin](https://github.com/emoose/idaxex) ([emoose](https://github.com/emoose)), find all the security checks, replace and patch them with nop instructions, then recompile. It was a lot of trial and error, lots of crashing my console lol.
