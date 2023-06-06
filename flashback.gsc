/*
	Kyle Timmermans
	Flashback MW2 Mod Menu v1.0 (TU6)
	June 6th, 2023
*/

#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;

// dev sphere from _dev.gsc
reflectionProbeButtons()
{
	offset = 100;
	offsetinc = 50;

	while ( getDvarInt( "debug_reflection" ) == 1 )
	{
		if ( self buttonpressed( "BUTTON_X" ) )
			offset += offsetinc;
		if ( self buttonpressed( "BUTTON_Y" ) )
			offset -= offsetinc;
		if ( offset > 1000 )
			offset = 1000;
		if ( offset < 64 )
			offset = 64;

		self.debug_reflectionobject.origin = self geteye() + ( vector_multiply( anglestoforward( self getplayerangles() ), offset ) );

		wait .05;
	}
}

updateReflectionProbe()
{
	for(;;)
	{
		if ( getDvarInt( "debug_reflection" ) == 1 )
		{
			if ( !isDefined( self.debug_reflectionobject ) )
			{
				self.debug_reflectionobject = spawn( "script_model", self geteye() + ( vector_multiply( anglestoforward( self.angles ), 100 ) ) );
				self.debug_reflectionobject setmodel( "test_sphere_silver" );
				self.debug_reflectionobject.origin = self geteye() + ( vector_multiply( anglestoforward( self getplayerangles() ), 100 ) );
				self thread reflectionProbeButtons();
			}
		}
		else if ( getDvarInt( "debug_reflection" ) == 0 )
		{
			if ( isDefined( self.debug_reflectionobject ) )
				self.debug_reflectionobject delete();
		}

		wait( 0.05 );
	}
}

init()
{
	setDvarIfUninitialized( "debug_reflection", "0" );
	setDvarIfUninitialized( "scr_testclients", "18" );
	precacheModel("test_sphere_silver");
	precacheItem("defaultweapon_mp");
	precacheString(&"MP_CHALLENGE_COMPLETED");

	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );

		setDvar( "sv_maxclients", "18" );
		player thread updateReflectionProbe();
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	self waittill("spawned_player");

	// Only host gets menu
	foreach(player in level.players) {
		if (self.name == player.name && player isHost()) {
			self thread createMenu();
			self thread createMenu2();
			self thread doGSCFuncs();
			self thread menuMessage();
			self thread devDoNotify();
		}
	}
}

doUfo()
{
	self endon ("disconnect");
	self endon ("death");

	self setClientDvar( "scr_arena_timelimit", "4" );
	maps\mp\gametypes\_spectating::setSpectatePermissions();   
	self allowSpectateTeam("freelook", true);
	self.sessionstate = "spectator";
	self setContents(0);

	// Stay in UFO until we get the shutdown signal
	while (1) {
		wait 0.1;
		if (getDvarInt("scr_arena_timelimit") == 1337) {
			self.sessionstate = "playing";
			self allowSpectateTeam("freelook", false);
			self setContents(100);
			// Reset end signal
			self setClientDvar( "scr_arena_timelimit", "4" );
			break;
		} else {
			continue;
		}
	}
}

unlockAll()
{
	self endon("disconnect");
	self setPlayerData( "iconUnlocked", "cardicon_prestige10_02", 1);
	chalProgress = 0;
	useBar = createPrimaryProgressBar(25);
	useBarText = createPrimaryProgressBarText(25);
	foreach ( challengeRef, challengeData in level.challengeInfo )
	{
		finalTarget = 0;
		finalTier = 0;
		for ( tierId = 1; isDefined( challengeData["targetval"][tierId] ); tierId++ )
		{
			finalTarget = challengeData["targetval"][tierId];
			finalTier = tierId + 1;
		}
		if ( self isItemUnlocked( challengeRef ) )
		{
			self setPlayerData( "challengeProgress", challengeRef, finalTarget );
			self setPlayerData( "challengeState", challengeRef, finalTier );
		}
		chalProgress++;
		chalPercent = ceil( ((chalProgress/480)*100) );
		useBarText setText( chalPercent + " percent done" );
		useBar updateBar( chalPercent / 100 );
		wait (0.04);
	}
	useBar destroyElem();
	useBarText destroyElem();
	self iPrintlnBold("^2Finished!");
}

createMoney()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	while(1)
	{
		playFx( level._effect["money"], self getTagOrigin( "j_spine4" ) );
		wait 0.5;
	}
}

Godmode()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	self.maxhealth = 90000;
	self.health = self.maxhealth;
	while ( 1 )
	{
		wait .4;
		if ( self.health < self.maxhealth )
		self.health = self.maxhealth;
	}
}

doAmmo()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	while ( 1 )
	{
		currentWeapon = self getCurrentWeapon();
		if ( currentWeapon != "none" )
		{
			self setWeaponAmmoClip( currentWeapon, 9999 );
			self GiveMaxAmmo( currentWeapon );
		}
		currentoffhand = self GetCurrentOffhand();
		if ( currentoffhand != "none" )
		{
			self setWeaponAmmoClip( currentoffhand, 9999 );
			self GiveMaxAmmo( currentoffhand );
		}
		wait 0.05;
	}
}

bigXP(onoff)
{
	if (onoff == 1) {
		self setClientDvar( "scr_ctf_score_suicide", "999999" );
		self setClientDvar( "scr_dd_score_suicide", "999999" );
		self setClientDvar( "scr_dm_score_suicide", "999999" );
		self setClientDvar( "scr_dom_score_suicide", "999999" );
		self setClientDvar( "scr_koth_score_suicide", "999999" );
		self setClientDvar( "scr_sab_score_suicide", "999999" );
		self setClientDvar( "scr_war_score_suicide", "999999" );
		self setClientDvar( "scr_ctf_score_kill", "999999" );
		self setClientDvar( "scr_dd_score_kill", "999999" );
		self setClientDvar( "scr_dm_score_kill", "999999" );
		self setClientDvar( "scr_dom_score_kill", "999999" );
		self setClientDvar( "scr_koth_score_kill", "999999" );
		self setClientDvar( "scr_sab_score_kill", "999999" );
		self setClientDvar( "scr_war_score_kill", "999999" );
		self setClientDvar( "scr_ctf_score_melee", "999999" );
		self setClientDvar( "scr_dd_score_melee", "999999" );
		self setClientDvar( "scr_dm_score_melee", "999999" );
		self setClientDvar( "scr_dom_score_melee", "999999" );
		self setClientDvar( "scr_koth_score_melee", "999999" );
		self setClientDvar( "scr_sab_score_melee", "999999" );
		self setClientDvar( "scr_war_score_melee", "999999" );
	}

	if (onoff == 0) {
		self setClientDvar( "scr_ctf_score_suicide", "-100" );
		self setClientDvar( "scr_dd_score_suicide", "-100" );
		self setClientDvar( "scr_dm_score_suicide", "-100" );
		self setClientDvar( "scr_dom_score_suicide", "-100" );
		self setClientDvar( "scr_koth_score_suicide", "-100" );
		self setClientDvar( "scr_sab_score_suicide", "-100" );
		self setClientDvar( "scr_war_score_suicide", "-100" );
		self setClientDvar( "scr_ctf_score_kill", "50" );
		self setClientDvar( "scr_dd_score_kill", "50" );
		self setClientDvar( "scr_dm_score_kill", "50" );
		self setClientDvar( "scr_dom_score_kill", "50" );
		self setClientDvar( "scr_koth_score_kill", "50" );
		self setClientDvar( "scr_sab_score_kill", "50" );
		self setClientDvar( "scr_war_score_kill", "50" );
		self setClientDvar( "scr_ctf_score_melee", "50" );
		self setClientDvar( "scr_dd_score_melee", "50" );
		self setClientDvar( "scr_dm_score_melee", "50" );
		self setClientDvar( "scr_dom_score_melee", "50" );
		self setClientDvar( "scr_koth_score_melee", "50" );
		self setClientDvar( "scr_sab_score_melee", "50" );
		self setClientDvar( "scr_war_score_melee", "50" );
	}
}

coloredClasses()
{
	i = 0;
	j = 1;
	while (i < 10)
	{
		self setPlayerData("customClasses", i, "name", "^" + j + self.name + " " + (i + 1));
		i++;
		j++;
		if (j == 7) j = 1;
	}
}

getAccolades()
{
	amount = 10000;
	foreach ( ref, award in level.awards ) {
		self setPlayerData( "awards", ref, self getPlayerData( "awards", ref ) + amount );
	}
	self giveAccolade( "targetsdestroyed", amount );
	self giveAccolade( "bombsplanted", amount );
	self giveAccolade( "bombsdefused", amount );
	self giveAccolade( "bombcarrierkills", amount );
	self giveAccolade( "bombscarried", amount );
	self giveAccolade( "killsasbombcarrier", amount );
	self giveAccolade( "flagscaptured", amount );
	self giveAccolade( "flagsreturned", amount );
	self giveAccolade( "flagcarrierkills", amount );
	self giveAccolade( "flagscarried" , amount);
	self giveAccolade( "killsasflagcarrier", amount );
	self giveAccolade( "hqsdestroyed", amount );
	self giveAccolade( "hqscaptured", amount );
	self giveAccolade( "pointscaptured", amount );
}

giveAccolade( ref, amount )
{
	self setPlayerData( "awards", ref, self getPlayerData( "awards", ref ) + amount );
}

setStats(deaths, kills, score, assists, headshots, wins, winStreak, killStreak, accuracy, hits, misses, losses)
{
	self setPlayerData( "deaths" , deaths );
	self setPlayerData( "kills" , kills );
	self setPlayerData( "score" , score );
	self setPlayerData( "assists" , assists );
	self setPlayerData( "headshots" , headshots );
	self setPlayerData( "wins" , wins );
	self setPlayerData( "winStreak" , winStreak );
	self setPlayerData( "killStreak" , killStreak );
	self setPlayerData( "accuracy" , accuracy );
	self setPlayerData( "hits" , hits );
	self setPlayerData( "misses" , misses );
	self setPlayerData( "losses" , losses );
}

insaneStats()
{
	self setStats(0,2147480000,2147000000,2147480000,2147480000,2147480000,1337,1337,2147483647,1337,0,-10);
}

setPrestige(num)
{	
	self setPlayerData("prestige", num);
}

addBots(team)
{
	wait 0.5;

	ent = addtestclient();

	if (!isdefined(ent)) {
		iPrintln("Could not add test client");
		wait 1;
	}
		
	ent.pers["isBot"] = true;

	// If FFA spawn bot w/ no team
	if (getDvar("g_gametype") == "dm") {
		ent thread TestClient("autoassign");
	} else {
		ent thread TestClient(team);
	}
	
	if (matchMakingGame())
		setMatchData( "hasBots", true );
}

TestClient(team)
{
	self endon( "disconnect" );

	while(!isdefined(self.pers["team"]))
		wait .05;

	self notify("menuresponse", game["menu_team"], team);
	wait 0.5;
	
	while(1)
	{
		class = "class" + randomInt( 5 );
		
		self notify("menuresponse", "changeclass", class);
			
		self waittill( "spawned_player" );
		wait ( 0.10 );
	}
}

killAll()
{
	foreach( player in level.players ) {
		player suicide();
	}
}

giveDefaultWeapon()
{
	self endon("death");	
	self takeWeapon(self getCurrentWeapon());
	self giveWeapon("defaultweapon_mp", 0, false);
	self switchToWeapon("defaultweapon_mp", 0, false);
}

instantSeventy()
{
	self setPlayerData( "experience", 2516000 );
}

endHack()
{
	self suicide();
}

createMenu()
{
	/* Pre Lobby Dvars
	No sv_ or developer dvars needed for TU6 (breaks setPlayerData) */
	wait 0.3;
	self setClientDvar( "loc_warnings", "0" );
	self setClientDvar( "loc_warningsAsErrors", "0" ); 
	self setClientDvar( "loc_warningsUI", "0" );

	// Make private matches count like online
	if (getDvarInt("xblive_privatematch") == 1) {
		self setClientDvar( "ui_promotion", "1");
		self setClientDvar( "scr_forcerankedmatch", "1" );
		self setClientDvar( "onlinegame", "1" );
		self setClientDvar( "onlinegameandhost", "1" );
		self setClientDvar( "onlineunrankedgameandhost", "0" ); 
		self setClientDvar( "xblive_privatematch", "0" );
	}
	// Setting up the mods
	wait 0.3;
	self setClientDvar( "ui_mapname", "mp_rust;bind button_back VSTR BINDS;say ^1Kyle's ^2Flasback ^5Menu ^2- ^1@^2Kyle^5Timmermans^7;jump_height 999;g_speed 900;g_gravity 90;bg_fallDamageMaxHeight 9999;bg_fallDamageMinHeight 9999" );
	self setClientDvar( "BINDS", "set didyouknow ^5@^1Kyle^2Timmermans;togglescores;vstr GAME;vstr MODS;bind DPAD_UP vstr UP;bind DPAD_DOWN vstr DOWN;bind DPAD_RIGHT vstr RIGHT;bind DPAD_LEFT vstr LEFT;vstr OPEN" );
	self setClientDvar( "REBIND", "bind DPAD_UP vstr UP;bind DPAD_RIGHT vstr RIGHT;bind DPAD_LEFT vstr LEFT;bind BUTTON_RSHLDR vstr RB;bind BUTTON_LSHLDR vstr LB" );
	self setClientDvar( "UNBIND", "bind DPAD_UP vstr MAIN0;bind BUTTON_RSHLDR +frag;bind BUTTON_LSHLDR +smoke;bind DPAD_RIGHT +actionslot 4;bind DPAD_LEFT +actionslot 3" );

	// Basic Menu Functions
	wait 0.3;
	self setClientDvar( "UP", "" );
	self setClientDvar( "DOWN", "" );
	self setClientDvar( "RIGHT", "vstr MSG;vstr EXEC" );
	self setClientDvar( "LEFT", "vstr BACK" );
	self setClientDvar( "RB", "" );
	self setClientDvar( "LB", "" );

	// Core Menu Functions
	wait 0.3;
	self setClientDvar( "EXEC", "vstr _" );
	self setClientDvar( "MSG", "vstr _" );

	// Open/Close Function
	wait 0.3;
	self setClientDvar( "OPEN", "set BACK vstr EXIT;set UP vstr MAIN0" );
	self setClientDvar( "EXIT", "set BACK vstr OPEN;cg_chatHeight 0;set EXEC +actionslot 4;vstr UNBIND" );

	// Dvar Collection
	wait 0.3;
	// Make private matches count like online
	if (getDvarInt("xblive_privatematch") == 1) {
		self setClientDvar( "GAME", "loc_warnings 0;loc_warningsAsErrors 0;loc_warningsUI 0;onlinegame 1;onlinegameandhost 1;onlineunrankedgameandhost 0;scr_forcerankedmatch 1;ui_promotion 1;xblive_privatematch 0" );
	} else if (getDvarInt("xblive_privatematch") == 0) {
		self setClientDvar( "GAME", "loc_warnings 0;loc_warningsAsErrors 0;loc_warningsUI 0" );
	}
	self setClientDvar( "MODS", "cg_hudChatPosition 250 250;bg_fallDamageMaxHeight 9999;bg_fallDamageMinHeight 9999" );
	self setClientDvar( "INFECT", "ui_gametype gtnw;bind button_back VSTR BINDS;motd ^1Kyle's ^2Flashback ^1Menu ^2- ^5@KyleTimmermans^7;jump_height 999;g_speed 800;g_gravity 99;bg_fallDamageMaxHeight 9999;bg_fallDamageMinHeight 9999" );
	// On Presets
	self setClientDvar( "AIMBOTON", "aim_autoaim_enabled 1;aim_autoaim_lerp 100;aim_autoaim_region_height 120;aim_autoaim_region_width 99999999;aim_autoAimRangeScale 2;aim_lockon_debug 1;aim_lockon_enabled 1;aim_lockon_region_height 0;aim_lockon_region_width 1386;aim_lockon_strength 1;aim_lockon_deflection 0.05;aim_input_graph_debug 0;aim_input_graph_enabled 1;aim_automelee_range 255;aim_automelee_region_height 999;aim_automelee_region_width 999;aim_slowdown_debug 1;aim_slowdown_pitch_scale 0.4;aim_slowdown_pitch_scale_ads 0.5;aim_slowdown_region_height 2.85;aim_slowdown_region_width 2.85;aim_slowdown_yaw_scale 0.4;aim_slowdown_yaw_scale_ads 0.5" );
	self setClientDvar( "WALLHACKON", "r_znear 35;r_zfar 0;r_znear_depthhack 2" );
	self setClientDvar( "UAVON", "compassSize 1.5;g_compassshowenemies 1;ui_hud_hardcore 1;compassEnemyFootstepEnabled 1;compass 0;scr_game_forceuav 1;compassEnemyFootstepEnabled 1;compassEnemyFootstepMaxRange 99999;compassEnemyFootstepMaxZ 99999;compassEnemyFootstepMinSpeed 0;compassRadarUpdateTime 0.001;compassFastRadarUpdateTime 2;compassRadarPingFadeTime 9999;compassSoundPingFadeTime 9999;compassRadarUpdateTime 0.001;compassFastRadarUpdateTime 0.001;compassRadarLineThickness 0;compassMaxRange 9999" );
	self setClientDvar( "COLORMODSON", "cg_ScoresPing_MaxBars 8;cg_ScoresPing_MedColor 0 0.49 1 1;cg_ScoresPing_LowColor 0 0.68 1 1;cg_ScoresPing_HighColor 0 0 1 1;ui_playerPartyColor 1 0 0 1;cg_scoreboardMyColor 1 0 0 1;lobby_searchingPartyColor 0 1.28 0 .8;con_typewriterColorGlowCheckpoint 0 0 1 1;con_typewriterColorGlowCompleted 0 0 1 1;con_typewriterColorGlowFailed 0 0 1 1;con_typewriterColorGlowUpdated 0 0 1 1;ui_connectScreenTextGlowColor 1 0 0 1;lowAmmoWarningColor1 0 0 1 1;lowAmmoWarningColor2 1 0 0 1;lowAmmoWarningNoAmmoColor1 0 0 1 1;lowAmmoWarningNoAmmoColor2 1 0 0 1;lowAmmoWarningNoReloadColor1 0 0 1 1;vstr COLORMODSONTWO" );
	self setClientDvar( "COLORMODSONTWO", "lowAmmoWarningNoReloadColor2 1 0 0 1;g_TeamColor_Allies 0 0 2.55 .8;g_TeamColor_Axis 1 0 0 1;g_ScoresColor_Allies 0 1.28 0 .8;g_ScoresColor_Axis .9 .3 1 .7;g_ScoresColor_Free 0 1.28 0 .8;g_ScoresColor_Spectator 0 2.55 2.55 .8" );
	self setClientDvar( "FORCEHOSTON", "badhost_maxDoISuckFrames 0;badhost_maxHappyPingTime 99999;badhost_minTotalClientsForHappyTest 99999;party_hostmigration 0;;party_connectToOthers 0;party_connectTimeout 1" );
	self setClientDvar( "FARKNIFEON", "perk_extendedMeleeRange 999;player_meleeRange 999" );
	self setClientDvar( "LUCKYCAREPACKAGESON", "scr_airdrop_ac130 999;scr_airdrop_helicopter_minigun 999;scr_airdrop_mega_ac130 999;scr_airdrop_mega_helicopter_minigun 999" );
	// Off Presets
	self setClientDvar( "FARKNIFEOFF", "perk_extendedMeleeRange 176;player_meleeRange 64" );
	self setClientDvar( "WALLHACKOFF", "r_znear 4;r_zfar 0;r_znear_depthhack 0.1" );
	self setClientDvar( "AIMBOTOFF", "aim_autoaim_enabled 0;aim_autoaim_lerp 40;aim_autoaim_region_width 160;aim_autoAimRangeScale 1;aim_lockon_debug 0;aim_lockon_region_height 90;aim_lockon_region_width 90;aim_lockon_strength 0.6;aim_automelee_range 128;aim_automelee_region_height 240;aim_automelee_region_width 320;aim_slowdown_debug 0;aim_slowdown_region_height 90;aim_slowdown_region_width 90;" );
	self setClientDvar( "UAVOFF", "compassSize 1;ui_hud_hardcore 0;compassEnemyFootstepEnabled 0;compass 1;scr_game_forceuav 0;compassEnemyFootstepEnabled 0;compassEnemyFootstepMaxRange 500;compassEnemyFootstepMaxZ 500;compassEnemyFootstepMinSpeed 140;compassRadarUpdateTime 4;compassRadarPingFadeTime 4;compassSoundPingFadeTime 2;compassRadarUpdateTime 4;compassFastRadarUpdateTime 2;compassRadarLineThickness 0.4;compassMaxRange 2500" );
	self setClientDvar( "FORCEHOSTOFF", "badhost_maxDoISuckFrames 300;badhost_maxHappyPingTime 400;badhost_minTotalClientsForHappyTest 3;party_hostmigration 1;party_connectToOthers 1;party_connectTimeout 1000" );
	self setClientDvar( "COLORMODSOFF", "cg_ScoresPing_MaxBars 4;cg_ScoresPing_MedColor 0.8 0.8 0 1;cg_ScoresPing_LowColor 0 0.74902 0 1;cg_ScoresPing_HighColor 0.8 0 0 1;ui_playerPartyColor 1 0.8 0.4 1;cg_scoreboardMyColor 1 0.8 0.4 1;lobby_searchingPartyColor 0.941177 0.768627 0.321569 1;con_typewriterColorGlowCheckpoint 0.6 0.5 0.6 1;con_typewriterColorGlowCompleted 0 0.3 0.8 1;con_typewriterColorGlowFailed 0.8 0 0 1;con_typewriterColorGlowUpdated 0 0.6 0.18 1;ui_connectScreenTextGlowColor 0.3 0.6 0.3 1;lowAmmoWarningColor1 0.701961 0.701961 0.701961 0.8;lowAmmoWarningColor2 1 1 1 1;vstr COLORMODSOFFTWO" );
	self setClientDvar( "COLORMODSOFFTWO", "lowAmmoWarningNoAmmoColor1 0.8 0.25098 0.301961 0.8;lowAmmoWarningNoAmmoColor2 1 0.25098 0.301961 1;lowAmmoWarningNoReloadColor1 0.701961 0.701961 0.301961;lowAmmoWarningNoReloadColor2 0.701961 0.701961 0.301961 1;g_TeamColor_Allies 0.6 0.639216 0.690196 1;g_TeamColor_Axis 0.65098 0.568627 0.411765 1;g_ScoresColor_Allies 0.2 0.2 0.2 0;g_ScoresColor_Axis 0.517647 0.298039 0.203922 0;g_ScoresColor_Free 0.760784 0.780392 0.101961 0;g_ScoresColor_Spectator 0.25098 0.25098 0.25098 0" );
	self setClientDvar( "LUCKYCAREPACKAGESOFF", "scr_airdrop_ac130 3;scr_airdrop_ammo 17;scr_airdrop_counter_uav 15;scr_airdrop_emp 1;scr_airdrop_harrier_airstrike 7;scr_airdrop_helicopter 7;scr_airdrop_helicopter_flares 5;scr_airdrop_helicopter_minigun 3;scr_airdrop_mega_ac130 2;scr_airdrop_mega_ammo 12;scr_airdrop_mega_counter_uav 16;scr_airdrop_mega_emp 0;scr_airdrop_mega_harrier_airstrike 5;scr_airdrop_mega_helicopter 5;scr_airdrop_mega_helicopter_flares 3;scr_airdrop_mega_helicopter_minigun 2;scr_airdrop_mega_nuke 0;scr_airdrop_mega_precision_airstrike 10;scr_airdrop_mega_predator_missile 14;scr_airdrop_mega_sentry 16;scr_airdrop_mega_stealth_airstrike 3;scr_airdrop_mega_uav 12;scr_airdrop_nuke 0;scr_airdrop_precision_airstrike 11;scr_airdrop_predator_missile 12;scr_airdrop_sentry 12;scr_airdrop_stealth_airstrike 5;scr_airdrop_uav 17" );

	// First Menu
	wait 0.3;
	self setClientDvar( "MAIN0", "vstr REBIND;set UP vstr MAIN1;set DOWN vstr MAIN1;set BACK vstr EXIT;cg_chatHeight 3;set MSG loc_warnings 0;set EXEC vstr SUB0_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^2Main Menu;say ^1Player Menu" );
	self setClientDvar( "MAIN1", "vstr REBIND;set UP vstr MAIN0;set DOWN vstr MAIN0;set BACK vstr EXIT;cg_chatHeight 3;set MSG loc_warnings 0;set EXEC vstr SUB5_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^1Main Menu;say ^2Player Menu" );

	// Main Menu
	wait 0.3;
	self setClientDvar( "SUB0_0", "set UP vstr SUB0_6;set DOWN vstr SUB0_1;set BACK vstr MAIN0;cg_chatHeight 8;set MSG loc_warnings 0;set EXEC vstr SUB1_0;say ^5Main Menu;say ^2Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^1Game Menu;say ^1ClanTag Menu" );
	self setClientDvar( "SUB0_1", "set UP vstr SUB0_0;set DOWN vstr SUB0_2;set BACK vstr MAIN0;cg_chatHeight 8;set MSG loc_warnings 0;set EXEC vstr SUB2_0;say ^5Main Menu;say ^1Unlock Menu;say ^2Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^1Game Menu;say ^1ClanTag Menu" );
	self setClientDvar( "SUB0_2", "set UP vstr SUB0_1;set DOWN vstr SUB0_3;set BACK vstr MAIN0;cg_chatHeight 8;set MSG loc_warnings 0;set EXEC vstr SUB3_0;say ^5Main Menu;say ^1Unlock Menu;say ^1Prestige Menu;say ^2Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^1Game Menu;say ^1ClanTag Menu" );
	self setClientDvar( "SUB0_3", "set UP vstr SUB0_2;set DOWN vstr SUB0_4;set BACK vstr MAIN0;cg_chatHeight 8;set MSG loc_warnings 0;set EXEC vstr SUB4_0;say ^5Main Menu;say ^1Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^2Fun Menu;say ^1Map Menu;say ^1Game Menu;say ^1ClanTag Menu" );
	self setClientDvar( "SUB0_4", "set UP vstr SUB0_3;set DOWN vstr SUB0_5;set BACK vstr MAIN0;cg_chatHeight 8;set MSG loc_warnings 0;set EXEC vstr SUB20_0;say ^5Main Menu;say ^1Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^2Map Menu;say ^1Game Menu;say ^1ClanTag Menu" );
	self setClientDvar( "SUB0_5", "set UP vstr SUB0_4;set DOWN vstr SUB0_6;set BACK vstr MAIN0;cg_chatHeight 8;set MSG loc_warnings 0;set EXEC vstr SUB15_0;say ^5Main Menu;say ^1Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^2Game Menu;say ^1ClanTag Menu" );
	self setClientDvar( "SUB0_6", "set UP vstr SUB0_5;set DOWN vstr SUB0_0;set BACK vstr MAIN0;cg_chatHeight 8;set MSG loc_warnings 0;set EXEC vstr SUB7_0;say ^5Main Menu;say ^1Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^1Game Menu;say ^2ClanTag Menu" );

	// Sub Menu - Unlock Menu
	wait 0.3;
	self setClientDvar( "SUB1_0", "set UP vstr SUB1_5;set DOWN vstr SUB1_1;set BACK vstr SUB0_0;cg_chatHeight 7;set MSG ui_customClassName ^1Unlocking ^2All ^5Challenges;set EXEC scr_arena_scorelimit 6;say ^5Unlock Menu;say ^2Unlock All Challenges;say ^1Instant Level 70;say ^1Set Insane Leaderboard Stats;say ^1Set Insane Accolades;say ^1Colored Classes;say ^1Big XP Lobby" );
	self setClientDvar( "SUB1_1", "set UP vstr SUB1_0;set DOWN vstr SUB1_2;set BACK vstr SUB0_0;cg_chatHeight 7;set MSG ui_customClassName ^1Level ^2Set ^5to^1: ^670!;set EXEC scr_arena_scorelimit 28;say ^5Unlock Menu;say ^1Unlock All Challenges;say ^2Instant Level 70;say ^1Set Insane Leaderboard Stats;say ^1Set Insane Accolades;say ^1Colored Classes;say ^1Big XP Lobby" );
	self setClientDvar( "SUB1_2", "set UP vstr SUB1_1;set DOWN vstr SUB1_3;set BACK vstr SUB0_0;cg_chatHeight 7;set MSG ui_customClassName ^1Insane ^2Stats ^5Set!;set EXEC scr_arena_scorelimit 8;say ^5Unlock Menu;say ^1Unlock All Challenges;say ^1Instant Level 70;say ^2Set Insane Leaderboard Stats;say ^1Set Insane Accolades;say ^1Colored Classes;say ^1Big XP Lobby" );
	self setClientDvar( "SUB1_3", "set UP vstr SUB1_2;set DOWN vstr SUB1_4;set BACK vstr SUB0_0;cg_chatHeight 7;set MSG ui_customClassName ^1Insane ^2Accolades ^5Set!;set EXEC scr_arena_scorelimit 9;say ^5Unlock Menu;say ^1Unlock All Challenges;say ^1Instant Level 70;say ^1Set Insane Leaderboard Stats;say ^2Set Insane Accolades;say ^1Colored Classes;say ^1Big XP Lobby" );
	self setClientDvar( "SUB1_4", "set UP vstr SUB1_3;set DOWN vstr SUB1_5;set BACK vstr SUB0_0;cg_chatHeight 7;set MSG ui_customClassName ^1C^2o^3l^4o^5r^6e^1d ^2C^3l^4a^5s^6s^1e^2s ^3S^4e^5t^6!;set EXEC scr_arena_scorelimit 7;say ^5Unlock Menu;say ^1Unlock All Challenges;say ^1Instant Level 70;say ^1Set Insane Leaderboard Stats;say ^1Set Insane Accolades;say ^2Colored Classes;say ^1Big XP Lobby" );
	self setClientDvar( "SUB1_5", "set UP vstr SUB1_4;set DOWN vstr SUB1_0;set RB vstr SUB1_6;set LB vstr SUB1_6;set BACK vstr SUB0_0;cg_chatHeight 7;set MSG ui_customClassName ^1Big ^2XP ^5Lobby ^1Set!;set EXEC scr_arena_scorelimit 5;say ^5Unlock Menu;say ^1Unlock All Challenges;say ^1Instant Level 70;say ^1Set Insane Leaderboard Stats;say ^1Set Insane Accolades;say ^1Colored Classes;say ^2Big XP Lobby ^7[^2On ^1Off^7]" );
	self setClientDvar( "SUB1_6", "set UP vstr SUB1_4;set DOWN vstr SUB1_0;set RB vstr SUB1_5;set LB vstr SUB1_5;set BACK vstr SUB0_0;cg_chatHeight 7;set MSG ui_customClassName ^1Big ^2XP ^5Lobby ^1Off!;set EXEC scr_arena_scorelimit 22;say ^5Unlock Menu;say ^1Unlock All Challenges;say ^1Instant Level 70;say ^1Set Insane Leaderboard Stats;say ^1Set Insane Accolades;say ^1Colored Classes;say ^2Big XP Lobby ^7[^1On ^2Off^7]" );

	// Sub Menu - Prestige Menu
	wait 0.3;
	self setClientDvar( "SUB2_0", "set UP vstr SUB2_6;set DOWN vstr SUB2_1;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^111th ^2Prestige ^5Set!;set EXEC scr_arena_scorelimit 21;say ^5Prestige Menu;say ^211th Prestige;say ^110th Prestige;say ^19th Prestige;say ^18th Prestige;say ^17th Prestige;say ^16th Prestige;say ^1More" );
	self setClientDvar( "SUB2_1", "set UP vstr SUB2_0;set DOWN vstr SUB2_2;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^110th ^2Prestige ^5Set!;set EXEC scr_arena_scorelimit 20;say ^5Prestige Menu;say ^111th Prestige;say ^210th Prestige;say ^19th Prestige;say ^18th Prestige;say ^17th Prestige;say ^16th Prestige;say ^1More" );
	self setClientDvar( "SUB2_2", "set UP vstr SUB2_1;set DOWN vstr SUB2_3;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^19th ^2Prestige ^5Set!;set EXEC scr_arena_scorelimit 19;say ^5Prestige Menu;say ^111th Prestige;say ^110th Prestige;say ^29th Prestige;say ^18th Prestige;say ^17th Prestige;say ^16th Prestige;say ^1More" );
	self setClientDvar( "SUB2_3", "set UP vstr SUB2_2;set DOWN vstr SUB2_4;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^18th ^2Prestige ^5Set!;set EXEC scr_arena_scorelimit 18;say ^5Prestige Menu;say ^111th Prestige;say ^110th Prestige;say ^19th Prestige;say ^28th Prestige;say ^17th Prestige;say ^16th Prestige;say ^1More" );
	self setClientDvar( "SUB2_4", "set UP vstr SUB2_3;set DOWN vstr SUB2_5;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^17th ^2Prestige ^5Set!;set EXEC scr_arena_scorelimit 17;say ^5Prestige Menu;say ^111th Prestige;say ^110th Prestige;say ^19th Prestige;say ^18th Prestige;say ^27th Prestige;say ^16th Prestige;say ^1More" );
	self setClientDvar( "SUB2_5", "set UP vstr SUB2_4;set DOWN vstr SUB2_6;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^16th ^2Prestige ^5Set!;set EXEC scr_arena_scorelimit 16;say ^5Prestige Menu;say ^111th Prestige;say ^110th Prestige;say ^19th Prestige;say ^18th Prestige;say ^17th Prestige;say ^26th Prestige;say ^1More" );
	self setClientDvar( "SUB2_6", "set UP vstr SUB2_5;set DOWN vstr SUB2_0;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG loc_warnings 0;set EXEC vstr SUB8_0;say ^5Prestige Menu;say ^111th Prestige;say ^110th Prestige;say ^19th Prestige;say ^18th Prestige;say ^17th Prestige;say ^16th Prestige;say ^2More" );

	// Sub Menu - Prestige Menu 2
	wait 0.3;
	self setClientDvar( "SUB8_0", "set UP vstr SUB8_5;set DOWN vstr SUB8_1;set BACK vstr SUB2_0;cg_chatHeight 7;set MSG ui_customClassName ^15th ^2Prestige ^5Set!;set EXEC scr_arena_scorelimit 15;say ^5Prestige Menu;say ^25th Prestige;say ^14th Prestige;say ^13rd Prestige;say ^12nd Prestige;say ^11st Prestige;say ^10 / No Prestige" );
	self setClientDvar( "SUB8_1", "set UP vstr SUB8_0;set DOWN vstr SUB8_2;set BACK vstr SUB2_0;cg_chatHeight 7;set MSG ui_customClassName ^14th ^2Prestige ^5Set!;set EXEC scr_arena_scorelimit 14;say ^5Prestige Menu;say ^15th Prestige;say ^24th Prestige;say ^13rd Prestige;say ^12nd Prestige;say ^11st Prestige;say ^10 / No Prestige" );
	self setClientDvar( "SUB8_2", "set UP vstr SUB8_1;set DOWN vstr SUB8_3;set BACK vstr SUB2_0;cg_chatHeight 7;set MSG ui_customClassName ^13rd ^2Prestige ^5Set!;set EXEC scr_arena_scorelimit 13;say ^5Prestige Menu;say ^15th Prestige;say ^14th Prestige;say ^23rd Prestige;say ^12nd Prestige;say ^11st Prestige;say ^10 / No Prestige" );
	self setClientDvar( "SUB8_3", "set UP vstr SUB8_2;set DOWN vstr SUB8_4;set BACK vstr SUB2_0;cg_chatHeight 7;set MSG ui_customClassName ^12nd ^2Prestige ^5Set!;set EXEC scr_arena_scorelimit 12;say ^5Prestige Menu;say ^15th Prestige;say ^14th Prestige;say ^13rd Prestige;say ^22nd Prestige;say ^11st Prestige;say ^10 / No Prestige" );
	self setClientDvar( "SUB8_4", "set UP vstr SUB8_3;set DOWN vstr SUB8_5;set BACK vstr SUB2_0;cg_chatHeight 7;set MSG ui_customClassName ^11st ^2Prestige ^5Set!;set EXEC scr_arena_scorelimit 11;say ^5Prestige Menu;say ^15th Prestige;say ^14th Prestige;say ^13rd Prestige;say ^12nd Prestige;say ^21st Prestige;say ^10 / No Prestige" );
	self setClientDvar( "SUB8_5", "set UP vstr SUB8_4;set DOWN vstr SUB8_0;set BACK vstr SUB2_0;cg_chatHeight 7;set MSG ui_customClassName ^10 / No ^2Prestige ^5Set!;set EXEC scr_arena_scorelimit 10;say ^5Prestige Menu;say ^15th Prestige;say ^14th Prestige;say ^13rd Prestige;say ^12nd Prestige;say ^11st Prestige;say ^20 / No Prestige" );

	// Sub Menu - Infection Menu
	wait 0.3;
	self setClientDvar( "SUB3_0", "set UP vstr SUB3_6;set DOWN vstr SUB3_1;set RB vstr SUB3_7;set LB vstr SUB3_7;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Aimbot ^2Now ^5Set!;set EXEC vstr AIMBOTON;say ^5Infection Menu;say ^2Aimbot ^7[^2On ^1Off^7];say ^1Wallhack;say ^1Big Minimap / UAV Always On;say ^1Laser;say ^1Far Knife;say ^1Show FPS;say ^1More" );
	self setClientDvar( "SUB3_7", "set UP vstr SUB3_6;set DOWN vstr SUB3_1;set RB vstr SUB3_0;set LB vstr SUB3_0;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Aimbot ^2Turned ^5Off!;set EXEC vstr AIMBOTOFF;say ^5Infection Menu;say ^2Aimbot ^7[^1On ^2Off^7];say ^1Wallhack;say ^1Big Minimap / UAV Always On;say ^1Laser;say ^1Far Knife;say ^1Show FPS;say ^1More" );
	self setClientDvar( "SUB3_1", "set UP vstr SUB3_0;set DOWN vstr SUB3_2;set RB vstr SUB3_8;set LB vstr SUB3_8;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Wallhack ^2Now ^5Set!;set EXEC vstr WALLHACKON;say ^5Infection Menu;say ^1Aimbot;say ^2Wallhack ^7[^2On ^1Off^7];say ^1Big Minimap / UAV Always On;say ^1Laser;say ^1Far Knife;say ^1Show FPS;say ^1More" );
	self setClientDvar( "SUB3_8", "set UP vstr SUB3_0;set DOWN vstr SUB3_2;set RB vstr SUB3_1;set LB vstr SUB3_1;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Wallhack ^2Turned ^5Off!;set EXEC vstr WALLHACKOFF;say ^5Infection Menu;say ^1Aimbot;say ^2Wallhack ^7[^1On ^2Off^7];say ^1Big Minimap / UAV Always On;say ^1Laser;say ^1Far Knife;say ^1Show FPS;say ^1More" );
	self setClientDvar( "SUB3_2", "set UP vstr SUB3_1;set DOWN vstr SUB3_3;set RB vstr SUB3_9;set LB vstr SUB3_9;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1UAV Dvars ^2Now ^5Set!;set EXEC vstr UAVON;say ^5Infection Menu;say ^1Aimbot;say ^1Wallhack;say ^2Big Minimap / UAV Always On ^7[^2On ^1Off^7];say ^1Laser;say ^1Far Knife;say ^1Show FPS;say ^1More" );
	self setClientDvar( "SUB3_9", "set UP vstr SUB3_1;set DOWN vstr SUB3_3;set RB vstr SUB3_2;set LB vstr SUB3_2;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1UAV Dvars ^2Turned ^5Off!;set EXEC vstr UAVOFF;say ^5Infection Menu;say ^1Aimbot;say ^1Wallhack;say ^2Big Minimap / UAV Always On ^7[^1On ^2Off^7];say ^1Laser;say ^1Far Knife;say ^1Show FPS;say ^1More" );
	self setClientDvar( "SUB3_3", "set UP vstr SUB3_2;set DOWN vstr SUB3_4;set RB vstr SUB3_10;set LB vstr SUB3_10;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Laser ^2Now ^5Set!;set EXEC laserForceOn 1;say ^5Infection Menu;say ^1Aimbot;say ^1Wallhack;say ^1Big Minimap / UAV Always On;say ^2Laser ^7[^2On ^1Off^7];say ^1Far Knife;say ^1Show FPS;say ^1More" );
	self setClientDvar( "SUB3_10", "set UP vstr SUB3_2;set DOWN vstr SUB3_4;set RB vstr SUB3_3;set LB vstr SUB3_3;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Laser ^2Turned ^5Off!;set EXEC laserForceOn 0;say ^5Infection Menu;say ^1Aimbot;say ^1Wallhack;say ^1Big Minimap / UAV Always On;say ^2Laser ^7[^1On ^2Off^7];say ^1Far Knife;say ^1Show FPS;say ^1More" );
	self setClientDvar( "SUB3_4", "set UP vstr SUB3_3;set DOWN vstr SUB3_5;set RB vstr SUB3_11;set LB vstr SUB3_11;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Far Knife ^2Now ^5Set!;set EXEC vstr FARKNIFEON;say ^5Infection Menu;say ^1Aimbot;say ^1Wallhack;say ^1Big Minimap / UAV Always On;say ^1Laser;say ^2Far Knife ^7[^2On ^1Off^7];say ^1Show FPS;say ^1More" );
	self setClientDvar( "SUB3_11", "set UP vstr SUB3_3;set DOWN vstr SUB3_5;set RB vstr SUB3_4;set LB vstr SUB3_4;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Far Knife ^2Turned ^5Off!;set EXEC vstr FARKNIFEOFF;say ^5Infection Menu;say ^1Aimbot;say ^1Wallhack;say ^1Big Minimap / UAV Always On;say ^1Laser;say ^2Far Knife ^7[^1On ^2Off^7];say ^1Show FPS;say ^1More" );
	self setClientDvar( "SUB3_5", "set UP vstr SUB3_4;set DOWN vstr SUB3_6;set RB vstr SUB3_12;set LB vstr SUB3_12;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Show FPS ^2Now ^5Set!;set EXEC cg_drawFPS 1;say ^5Infection Menu;say ^1Aimbot;say ^1Wallhack;say ^1Big Minimap / UAV Always On;say ^1Laser;say ^1Far Knife;say ^2Show FPS ^7[^2On ^1Off^7];say ^1More" );
	self setClientDvar( "SUB3_12", "set UP vstr SUB3_4;set DOWN vstr SUB3_6;set RB vstr SUB3_5;set LB vstr SUB3_5;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Show FPS ^2Turned ^5Off!;set EXEC cg_drawFPS 0;say ^5Infection Menu;say ^1Aimbot;say ^1Wallhack;say ^1Big Minimap / UAV Always On;say ^1Laser;say ^1Far Knife;say ^2Show FPS ^7[^1On ^2Off^7];say ^1More" );
	self setClientDvar( "SUB3_6", "set UP vstr SUB3_5;set DOWN vstr SUB3_0;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG loc_warnings 0;set EXEC vstr SUB9_0;say ^5Infection Menu;say ^1Aimbot;say ^1Wallhack;say ^1Big Minimap / UAV Always On;say ^1Laser;say ^1Far Knife;say ^1Show FPS;say ^2More" );

	// Sub Menu - Infection Menu 2
	wait 0.3;
	self setClientDvar( "SUB9_0", "set UP vstr SUB9_6;set RB vstr SUB9_7;set LB vstr SUB9_7;set DOWN vstr SUB9_1;set BACK vstr SUB3_0;cg_chatHeight 8;set MSG ui_customClassName ^1Force ^2Host ^5Set!;set EXEC vstr FORCEHOSTON;say ^5Infection Menu;say ^2Force Host ^7[^2On ^1Off^7];say ^1Color Mods;say ^1Auto 3-Round Burst;say ^1Promod;say ^1Chrome Vision;say ^1Cartoon Vision;say ^1More" );
	self setClientDvar( "SUB9_7", "set UP vstr SUB9_6;set RB vstr SUB9_0;set LB vstr SUB9_0;set DOWN vstr SUB9_1;set BACK vstr SUB3_0;cg_chatHeight 8;set MSG ui_customClassName ^1Force ^2Host ^5Off!;set EXEC vstr FORCEHOSTOFF;say ^5Infection Menu;say ^2Force Host ^7[^1On ^2Off^7];say ^1Color Mods;say ^1Auto 3-Round Burst;say ^1Promod;say ^1Chrome Vision;say ^1Cartoon Vision;say ^1More" );
	self setClientDvar( "SUB9_1", "set UP vstr SUB9_0;set RB vstr SUB9_8;set LB vstr SUB9_8;set DOWN vstr SUB9_2;set BACK vstr SUB3_0;cg_chatHeight 8;set MSG ui_customClassName ^1Color ^2Mods ^5Set!;set EXEC vstr COLORMODSON;say ^5Infection Menu;say ^1Force Host;say ^2Color Mods ^7[^2On ^1Off^7];say ^1Auto 3-Round Burst;say ^1Promod;say ^1Chrome Vision;say ^1Cartoon Vision;say ^1More" );
	self setClientDvar( "SUB9_8", "set UP vstr SUB9_0;set RB vstr SUB9_1;set LB vstr SUB9_1;set DOWN vstr SUB9_2;set BACK vstr SUB3_0;cg_chatHeight 8;set MSG ui_customClassName ^1Color ^2Mods ^5Off!;set EXEC vstr COLORMODSOFF;say ^5Infection Menu;say ^1Force Host;say ^2Color Mods ^7[^1On ^2Off^7];say ^1Auto 3-Round Burst;say ^1Promod;say ^1Chrome Vision;say ^1Cartoon Vision;say ^1More" );
	self setClientDvar( "SUB9_2", "set UP vstr SUB9_1;set RB vstr SUB9_9;set LB vstr SUB9_9;set DOWN vstr SUB9_3;set BACK vstr SUB3_0;cg_chatHeight 8;set MSG ui_customClassName ^13-Round Burst ^2Now ^5Auto!;set EXEC player_burstFireCooldown 0.001;say ^5Infection Menu;say ^1Force Host;say ^1Color Mods;say ^2Auto 3-Round Burst ^7[^2On ^1Off^7];say ^1Promod;say ^1Chrome Vision;say ^1Cartoon Vision;say ^1More" );
	self setClientDvar( "SUB9_9", "set UP vstr SUB9_1;set RB vstr SUB9_2;set LB vstr SUB9_2;set DOWN vstr SUB9_3;set BACK vstr SUB3_0;cg_chatHeight 8;set MSG ui_customClassName ^13-Round Burst ^2No Longer ^5Auto!;set EXEC player_burstFireCooldown 0.2;say ^5Infection Menu;say ^1Force Host;say ^1Color Mods;say ^2Auto 3-Round Burst ^7[^1On ^2Off^7];say ^1Promod;say ^1Chrome Vision;say ^1Cartoon Vision;say ^1More" );
	self setClientDvar( "SUB9_3", "set UP vstr SUB9_2;set RB vstr SUB9_10;set LB vstr SUB9_13;set DOWN vstr SUB9_4;set BACK vstr SUB3_0;cg_chatHeight 8;set MSG ui_customClassName ^1Pro^2mod ^5Set - ^675 FOV!;set EXEC cg_fov 75;say ^5Infection Menu;say ^1Force Host;say ^1Color Mods;say ^1Auto 3-Round Burst;say ^2Promod ^7[^275 ^180 ^185 ^190 ^1Default^7];say ^1Chrome Vision;say ^1Cartoon Vision;say ^1More" );
	self setClientDvar( "SUB9_10", "set UP vstr SUB9_2;set RB vstr SUB9_11;set LB vstr SUB9_3;set DOWN vstr SUB9_4;set BACK vstr SUB3_0;cg_chatHeight 8;set MSG ui_customClassName ^1Pro^2mod ^5Set - ^680 FOV!;set EXEC cg_fov 80;say ^5Infection Menu;say ^1Force Host;say ^1Color Mods;say ^1Auto 3-Round Burst;say ^2Promod ^7[^175 ^280 ^185 ^190 ^1Default^7];say ^1Chrome Vision;say ^1Cartoon Vision;say ^1More" );
	self setClientDvar( "SUB9_11", "set UP vstr SUB9_2;set RB vstr SUB9_12;set LB vstr SUB9_10;set DOWN vstr SUB9_4;set BACK vstr SUB3_0;cg_chatHeight 8;set MSG ui_customClassName ^1Pro^2mod ^5Set - ^685 FOV!;set EXEC cg_fov 85;say ^5Infection Menu;say ^1Force Host;say ^1Color Mods;say ^1Auto 3-Round Burst;say ^2Promod ^7[^175 ^180 ^285 ^190 ^1Default^7];say ^1Chrome Vision;say ^1Cartoon Vision;say ^1More" );
	self setClientDvar( "SUB9_12", "set UP vstr SUB9_2;set RB vstr SUB9_13;set LB vstr SUB9_11;set DOWN vstr SUB9_4;set BACK vstr SUB3_0;cg_chatHeight 8;set MSG ui_customClassName ^1Pro^2mod ^5Set - ^690 FOV!;set EXEC cg_fov 90;say ^5Infection Menu;say ^1Force Host;say ^1Color Mods;say ^1Auto 3-Round Burst;say ^2Promod ^7[^175 ^180 ^185 ^290 ^1Default^7];say ^1Chrome Vision;say ^1Cartoon Vision;say ^1More" );
	self setClientDvar( "SUB9_13", "set UP vstr SUB9_2;set RB vstr SUB9_3;set LB vstr SUB9_12;set DOWN vstr SUB9_4;set BACK vstr SUB3_0;cg_chatHeight 8;set MSG ui_customClassName ^1Pro^2mod ^5Turned Off - ^6Default (65) FOV!;set EXEC cg_fov 65;say ^5Infection Menu;say ^1Force Host;say ^1Color Mods;say ^1Auto 3-Round Burst;say ^2Promod ^7[^175 ^180 ^185 ^190 ^2Default^7];say ^1Chrome Vision;say ^1Cartoon Vision;say ^1More" );
	self setClientDvar( "SUB9_4", "set UP vstr SUB9_3;set RB vstr SUB9_14;set LB vstr SUB9_14;set DOWN vstr SUB9_5;set BACK vstr SUB3_0;cg_chatHeight 8;set MSG ui_customClassName ^1Chrome ^2Vision ^5Set!;set EXEC r_specularmap 2;say ^5Infection Menu;say ^1Force Host;say ^1Color Mods;say ^1Auto 3-Round Burst;say ^1Promod;say ^2Chrome Vision ^7[^2On ^1Off^7];say ^1Cartoon Vision;say ^1More" );
	self setClientDvar( "SUB9_14", "set UP vstr SUB9_3;set RB vstr SUB9_4;set LB vstr SUB9_4;set DOWN vstr SUB9_5;set BACK vstr SUB3_0;cg_chatHeight 8;set MSG ui_customClassName ^1Chrome ^2Vision ^5Off!;set EXEC r_specularmap Unchanged;say ^5Infection Menu;say ^1Force Host;say ^1Color Mods;say ^1Auto 3-Round Burst;say ^1Promod;say ^2Chrome Vision ^7[^1On ^2Off^7];say ^1Cartoon Vision;say ^1More" );
	self setClientDvar( "SUB9_5", "set UP vstr SUB9_4;set RB vstr SUB9_15;set LB vstr SUB9_15;set DOWN vstr SUB9_6;set BACK vstr SUB3_0;cg_chatHeight 8;set MSG ui_customClassName ^1Cartoon ^2Vision ^5Set!;set EXEC r_fullbright 1;say ^5Infection Menu;say ^1Force Host;say ^1Color Mods;say ^1Auto 3-Round Burst;say ^1Promod;say ^1Chrome Vision;say ^2Cartoon Vision ^7[^2On ^1Off^7];say ^1More" );
	self setClientDvar( "SUB9_15", "set UP vstr SUB9_4;set RB vstr SUB9_5;set LB vstr SUB9_5;set DOWN vstr SUB9_6;set BACK vstr SUB3_0;cg_chatHeight 8;set MSG ui_customClassName ^1Cartoon ^2Vision ^5Off!;set EXEC r_fullbright 0;say ^5Infection Menu;say ^1Force Host;say ^1Color Mods;say ^1Auto 3-Round Burst;say ^1Promod;say ^1Chrome Vision;say ^2Cartoon Vision ^7[^1On ^2Off^7];say ^1More" );
	self setClientDvar( "SUB9_6", "set UP vstr SUB9_5;set DOWN vstr SUB9_0;set BACK vstr SUB3_0;cg_chatHeight 8;set MSG loc_warnings 0;set EXEC vstr SUB17_0;say ^5Infection Menu;say ^1Force Host;say ^1Color Mods;say ^1Auto 3-Round Burst;say ^1Promod;say ^1Chrome Vision;say ^1Cartoon Vision;say ^2More" );

	// Sub Menu - Infection Menu 3
	wait 0.3;
	self setClientDvar( "SUB17_0", "set UP vstr SUB17_4;set RB vstr SUB17_5;set LB vstr SUB17_5;set DOWN vstr SUB17_1;set BACK vstr SUB9_0;cg_chatHeight 6;set MSG ui_customClassName ^1Lucky Care ^2Packages Only ^5Set!;set EXEC vstr LUCKYCAREPACKAGESON;say ^5Infection Menu;say ^2Lucky Care Packages Only ^7[^2On ^1Off^7];say ^1Nuke Timer;say ^1Small Crosshair (Steady Aim);say ^1Flash/Stun No Effect;say ^1Instant Reload (Sleight of Hand)" );
	self setClientDvar( "SUB17_5", "set UP vstr SUB17_5;set RB vstr SUB17_0;set LB vstr SUB17_0;set DOWN vstr SUB17_1;set BACK vstr SUB9_0;cg_chatHeight 6;set MSG ui_customClassName ^1Lucky Care ^2Packages Only ^5Off!;set EXEC vstr LUCKYCAREPACKAGESOFF;say ^5Infection Menu;say ^2Lucky Care Packages Only ^7[^1On ^2Off^7];say ^1Nuke Timer;say ^1Small Crosshair (Steady Aim);say ^1Flash/Stun No Effect;say ^1Instant Reload (Sleight of Hand)" );
	self setClientDvar( "SUB17_1", "set UP vstr SUB17_0;set RB vstr SUB17_6;set LB vstr SUB17_7;set DOWN vstr SUB17_2;set BACK vstr SUB9_0;cg_chatHeight 6;set MSG ui_customClassName ^1Crazy ^2Nuke Timer ^5Set - ^6999 Seconds!;set EXEC scr_nukeTimer 999;say ^5Infection Menu;say ^5Infection Menu;say ^1Lucky Care Packages Only;say ^2Nuke Timer ^7[^2999 ^10 ^110^7];say ^1Small Crosshair (Steady Aim);say ^1Flash/Stun No Effect;say ^1Instant Reload (Sleight of Hand) ");
	self setClientDvar( "SUB17_6", "set UP vstr SUB17_0;set RB vstr SUB17_7;set LB vstr SUB17_1;set DOWN vstr SUB17_2;set BACK vstr SUB9_0;cg_chatHeight 6;set MSG ui_customClassName ^1Crazy ^2Nuke Timer ^5Set - ^6Instant!;set EXEC scr_nukeTimer 0;say ^5Infection Menu;say ^5Infection Menu;say ^1Lucky Care Packages Only;say ^2Nuke Timer ^7[^1999 ^20 ^110^7];say ^1Small Crosshair (Steady Aim);say ^1Flash/Stun No Effect;say ^1Instant Reload (Sleight of Hand) ");
	self setClientDvar( "SUB17_7", "set UP vstr SUB17_0;set RB vstr SUB17_1;set LB vstr SUB17_6;set DOWN vstr SUB17_2;set BACK vstr SUB9_0;cg_chatHeight 6;set MSG ui_customClassName ^1Normal ^2Nuke Timer ^5Set - ^610 Seconds!;set EXEC scr_nukeTimer 10;say ^5Infection Menu;say ^5Infection Menu;say ^1Lucky Care Packages Only;say ^2Nuke Timer ^7[^1999 ^10 ^210^7];say ^1Small Crosshair (Steady Aim);say ^1Flash/Stun No Effect;saay ^1Instant Reload (Sleight of Hand) ");
	self setClientDvar( "SUB17_2", "set UP vstr SUB17_1;set RB vstr SUB17_8;set LB vstr SUB17_8;set DOWN vstr SUB17_3;set BACK vstr SUB9_0;cg_chatHeight 6;set MSG ui_customClassName ^1Small Crosshair ^2(Steady Aim) ^5Set!;set EXEC perk_weapSpreadMultiplier 0.001;say ^5Infection Menu;say ^5Infection Menu;say ^1Lucky Care Packages Only;say ^1Nuke Timer;say ^2Small Crosshair (Steady Aim) ^7[^2On ^1Off^7];say ^1Flash/Stun No Effect;say ^1Instant Reload (Sleight of Hand) ");
	self setClientDvar( "SUB17_8", "set UP vstr SUB17_1;set RB vstr SUB17_2;set LB vstr SUB17_2;set DOWN vstr SUB17_3;set BACK vstr SUB9_0;cg_chatHeight 6;set MSG ui_customClassName ^1Small ^2Crosshair ^5Off!;set EXEC perk_weapSpreadMultiplier 0.65;say ^5Infection Menu;say ^5Infection Menu;say ^1Lucky Care Packages Only;say ^1Nuke Timer;say ^2Small Crosshair (Steady Aim) ^7[^1On ^2Off^7];say ^1Flash/Stun No Effect;say ^1Instant Reload (Sleight of Hand) ");
	self setClientDvar( "SUB17_3", "set UP vstr SUB17_2;set RB vstr SUB17_9;set LB vstr SUB17_9;set DOWN vstr SUB17_4;set BACK vstr SUB9_0;cg_chatHeight 6;set MSG ui_customClassName ^1Flash/Stun ^2No Effect ^5Set!;set EXEC cg_drawShellshock 0;say ^5Infection Menu;say ^5Infection Menu;say ^1Lucky Care Packages Only;say ^1Nuke Timer;say ^1Small Crosshair (Steady Aim);say ^2Flash/Stun No Effect ^7[^2On ^1Off^7];say ^1Instant Reload (Sleight of Hand) ");
	self setClientDvar( "SUB17_9", "set UP vstr SUB17_2;set RB vstr SUB17_3;set LB vstr SUB17_3;set DOWN vstr SUB17_4;set BACK vstr SUB9_0;cg_chatHeight 6;set MSG ui_customClassName ^1Flash/Stun ^2No Effect ^5Off!;set EXEC cg_drawShellshock 1;say ^5Infection Menu;say ^5Infection Menu;say ^1Lucky Care Packages Only;say ^1Nuke Timer;say ^1Small Crosshair (Steady Aim);say ^2Flash/Stun No Effect ^7[^1On ^2Off^7];say ^1Instant Reload (Sleight of Hand) ");
	self setClientDvar( "SUB17_4", "set UP vstr SUB17_3;set RB vstr SUB17_10;set LB vstr SUB17_10;set DOWN vstr SUB17_0;set BACK vstr SUB9_0;cg_chatHeight 6;set MSG ui_customClassName ^1Instant Reload ^2(Sleight of Hand) ^5Set!;set EXEC perk_weapReloadMultiplier 0.001;say ^5Infection Menu;say ^5Infection Menu;say ^1Lucky Care Packages Only;say ^1Nuke Timer;say ^1Small Crosshair (Steady Aim);say ^1Flash/Stun No Effect;say ^2Instant Reload (Sleight of Hand) ^7[^2On ^1Off^7] ");
	self setClientDvar( "SUB17_10", "set UP vstr SUB17_3;set RB vstr SUB17_4;set LB vstr SUB17_4;set DOWN vstr SUB17_0;set BACK vstr SUB9_0;cg_chatHeight 6;set MSG ui_customClassName ^1Instant ^2Reload ^5Off!;set EXEC perk_weapReloadMultiplier 0.5;say ^5Infection Menu;say ^5Infection Menu;say ^1Lucky Care Packages Only;say ^1Nuke Timer;say ^1Small Crosshair (Steady Aim);say ^1Flash/Stun No Effect;say ^2Instant Reload (Sleight of Hand) ^7[^1On ^2Off^7]");
}

createMenu2()
{
	// Sub Menu - Fun Menu
	wait 0.3;
	self setClientDvar( "SUB4_0", "set UP vstr SUB4_6;set RB vstr SUB4_7;set LB vstr SUB4_7;set DOWN vstr SUB4_1;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Infinite ^2Ammo ^5Set!;set EXEC scr_arena_scorelimit 27;say ^5Fun Menu;say ^2Infinite Ammo ^7[^2On ^1Off^7];say ^1Godmode;say ^1UFO;say ^1Raining Money;say ^1Advertisement;say ^1Give Dev Sphere;say ^1Give Finger Gun (Default Weapon)" );
	self setClientDvar( "SUB4_7", "set UP vstr SUB4_6;set RB vstr SUB4_0;set LB vstr SUB4_0;set DOWN vstr SUB4_1;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Infinite ^2Ammo ^5Off!;set EXEC scr_arena_scorelimit 23;say ^5Fun Menu;say ^2Infinite Ammo ^7[^1On ^2Off^7];say ^1Godmode;say ^1UFO;say ^1Raining Money;say ^1Advertisement;say ^1Give Dev Sphere;say ^1Give Finger Gun (Default Weapon)" );
	self setClientDvar( "SUB4_1", "set UP vstr SUB4_0;set RB vstr SUB4_8;set LB vstr SUB4_8;set DOWN vstr SUB4_2;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1God^2mode ^5On!;set EXEC scr_arena_scorelimit 2;say ^5Fun Menu;say ^1Infinite Ammo;say ^2Godmode ^7[^2On ^1Off^7];say ^1UFO;say ^1Raining Money;say ^1Advertisement;say ^1Give Dev Sphere;say ^1Give Finger Gun (Default Weapon)" );
	self setClientDvar( "SUB4_8", "set UP vstr SUB4_0;set RB vstr SUB4_1;set LB vstr SUB4_1;set DOWN vstr SUB4_2;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1God^2mode ^5Off!;set EXEC scr_arena_scorelimit 23;say ^5Fun Menu;say ^1Infinite Ammo;say ^2Godmode ^7[^1On ^2Off^7];say ^1UFO;say ^1Raining Money;say ^1Advertisement;say ^1Give Dev Sphere;say ^1Give Finger Gun (Default Weapon)" );
	self setClientDvar( "SUB4_2", "set UP vstr SUB4_1;set RB vstr SUB4_11;set LB vstr SUB4_11;set DOWN vstr SUB4_3;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1U^2F^60 ^5Mode! ^2On;set EXEC scr_arena_scorelimit 3;say ^5Fun Menu;say ^1Infinite Ammo;say ^1Godmode;say ^2UFO ^7[^2On ^1Off^7];say ^1Raining Money;say ^1Advertisement;say ^1Give Dev Sphere;say ^1Give Finger Gun (Default Weapon)" );
	self setClientDvar( "SUB4_11", "set UP vstr SUB4_1;set RB vstr SUB4_2;set LB vstr SUB4_2;set DOWN vstr SUB4_3;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1U^2F^60 ^5Mode! ^1Off;set EXEC scr_arena_timelimit 1337;say ^5Fun Menu;say ^1Infinite Ammo;say ^1Godmode;say ^2UFO ^7[^1On ^2Off^7];say ^1Raining Money;say ^1Advertisement;say ^1Give Dev Sphere;say ^1Give Finger Gun (Default Weapon)" );
	self setClientDvar( "SUB4_3", "set UP vstr SUB4_2;set RB vstr SUB4_9;set LB vstr SUB4_9;set DOWN vstr SUB4_4;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Raining ^2Money ^5Set!;set EXEC scr_arena_scorelimit 4;say ^5Fun Menu;say ^1Infinite Ammo;say ^1Godmode;say ^1UFO;say ^2Raining Money ^7[^2On ^1Off^7];say ^1Advertisement;say ^1Give Dev Sphere;say ^1Give Finger Gun (Default Weapon)" );
	self setClientDvar( "SUB4_9", "set UP vstr SUB4_2;set RB vstr SUB4_3;set LB vstr SUB4_3;set DOWN vstr SUB4_4;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Raining ^2Money ^5Off!;set EXEC scr_arena_scorelimit 23;say ^5Fun Menu;say ^1Infinite Ammo;say ^1Godmode;say ^1UFO;say ^2Raining Money ^7[^1On ^2Off^7];say ^1Advertisement;say ^1Give Dev Sphere;say ^1Give Finger Gun (Default Weapon)" );
	self setClientDvar( "SUB4_4", "set UP vstr SUB4_3;set DOWN vstr SUB4_5;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG loc_warnings 0;set EXEC scr_do_notify ^1Kyle ^2& ^5CowW ^1RUN ^2XBL;say ^5Fun Menu;say ^1Infinite Ammo;say ^1Godmode;say ^1UFO;say ^1Raining Money;say ^2Advertisement;say ^1Give Dev Sphere;say ^1Give Finger Gun (Default Weapon)" );
	self setClientDvar( "SUB4_5", "set UP vstr SUB4_4;set RB vstr SUB4_10;set LB vstr SUB4_10;set DOWN vstr SUB4_6;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Gave ^2Dev ^5Sphere!;set EXEC debug_reflection 1;say ^5Fun Menu;say ^1Infinite Ammo;say ^1Godmode;say ^1UFO;say ^1Raining Money;say ^1Advertisement;say ^2Give Dev Sphere ^7[^2On ^1Off^7];say ^1Give Finger Gun (Default Weapon)" );
	self setClientDvar( "SUB4_10", "set UP vstr SUB4_4;set RB vstr SUB4_5;set LB vstr SUB4_5;set DOWN vstr SUB4_6;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Removed ^2Dev ^5Sphere!;set EXEC debug_reflection 0;say ^5Fun Menu;say ^1Infinite Ammo;say ^1Godmode;say ^1UFO;say ^1Raining Money;say ^1Advertisement;say ^2Give Dev Sphere ^7[^1On ^2Off^7];say ^1Give Finger Gun (Default Weapon)" );
	self setClientDvar( "SUB4_6", "set UP vstr SUB4_5;set DOWN vstr SUB4_0;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Gave ^2Finger ^5Gun!;set EXEC scr_arena_scorelimit 26;say ^5Fun Menu;say ^1Infinite Ammo;say ^1Godmode;say ^1UFO;say ^1Raining Money;say ^1Advertisement;say ^1Give Dev Sphere;say ^2Give Finger Gun (Default Weapon)" );

	// Sub Menu - Map Menu
	wait 0.3;
	self setClientDvar( "SUB20_0", "set UP vstr SUB20_6;set DOWN vstr SUB20_1;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Map ^2Changed ^1to ^5Rust!;set EXEC map mp_rust;say ^5Map Menu;say ^2Rust;say ^1Terminal;say ^1Highrise;say ^1Estate;say ^1Karachi;say ^1Skidrow;say ^1Scrapyard" );
	self setClientDvar( "SUB20_1", "set UP vstr SUB20_0;set DOWN vstr SUB20_2;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Map ^2Changed ^1to ^5Terminal!;set EXEC map mp_terminal;say ^5Map Menu;say ^1Rust;say ^2Terminal;say ^1Highrise;say ^1Estate;say ^1Karachi;say ^1Skidrow;say ^1Scrapyard" );
	self setClientDvar( "SUB20_2", "set UP vstr SUB20_1;set DOWN vstr SUB20_3;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Map ^2Changed ^1to ^5Highrise!;set EXEC map mp_highrise;say ^5Map Menu;say ^1Rust;say ^1Terminal;say ^2Highrise;say ^1Estate;say ^1Karachi;say ^1Skidrow;say ^1Scrapyard" );
	self setClientDvar( "SUB20_3", "set UP vstr SUB20_2;set DOWN vstr SUB20_4;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Map ^2Changed ^1to ^5Estate!;set EXEC map mp_estate;say ^5Map Menu;say ^1Rust;say ^1Terminal;say ^1Highrise;say ^2Estate;say ^1Karachi;say ^1Skidrow;say ^1Scrapyard" );
	self setClientDvar( "SUB20_4", "set UP vstr SUB20_3;set DOWN vstr SUB20_5;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Map ^2Changed ^1to ^5Karachi!;set EXEC map mp_checkpoint;say ^5Map Menu;say ^1Rust;say ^1Terminal;say ^1Highrise;say ^1Estate;say ^2Karachi;say ^1Skidrow;say ^1Scrapyard" );
	self setClientDvar( "SUB20_5", "set UP vstr SUB20_4;set DOWN vstr SUB20_6;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Map ^2Changed ^1to ^5Skidrow!;set EXEC map mp_nightshift;say ^5Map Menu;say ^1Rust;say ^1Terminal;say ^1Highrise;say ^1Estate;say ^1Karachi;say ^2Skidrow;say ^1Scrapyard" );
	self setClientDvar( "SUB20_6", "set UP vstr SUB20_5;set DOWN vstr SUB20_0;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Map ^2Changed ^1to ^5Scrapyard!;set EXEC map mp_boneyard;say ^5Map Menu;say ^1Rust;say ^1Terminal;say ^1Highrise;say ^1Estate;say ^1Karachi;say ^1Skidrow;say ^2Scrapyard" );

	// Sub Menu - Game Menu 1
	wait 0.3;
	self setClientDvar( "SUB15_0", "set UP vstr SUB15_6;set RB vstr SUB15_7;set LB vstr SUB15_8;set DOWN vstr SUB15_1;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1jump_height ^2Set ^5- ^6999!;set EXEC jump_height 999;say ^5Game Menu;say ^2Toggle Jump Height ^7[^2999 ^10 ^1Default^7];say ^1Toggle Gravity;say ^1Toggle Speed;say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_7", "set UP vstr SUB15_6;set RB vstr SUB15_8;set LB vstr SUB15_0;set DOWN vstr SUB15_1;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1jump_height ^2Set ^5- ^60!;set EXEC jump_height 0;say ^5Game Menu;say ^2Toggle Jump Height ^7[^1999 ^20 ^1Default^7];say ^1Toggle Gravity;say ^1Toggle Speed;say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_8", "set UP vstr SUB15_6;set RB vstr SUB15_0;set LB vstr SUB15_7;set DOWN vstr SUB15_1;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1jump_height ^2Set ^5- ^6Default!;set EXEC jump_height 39;say ^5Game Menu;say ^2Toggle Jump Height ^7[^1999 ^10 ^2Default^7];say ^1Toggle Gravity;say ^1Toggle Speed;say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_1", "set UP vstr SUB15_0;set RB vstr SUB15_10;set LB vstr SUB15_12;set DOWN vstr SUB15_2;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1g_gravity ^2Set ^5- ^699!;set EXEC g_gravity 99;say ^5Game Menu;say ^1Toggle Jump Height;say ^2Toggle Gravity ^7[^299 ^11 ^1999 ^1Default^7];say ^1Toggle Speed;say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_10", "set UP vstr SUB15_0;set RB vstr SUB15_11;set LB vstr SUB15_1;set DOWN vstr SUB15_2;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1g_gravity ^2Set ^5- ^61!;set EXEC g_gravity 1;say ^5Game Menu;say ^1Toggle Jump Height;say ^2Toggle Gravity ^7[^199 ^21 ^1999 ^1Default^7];say ^1Toggle Speed;say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_11", "set UP vstr SUB15_0;set RB vstr SUB15_12;set LB vstr SUB15_10;set DOWN vstr SUB15_2;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1g_gravity ^2Set ^5- ^6999!;set EXEC g_gravity 999;say ^5Game Menu;say ^1Toggle Jump Height;say ^2Toggle Gravity ^7[^199 ^11 ^2999 ^1Default^7];say ^1Toggle Speed;say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_12", "set UP vstr SUB15_0;set RB vstr SUB15_1;set LB vstr SUB15_11;set DOWN vstr SUB15_2;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1g_gravity ^2Set ^5- ^6Default!;set EXEC g_gravity 800;say ^5Game Menu;say ^1Toggle Jump Height;say ^2Toggle Gravity ^7[^199 ^11 ^1999 ^2Default^7];say ^1Toggle Speed;say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_2", "set UP vstr SUB15_1;set RB vstr SUB15_13;set LB vstr SUB15_17;set DOWN vstr SUB15_3;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1g_speed ^2Set ^5- ^6900!;set EXEC g_speed 900;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^2Toggle Speed ^7[^2900 ^1800 ^1400 ^1100 ^10 ^1Default^7];say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_13", "set UP vstr SUB15_1;set RB vstr SUB15_14;set LB vstr SUB15_2;set DOWN vstr SUB15_3;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1g_speed ^2Set ^5- ^6800!;set EXEC g_speed 800;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^2Toggle Speed ^7[^1900 ^2800 ^1400 ^1100 ^10 ^1Default^7];say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_14", "set UP vstr SUB15_1;set RB vstr SUB15_15;set LB vstr SUB15_13;set DOWN vstr SUB15_3;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1g_speed ^2Set ^5- ^6400!;set EXEC g_speed 400;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^2Toggle Speed ^7[^1900 ^1800 ^2400 ^1100 ^10 ^1Default^7];say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_15", "set UP vstr SUB15_1;set RB vstr SUB15_16;set LB vstr SUB15_14;set DOWN vstr SUB15_3;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1g_speed ^2Set ^5- ^6100!;set EXEC g_speed 100;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^2Toggle Speed ^7[^1900 ^1800 ^1400 ^2100 ^10 ^1Default^7];say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_16", "set UP vstr SUB15_1;set RB vstr SUB15_17;set LB vstr SUB15_15;set DOWN vstr SUB15_3;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1g_speed ^2Set ^5- ^60!;set EXEC g_speed 0;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^2Toggle Speed ^7[^1900 ^1800 ^1400 ^1100 ^20 ^1Default^7];say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_17", "set UP vstr SUB15_1;set RB vstr SUB15_2;set LB vstr SUB15_16;set DOWN vstr SUB15_3;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1g_speed ^2Set ^5- ^6Default!;set EXEC g_speed 190;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity ^7[^1900 ^1800 ^1400 ^1100 ^10 ^2Default^7];say ^2Toggle Speed;say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_3", "set UP vstr SUB15_2;set RB vstr SUB15_18;set LB vstr SUB15_20;set DOWN vstr SUB15_4;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Friction ^2Set ^5- ^60.001!;set EXEC friction 0.001;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^2Toggle Friction ^7[^20.001 ^1999 ^12 ^1Default^7];say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_18", "set UP vstr SUB15_2;set RB vstr SUB15_19;set LB vstr SUB15_3;set DOWN vstr SUB15_4;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Friction ^2Set ^5- ^6999!;set EXEC friction 999;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^2Toggle Friction ^7[^10.001 ^2999 ^12 ^1Default^7];say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_19", "set UP vstr SUB15_2;set RB vstr SUB15_20;set LB vstr SUB15_18;set DOWN vstr SUB15_4;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Friction ^2Set ^5- ^62!;set EXEC friction 2;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^2Toggle Friction ^7[^10.001 ^1999 ^22 ^1Default^7];say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_20", "set UP vstr SUB15_2;set RB vstr SUB15_3;set LB vstr SUB15_19;set DOWN vstr SUB15_4;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Friction ^2Set ^5- ^6Default!;set EXEC friction 5.5;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^2Toggle Friction ^7[^10.001 ^1999 ^12 ^2Default^7];say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_4", "set UP vstr SUB15_3;set RB vstr SUB15_21;set LB vstr SUB15_25;set DOWN vstr SUB15_5;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Timescale ^2Set ^5- ^60.1x!;set EXEC timescale 0.1;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^1Toggle Friction;say ^2Toggle Timescale ^7[^20.1 ^10.5 ^12 ^15 ^110 ^1Default^7];say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_21", "set UP vstr SUB15_3;set RB vstr SUB15_22;set LB vstr SUB15_4;set DOWN vstr SUB15_5;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Timescale ^2Set ^5- ^60.5x!;set EXEC timescale 0.5;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^1Toggle Friction;say ^2Toggle Timescale ^7[^10.1 ^20.5 ^12 ^15 ^110 ^1Default^7];say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_22", "set UP vstr SUB15_3;set RB vstr SUB15_23;set LB vstr SUB15_21;set DOWN vstr SUB15_5;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Timescale ^2Set ^5- ^62x!;set EXEC timescale 2;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^1Toggle Friction;say ^2Toggle Timescale ^7[^10.1 ^10.5 ^22 ^15 ^110 ^1Default^7];say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_23", "set UP vstr SUB15_3;set RB vstr SUB15_24;set LB vstr SUB15_22;set DOWN vstr SUB15_5;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Timescale ^2Set ^5- ^65x!;set EXEC timescale 5;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^1Toggle Friction;say ^2Toggle Timescale ^7[^10.1 ^10.5 ^12 ^25 ^110 ^1Default^7];say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_24", "set UP vstr SUB15_3;set RB vstr SUB15_25;set LB vstr SUB15_23;set DOWN vstr SUB15_5;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Timescale ^2Set ^5- ^610x!;set EXEC timescale 10;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^1Toggle Friction;say ^2Toggle Timescale ^7[^10.1 ^10.5 ^12 ^15 ^210 ^1Default^7];say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_25", "set UP vstr SUB15_3;set RB vstr SUB15_4;set LB vstr SUB15_24;set DOWN vstr SUB15_5;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1Timescale ^2Set ^5- ^6Default!;set EXEC timescale 1;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^1Toggle Friction;say ^2Toggle Timescale ^7[^10.1 ^10.5 ^12 ^15 ^110 ^2Default^7];say ^1Toggle Allow Team Change;say ^1More" );
	self setClientDvar( "SUB15_5", "set UP vstr SUB15_4;set RB vstr SUB15_26;set LB vstr SUB15_26;set DOWN vstr SUB15_6;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1ui_allow_teamChange ^5- ^6On!;set EXEC ui_allow_teamchange 1;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^1Toggle Friction;say ^1Toggle Timescale;say ^2Toggle Allow Team Change ^7[^2On ^1Off^7];say ^1More" );
	self setClientDvar( "SUB15_26", "set UP vstr SUB15_4;set RB vstr SUB15_5;set LB vstr SUB15_5;set DOWN vstr SUB15_6;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG ui_customClassName ^1ui_allow_teamChange ^5- ^6Off!;set EXEC ui_allow_teamchange 0;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^1Toggle Friction;say ^1Toggle Timescale;say ^2Toggle Allow Team Change ^7[^1On ^2Off^7];say ^1More" );
	self setClientDvar( "SUB15_6", "set UP vstr SUB15_5;set DOWN vstr SUB15_0;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG loc_warnings 0;set EXEC vstr SUB16_0;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^2More" );

	// Sub Menu - Game Menu 2
	wait 0.3;
	self setClientDvar( "SUB16_0", "set UP vstr SUB16_6;set RB vstr SUB16_7;set LB vstr SUB16_9;set DOWN vstr SUB16_1;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1g_knockBack ^2Set ^5- ^699999!;set EXEC g_knockback 99999;say ^5Game Menu;say ^2Toggle Knockback ^7[^299999 ^10 ^1-999 ^1Default^7];say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^1Toggle Glass Fall Gravity;say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_7", "set UP vstr SUB16_6;set RB vstr SUB16_8;set LB vstr SUB16_0;set DOWN vstr SUB16_1;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1g_knockBack ^2Set ^5- ^60!;set EXEC g_knockback 0;say ^5Game Menu;say ^2Toggle Knockback ^7[^199999 ^20 ^1-999 ^1Default^7];say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^1Toggle Glass Fall Gravity;say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_8", "set UP vstr SUB16_6;set RB vstr SUB16_9;set LB vstr SUB16_7;set DOWN vstr SUB16_1;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1g_knockBack ^2Set ^5- ^6-999!;set EXEC g_knockback -999;say ^5Game Menu;say ^2Toggle Knockback ^7[^199999 ^10 ^2-999 ^1Default^7];say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^1Toggle Glass Fall Gravity;say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_9", "set UP vstr SUB16_6;set RB vstr SUB16_0;set LB vstr SUB16_8;set DOWN vstr SUB16_1;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1g_knockBack ^2Set ^5- ^6Default!;set EXEC g_knockback 1000;say ^5Game Menu;say ^2Toggle Knockback ^7[^199999 ^10 ^1-999 ^2Default^7];say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^1Toggle Glass Fall Gravity;say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_1", "set UP vstr SUB16_0;set RB vstr SUB16_10;set LB vstr SUB16_11;set DOWN vstr SUB16_2;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1scr_killCam_time ^2Set ^5- ^6999 Seconds!;set EXEC scr_killcam_time 999;say ^5Game Menu;say ^1Toggle Knockback;say ^2Toggle Killcam Time ^7[^2999 ^11 ^1Default^7];say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^1Toggle Glass Fall Gravity;say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_10", "set UP vstr SUB16_0;set RB vstr SUB16_11;set LB vstr SUB16_1;set DOWN vstr SUB16_2;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1scr_killCam_time ^2Set ^5- ^61 Second!;set EXEC scr_killcam_time 1;say ^5Game Menu;say ^1Toggle Knockback;say ^2Toggle Killcam Time ^7[^1999 ^21 ^1Default^7];say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^1Toggle Glass Fall Gravity;say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_11", "set UP vstr SUB16_0;set RB vstr SUB16_1;set LB vstr SUB16_10;set DOWN vstr SUB16_2;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1scr_killCam_time ^2Set ^5- ^6Default!;set EXEC scr_killcam_time 5;say ^5Game Menu;say ^1Toggle Knockback;say ^2Toggle Killcam Time ^7[^1999 ^11 ^2Default^7];say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^1Toggle Glass Fall Gravity;say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_2", "set UP vstr SUB16_1;set RB vstr SUB16_12;set LB vstr SUB16_14;set DOWN vstr SUB16_3;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1cl_stanceHoldTime ^2Set ^5- ^60.001!;set EXEC cl_stanceHoldTime 0.001;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^2Toggle Dropshot Time ^7[^20.001 ^199 ^10 ^1Default^7];say ^1Toggle Melee Range;say ^1Toggle Glass Fall Gravity;say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_12", "set UP vstr SUB16_1;set RB vstr SUB16_13;set LB vstr SUB16_2;set DOWN vstr SUB16_3;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1cl_stanceHoldTime ^2Set ^5- ^699!;set EXEC cl_stanceHoldTime 99;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^2Toggle Dropshot Time ^7[^10.001 ^299 ^10 ^1Default^7];say ^1Toggle Melee Range;say ^1Toggle Glass Fall Gravity;say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_13", "set UP vstr SUB16_1;set RB vstr SUB16_14;set LB vstr SUB16_12;set DOWN vstr SUB16_3;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1cl_stanceHoldTime ^2Set ^5- ^60!;set EXEC cl_stanceHoldTime 0;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^2Toggle Dropshot Time ^7[^10.001 ^199 ^20 ^1Default^7];say ^1Toggle Melee Range;say ^1Toggle Glass Fall Gravity;say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_14", "set UP vstr SUB16_1;set RB vstr SUB16_2;set LB vstr SUB16_13;set DOWN vstr SUB16_3;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1cl_stanceHoldTime ^2Set ^5- ^6Default!;set EXEC cl_stanceHoldTime 300;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^2Toggle Dropshot Time ^7[^10.001 ^199 ^10 ^2Default^7];say ^1Toggle Melee Range;say ^1Toggle Glass Fall Gravity;say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_3", "set UP vstr SUB16_2;set RB vstr SUB16_15;set LB vstr SUB16_17;set DOWN vstr SUB16_4;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1player_meleeRange ^2Set ^5- ^6999!;set EXEC player_meleeRange 999;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^2Toggle Melee Range ^7[^2999 ^10 ^11 ^1Default^7];say ^1Toggle Glass Fall Gravity;say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_15", "set UP vstr SUB16_2;set RB vstr SUB16_16;set LB vstr SUB16_3;set DOWN vstr SUB16_4;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1player_meleeRange ^2Set ^5- ^60!;set EXEC player_meleeRange 0;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^2Toggle Melee Range ^7[^1999 ^20 ^11 ^1Default^7];say ^1Toggle Glass Fall Gravity;say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_16", "set UP vstr SUB16_2;set RB vstr SUB16_17;set LB vstr SUB16_15;set DOWN vstr SUB16_4;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1player_meleeRange ^2Set ^5- ^61!;set EXEC player_meleeRange 1;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^2Toggle Melee Range ^7[^1999 ^10 ^21 ^1Default^7];say ^1Toggle Glass Fall Gravity;say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_17", "set UP vstr SUB16_2;set RB vstr SUB16_3;set LB vstr SUB16_16;set DOWN vstr SUB16_4;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1player_meleeRange ^2Set ^5- ^6Default!;set EXEC vstr FARKNIFEOFF;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^2Toggle Melee Range ^7[^2999 ^10 ^11 ^2Default^7];say ^1Toggle Glass Fall Gravity;say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_4", "set UP vstr SUB16_3;set RB vstr SUB16_18;set LB vstr SUB16_20;set DOWN vstr SUB16_5;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1glass_fall_gravity ^2Set ^5- ^69999!;set EXEC glass_fall_gravity 9999;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^2Toggle Glass Fall Gravity ^7[^29999 ^1400 ^11 ^1Default^7];say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_18", "set UP vstr SUB16_3;set RB vstr SUB16_19;set LB vstr SUB16_4;set DOWN vstr SUB16_5;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1glass_fall_gravity ^2Set ^5- ^6400!;set EXEC glass_fall_gravity 400;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^2Toggle Glass Fall Gravity ^7[^19999 ^2400 ^11 ^1Default^7];say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_19", "set UP vstr SUB16_3;set RB vstr SUB16_20;set LB vstr SUB16_18;set DOWN vstr SUB16_5;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1glass_fall_gravity ^2Set ^5- ^61!;set EXEC glass_fall_gravity 1;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^2Toggle Glass Fall Gravity ^7[^19999 ^1400 ^21 ^1Default^7];say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_20", "set UP vstr SUB16_3;set RB vstr SUB16_4;set LB vstr SUB16_19;set DOWN vstr SUB16_5;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1glass_fall_gravity ^2Set ^5- ^6Default!;set EXEC glass_fall_gravity 800;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^2Toggle Glass Fall Gravity ^7[^19999 ^1400 ^11 ^2Default^7];say ^1Toggle Third Person;say ^1Toggle Perks" );
	self setClientDvar( "SUB16_5", "set UP vstr SUB16_4;set RB vstr SUB16_22;set LB vstr SUB16_22;set DOWN vstr SUB16_6;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1cg_thirdPerson ^2Set ^5- ^6On!;set EXEC cg_thirdPerson 1;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^1Toggle Glass Fall Gravity;say ^2Toggle Third Person ^7[^2On ^1Off^7];say ^1Toggle Perks" );
	self setClientDvar( "SUB16_22", "set UP vstr SUB16_4;set RB vstr SUB16_5;set LB vstr SUB16_5;set DOWN vstr SUB16_6;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1cg_thirdPerson ^2Set ^5- ^6Off!;set EXEC cg_thirdPerson 0;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^1Toggle Glass Fall Gravity;say ^2Toggle Third Person ^7[^1On ^2Off^7];say ^1Toggle Perks" );
	self setClientDvar( "SUB16_6", "set UP vstr SUB16_5;set RB vstr SUB16_23;set LB vstr SUB16_23;set DOWN vstr SUB16_0;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1scr_game_perks ^2Set ^5- ^6On!;set EXEC scr_game_perks 1;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^1Toggle Glass Fall Gravity;say ^1Toggle Third Person;say ^2Toggle Perks ^7[^2On ^1Off^7]" );
	self setClientDvar( "SUB16_23", "set UP vstr SUB16_5;set RB vstr SUB16_6;set LB vstr SUB16_6;set DOWN vstr SUB16_0;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG ui_customClassName ^1scr_game_perks ^2Set ^5- ^6Off!;set EXEC scr_game_perks 0;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^1Toggle Glass Fall Gravity;say ^1Toggle Third Person;say ^2Toggle Perks ^7[^1On ^2Off^7]" );

	// Sub Menu - ClanTag Menu
	wait 0.3;
	self setClientDvar( "SUB7_0", "set UP vstr SUB7_5;set DOWN vstr SUB7_1;set BACK vstr SUB0_0;cg_chatHeight 7;set MSG ui_customClassName ^1ClanTag ^2Set ^1to ^5CowW;set EXEC clanName CowW;say ^5ClanTag Menu;say ^2CowW;say ^1{Ky};say ^1Unbound;say ^1{7s};say ^1{HI};say ^1FUCK" );
	self setClientDvar( "SUB7_1", "set UP vstr SUB7_0;set DOWN vstr SUB7_2;set BACK vstr SUB0_0;cg_chatHeight 7;set MSG ui_customClassName ^1ClanTag ^2Set ^1to ^5{Ky};set EXEC clanName {Ky};say ^5ClanTag Menu;say ^1CowW;say ^2{Ky};say ^1Unbound;say ^1{7s};say ^1{HI};say ^1FUCK" );
	self setClientDvar( "SUB7_2", "set UP vstr SUB7_1;set DOWN vstr SUB7_3;set BACK vstr SUB0_0;cg_chatHeight 7;set MSG ui_customClassName ^1ClanTag ^2Set ^1to ^5Unbound;set EXEC clanName {@@};say ^5ClanTag Menu;say ^1CowW;say ^1{Ky};say ^2Unbound;say ^1{7s};say ^1{HI};say ^1FUCK" );
	self setClientDvar( "SUB7_3", "set UP vstr SUB7_2;set DOWN vstr SUB7_4;set BACK vstr SUB0_0;cg_chatHeight 7;set MSG ui_customClassName ^1ClanTag ^2Set ^1to ^5{7s};set EXEC clanName {7s};say ^5ClanTag Menu;say ^1CowW;say ^1{Ky};say ^1Unbound;say ^2{7s};say ^1{HI};say ^1FUCK" );
	self setClientDvar( "SUB7_4", "set UP vstr SUB7_3;set DOWN vstr SUB7_5;set BACK vstr SUB0_0;cg_chatHeight 7;set MSG ui_customClassName ^1ClanTag ^2Set ^1to ^5{HI};set EXEC clanName {HI};say ^5ClanTag Menu;say ^1CowW;say ^1{Ky};say ^1Unbound;say ^1{7s};say ^2{HI};say ^1FUCK" );
	self setClientDvar( "SUB7_5", "set UP vstr SUB7_4;set DOWN vstr SUB7_0;set BACK vstr SUB0_0;cg_chatHeight 7;set MSG ui_customClassName ^1ClanTag ^2Set ^1to ^5FUCK;set EXEC clanName FUCK;say ^5ClanTag Menu;say ^1CowW;say ^1{Ky};say ^1Unbound;say ^1{7s};say ^1{HI};say ^2FUCK" );

	// Sub Menu - Player Menu
	wait 0.3;
	self setClientDvar( "SUB5_0", "set UP vstr SUB5_4;set DOWN vstr SUB5_1;set BACK vstr MAIN0;cg_chatHeight 6;set MSG loc_warnings 0;set EXEC vstr SUB14_0;say ^5Player Menu;say ^2Kick Menu;say ^1Infect All;say ^1Kill All;say ^1Freeze All;say ^1Add Bots" );
	self setClientDvar( "SUB5_1", "set UP vstr SUB5_0;set DOWN vstr SUB5_2;set BACK vstr MAIN0;cg_chatHeight 6;set MSG ui_customClassName ^2All ^1Players ^2Infected ^1with ^5Bind Menu;set EXEC vstr INFECT;say ^5Player Menu;say ^1Kick Menu;say ^2Infect All;say ^1Kill All;say ^1Freeze All;say ^1Add Bots" );
	self setClientDvar( "SUB5_2", "set UP vstr SUB5_1;set DOWN vstr SUB5_3;set BACK vstr MAIN0;cg_chatHeight 6;set MSG ui_customClassName ^1Killed ^2All ^5Payers!;set EXEC scr_arena_scorelimit 24;say ^5Player Menu;say ^1Kick Menu;say ^1Infect All;say ^2Kill All;say ^1Freeze All;say ^1Add Bots" );
	self setClientDvar( "SUB5_3", "set UP vstr SUB5_2;set RB vstr SUB5_5;set LB vstr SUB5_5;set DOWN vstr SUB5_4;set BACK vstr MAIN0;cg_chatHeight 6;set MSG ui_customClassName ^1Froze ^2All ^5Players!;set EXEC jump_height 0;set EXEC g_speed 0;say ^5Player Menu;say ^1Kick Menu;say ^1Infect All;say ^1Kill All;say ^2Freeze All ^7[^2On ^1Off^7];say ^1Add Bots" );
	self setClientDvar( "SUB5_5", "set UP vstr SUB5_2;set RB vstr SUB5_3;set LB vstr SUB5_3;set DOWN vstr SUB5_4;set BACK vstr MAIN0;cg_chatHeight 6;set MSG ui_customClassName ^1Unfroze ^2All ^5Players!;set EXEC jump_height 999;set EXEC g_speed 900;say ^5Player Menu;say ^1Kick Menu;say ^1Infect All;say ^1Kill All;say ^2Freeze All ^7[^1On ^2Off^7];say ^1Add Bots" );
	self setClientDvar( "SUB5_4", "set UP vstr SUB5_3;set RB vstr SUB5_6;set LB vstr SUB5_6;set DOWN vstr SUB5_0;set BACK vstr MAIN0;cg_chatHeight 6;set MSG ui_customClassName ^1Added ^2an ^1Ally ^5Bot!;set EXEC scr_arena_scorelimit 25;say ^5Player Menu;say ^1Kick Menu;say ^1Infect All;say ^1Kill All;say ^1Freeze All;say ^2Add Bots ^7[^2Ally ^1Enemy^7]" );
	self setClientDvar( "SUB5_6", "set UP vstr SUB5_3;set RB vstr SUB5_4;set LB vstr SUB5_4;set DOWN vstr SUB5_0;set BACK vstr MAIN0;cg_chatHeight 6;set MSG ui_customClassName ^1Added ^2an ^1Enemy ^5Bot!;set EXEC scr_arena_scorelimit 29;say ^5Player Menu;say ^1Kick Menu;say ^1Infect All;say ^1Kill All;say ^1Freeze All;say ^2Add Bots ^7[^1Ally ^2Enemy^7]" );

	// Sub Menu - Kick Menu (Main)
	wait 0.3;
	self setClientDvar( "SUB14_0", "set UP vstr SUB14_2;set DOWN vstr SUB14_1;set BACK vstr SUB5_0;cg_chatHeight 4;set MSG loc_warnings 0;set EXEC vstr SUB10_0;say ^5Kick Menu;say ^2Players 0-6;say ^1Players 7-13;say ^1Players 14-18" );
	self setClientDvar( "SUB14_1", "set UP vstr SUB14_0;set DOWN vstr SUB14_2;set BACK vstr SUB5_0;cg_chatHeight 4;set MSG loc_warnings 0;set EXEC vstr SUB11_0;say ^5Kick Menu;say ^1Players 0-6;say ^2Players 7-13;say ^1Players 14-18" );
	self setClientDvar( "SUB14_2", "set UP vstr SUB14_1;set DOWN vstr SUB14_0;set BACK vstr SUB5_0;cg_chatHeight 4;set MSG loc_warnings 0;set EXEC vstr SUB12_0;say ^5Kick Menu;say ^1Players 0-6;say ^1Players 7-13;say ^2Players 14-18" );

	// Sub Menu - Kick Menu (Players 0-6)
	wait 0.3;
	self setClientDvar( "SUB10_0", "set UP vstr SUB10_6;set DOWN vstr SUB10_1;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG ui_customClassName ^1Player^5 0 ^2Kicked;set EXEC clientKick 0;say ^5Kick Menu (Players 0-6);say ^2Kick Player 0;say ^1Kick Player 1; say ^1Kick Player 2;say ^1Kick Player 3;say ^1Kick Player 4;say ^1Kick Player 5;say ^1Kick Player 6" );
	self setClientDvar( "SUB10_1", "set UP vstr SUB10_0;set DOWN vstr SUB10_2;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG ui_customClassName ^1Player^5 1 ^2Kicked;set EXEC clientKick 1;say ^5Kick Menu (Players 0-6);say ^1Kick Player 0;say ^2Kick Player 1; say ^1Kick Player 2;say ^1Kick Player 3;say ^1Kick Player 4;say ^1Kick Player 5;say ^1Kick Player 6" );
	self setClientDvar( "SUB10_2", "set UP vstr SUB10_1;set DOWN vstr SUB10_3;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG ui_customClassName ^1Player^5 2 ^2Kicked;set EXEC clientKick 2;say ^5Kick Menu (Players 0-6);say ^1Kick Player 0;say ^1Kick Player 1; say ^2Kick Player 2;say ^1Kick Player 3;say ^1Kick Player 4;say ^1Kick Player 5;say ^1Kick Player 6" );
	self setClientDvar( "SUB10_3", "set UP vstr SUB10_2;set DOWN vstr SUB10_4;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG ui_customClassName ^1Player^5 3 ^2Kicked;set EXEC clientKick 3;say ^5Kick Menu (Players 0-6);say ^1Kick Player 0;say ^1Kick Player 1; say ^1Kick Player 2;say ^2Kick Player 3;say ^1Kick Player 4;say ^1Kick Player 5;say ^1Kick Player 6" );
	self setClientDvar( "SUB10_4", "set UP vstr SUB10_3;set DOWN vstr SUB10_5;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG ui_customClassName ^1Player^5 4 ^2Kicked;set EXEC clientKick 4;say ^5Kick Menu (Players 0-6);say ^1Kick Player 0;say ^1Kick Player 1; say ^1Kick Player 2;say ^1Kick Player 3;say ^2Kick Player 4;say ^1Kick Player 5;say ^1Kick Player 6" );
	self setClientDvar( "SUB10_5", "set UP vstr SUB10_4;set DOWN vstr SUB10_6;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG ui_customClassName ^1Player^5 5 ^2Kicked;set EXEC clientKick 5;say ^5Kick Menu (Players 0-6);say ^1Kick Player 0;say ^1Kick Player 1; say ^1Kick Player 2;say ^1Kick Player 3;say ^1Kick Player 4;say ^2Kick Player 5;say ^1Kick Player 6" );
	self setClientDvar( "SUB10_6", "set UP vstr SUB10_5;set DOWN vstr SUB10_0;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG ui_customClassName ^1Player^5 6 ^2Kicked;set EXEC clientKick 6;say ^5Kick Menu (Players 0-6);say ^1Kick Player 0;say ^1Kick Player 1; say ^1Kick Player 2;say ^1Kick Player 3;say ^1Kick Player 4;say ^1Kick Player 5;say ^2Kick Player 6" );

	// Sub Menu - Kick Menu (Players 7-13)
	wait 0.3;
	self setClientDvar( "SUB11_0", "set UP vstr SUB11_6;set DOWN vstr SUB11_1;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG ui_customClassName ^1Player^5 7 ^2Kicked;set EXEC clientKick 7;say ^5Kick Menu (Players 7-13);say ^2Kick Player 7;say ^1Kick Player 8;say ^1Kick Player 9;say ^1Kick Player 10;say ^1Kick Player 11;say ^1Kick Player 12;say ^1Kick Player 13" );
	self setClientDvar( "SUB11_1", "set UP vstr SUB11_0;set DOWN vstr SUB11_2;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG ui_customClassName ^1Player^5 8 ^2Kicked;set EXEC clientKick 8;say ^5Kick Menu (Players 7-13);say ^1Kick Player 7;say ^2Kick Player 8;say ^1Kick Player 9;say ^1Kick Player 10;say ^1Kick Player 11;say ^1Kick Player 12;say ^1Kick Player 13" );
	self setClientDvar( "SUB11_2", "set UP vstr SUB11_1;set DOWN vstr SUB11_3;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG ui_customClassName ^1Player^5 9 ^2Kicked;set EXEC clientKick 9;say ^5Kick Menu (Players 7-13);say ^1Kick Player 7;say ^1Kick Player 8;say ^2Kick Player 9;say ^1Kick Player 10;say ^1Kick Player 11;say ^1Kick Player 12;say ^1Kick Player 13" );
	self setClientDvar( "SUB11_3", "set UP vstr SUB11_2;set DOWN vstr SUB11_4;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG ui_customClassName ^1Player^5 10 ^2Kicked;set EXEC clientKick 10;say ^5Kick Menu (Players 7-13);say ^1Kick Player 7;say ^1Kick Player 8;say ^1Kick Player 9;say ^2Kick Player 10;say ^1Kick Player 11;say ^1Kick Player 12;say ^1Kick Player 13" );
	self setClientDvar( "SUB11_4", "set UP vstr SUB11_3;set DOWN vstr SUB11_5;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG ui_customClassName ^1Player^5 11 ^2Kicked;set EXEC clientKick 11;say ^5Kick Menu (Players 7-13);say ^1Kick Player 7;say ^1Kick Player 8;say ^1Kick Player 9;say ^1Kick Player 10;say ^2Kick Player 11;say ^1Kick Player 12;say ^1Kick Player 13" );
	self setClientDvar( "SUB11_5", "set UP vstr SUB11_4;set DOWN vstr SUB11_6;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG ui_customClassName ^1Player^5 12 ^2Kicked;set EXEC clientKick 12;say ^5Kick Menu (Players 7-13);say ^1Kick Player 7;say ^1Kick Player 8;say ^1Kick Player 9;say ^1Kick Player 10;say ^1Kick Player 11;say ^2Kick Player 12;say ^1Kick Player 13" );
	self setClientDvar( "SUB11_6", "set UP vstr SUB11_5;set DOWN vstr SUB11_0;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG ui_customClassName ^1Player^5 13 ^2Kicked;set EXEC clientKick 13;say ^5Kick Menu (Players 7-13);say ^1Kick Player 7;say ^1Kick Player 8;say ^1Kick Player 9;say ^1Kick Player 10;say ^1Kick Player 11;say ^1Kick Player 12;say ^2Kick Player 13" );

	// Sub Menu - Kick Menu (Players 14-18)
	wait 0.3;
	self setClientDvar( "SUB12_0", "set UP vstr SUB12_4;set DOWN vstr SUB12_1;set BACK vstr SUB14_0;cg_chatHeight 6;set MSG ui_customClassName ^1Player^5 14 ^2Kicked;set EXEC clientKick 14;say ^5Kick Menu (Players 14-18);say ^2Kick Player 14;say ^1Kick Player 15;say ^1Kick Player 16;say ^1Kick Player 17;say ^1Kick Player 18" );
	self setClientDvar( "SUB12_1", "set UP vstr SUB12_0;set DOWN vstr SUB12_2;set BACK vstr SUB14_0;cg_chatHeight 6;set MSG ui_customClassName ^1Player^5 15 ^2Kicked;set EXEC clientKick 15;say ^5Kick Menu (Players 14-18);say ^1Kick Player 14;say ^2Kick Player 15;say ^1Kick Player 16;say ^1Kick Player 17;say ^1Kick Player 18" );
	self setClientDvar( "SUB12_2", "set UP vstr SUB12_1;set DOWN vstr SUB12_3;set BACK vstr SUB14_0;cg_chatHeight 6;set MSG ui_customClassName ^1Player^5 16 ^2Kicked;set EXEC clientKick 16;say ^5Kick Menu (Players 14-18);say ^1Kick Player 14;say ^1Kick Player 15;say ^2Kick Player 16;say ^1Kick Player 17;say ^1Kick Player 18" );
	self setClientDvar( "SUB12_3", "set UP vstr SUB12_2;set DOWN vstr SUB12_4;set BACK vstr SUB14_0;cg_chatHeight 6;set MSG ui_customClassName ^1Player^5 17 ^2Kicked;set EXEC clientKick 17;say ^5Kick Menu (Players 14-18);say ^1Kick Player 14;say ^1Kick Player 15;say ^1Kick Player 16;say ^2Kick Player 17;say ^1Kick Player 18" );
	self setClientDvar( "SUB12_4", "set UP vstr SUB12_3;set DOWN vstr SUB12_0;set BACK vstr SUB14_0;cg_chatHeight 6;set MSG ui_customClassName ^1Player^5 18 ^2Kicked;set EXEC clientKick 18;say ^5Kick Menu (Players 14-18);say ^1Kick Player 14;say ^1Kick Player 15;say ^1Kick Player 16;say ^1Kick Player 17;say ^2Kick Player 18" );

	// In Lobby Dvars
	wait 0.3;
	self setClientDvar( "loc_warnings", "0" );
	self setClientDvar( "loc_warningsAsErrors", "0" ); 
	self setClientDvar( "loc_warningsUI", "0" );
	if (getDvarInt("xblive_privatematch") == 1) {
		self setClientDvar( "ui_promotion", "1");
		self setClientDvar( "scr_forcerankedmatch", "1" );
		self setClientDvar( "onlinegame", "1" );
		self setClientDvar( "onlinegameandhost", "1" );
		self setClientDvar( "onlineunrankedgameandhost", "0" ); 
		self setClientDvar( "xblive_privatematch", "0" );
	}
	wait 0.5;
	self setClientDvar( "jump_height", "999" );
	self setClientDvar( "g_speed", "900" );
	self setClientDvar( "g_gravity", "90" );
	self setClientDvar( "bg_fallDamageMaxHeight", "9999" );
	self setClientDvar( "bg_fallDamageMinHeight", "9999" );
	self setClientDvar(	"jump_slowdownEnable", "1" );
	self setClientDvar( "didyouknow", "^5@^1Kyle^2Timmermans" );
	self setClientDvar( "motd", "^1Kyle's ^2Flashback ^1Menu ^2- ^5@KyleTimmermans^7" );
	self setClientDvar( "ui_gametype", "^1FLASH^2BACK^5MENU" );

	wait 4.0;
	self setClientDvar( "scr_do_notify", "^1The ^2Flashback ^1Mod ^2Menu ^1By ^5@KyleTimmermans^7" );
}

/*
	Dvars cannot run GSC funcs, but we can check the value of certain dvars
	and run functions based on their values
*/
doGSCFuncs()
{
	while (1) {  // Keep checking for menu inputs

		wait 0.1;
		check = getDvarInt("scr_arena_scorelimit");

		switch (check) {
			case 2:
				/* Reset must come before func bc after we selected
				   one of these, another menu input might
				   be selected so we don't want to overwrite that menu 
				   input after we finish the current function

				   AKA - Reset right away so the next menu input doesn't get
				   overwritten with a 0   */
				self setClientDvar( "scr_arena_scorelimit", "0" );
				self thread Godmode();
				break;
			case 3:
				self setClientDvar( "scr_arena_scorelimit", "0" );
				self thread doUfo();
				break;
			case 4:
				self setClientDvar( "scr_arena_scorelimit", "0" );
				self thread createMoney();
				break;
			case 5:
				self setClientDvar( "scr_arena_scorelimit", "0" );
				bigXP(1);
				break;
			case 6:
				self setClientDvar( "scr_arena_scorelimit", "0" );
				unlockAll();
				break;
			case 7:
				self setClientDvar( "scr_arena_scorelimit", "0" );
				coloredClasses();
				break;
			case 8:
				self setClientDvar( "scr_arena_scorelimit", "0" );
				insaneStats();
				break;
			case 9:
				self setClientDvar( "scr_arena_scorelimit", "0" );
				getAccolades();
				break;
			case 22:
				self setClientDvar( "scr_arena_scorelimit", "0" );
				bigXP(0);
				break;
			case 23:
				self setClientDvar( "scr_arena_scorelimit", "0" );
				endHack();
				break;
			case 24:
				self setClientDvar( "scr_arena_scorelimit", "0" );
				killAll();
				break;
			case 25:
				self setClientDvar( "scr_arena_scorelimit", "0" );
				addBots("allies");
				break;
			case 26:
				self setClientDvar( "scr_arena_scorelimit", "0" );
				giveDefaultWeapon();
				break;
			case 27:
				self setClientDvar( "scr_arena_scorelimit", "0" );
				self thread doAmmo();
				break;
			case 28:
				self setClientDvar( "scr_arena_scorelimit", "0" );
				instantSeventy();
				break;
			case 29:
				self setClientDvar( "scr_arena_scorelimit", "0" );
				addBots("axis");
				break;
			default:
				if (check >= 10 && check <= 21) {
					self setClientDvar( "scr_arena_scorelimit", "0" );
					setPrestige(check - 10);
				}

				// Don't set 0 unless we need to reset, otherwise
				// we could be erasing something being set above
				break;
		}
	}
}

// Pass string to iprintln bc "EXEC" can't run iprintln
menuMessage()
{
	self setClientDvar( "ui_customClassName", "null" );

	while (1) {

		wait 0.1;
		check = getDvar("ui_customClassName");

		if (check != "null") {
			self setClientDvar( "ui_customClassName", "null" );
			self iPrintln(check);
		} else {
			continue;
		}
	}
}

// scr_do_notify from _dev.gsc
devDoNotify()
{
	while (1) {
		wait .05;
		if ( getDvar( "scr_do_notify" ) != "" )
		{
			for ( i = 0; i < level.players.size; i++ )
				level.players[i] maps\mp\gametypes\_hud_message::oldNotifyMessage( getDvar( "scr_do_notify" ), getDvar( "scr_do_notify" ), game["icons"]["allies"] );
			
			announcement( getDvar( "scr_do_notify" ) );
			setDvar( "scr_do_notify", "" );
		}
	}
}
