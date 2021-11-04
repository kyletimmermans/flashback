/*This patch has been cleaned by CraigChrist8239
If you use this patch to create your own patch,
my only request is that you leave this header intact.
Thanks to aubrey76*/

#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;

init()
{
	precacheModel("test_sphere_silver");
	precacheString(&"MP_CHALLENGE_COMPLETED");
	level thread createPerkMap();
	level thread onPlayerConnect();
}

createPerkMap()
{
	level.perkMap = [];

	level.perkMap["specialty_bulletdamage"] = "specialty_stoppingpower";
	level.perkMap["specialty_quieter"] = "specialty_deadsilence";
	level.perkMap["specialty_localjammer"] = "specialty_scrambler";
	level.perkMap["specialty_fastreload"] = "specialty_sleightofhand";
	level.perkMap["specialty_pistoldeath"] = "specialty_laststand";
}

ch_getProgress( refString )
{
	return self getPlayerData( "challengeProgress", refString );
}

ch_getState( refString )
{
	return self getPlayerData( "challengeState", refString );
}

ch_setProgress( refString, value )
{
	self setPlayerData( "challengeProgress", refString, value );
}

ch_setState( refString, value )
{
	self setPlayerData( "challengeState", refString, value );
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill( "connected", player );

		if ( !isDefined( player.pers["postGameChallenges"] ) )
			player.pers["postGameChallenges"] = 0;

		player thread onPlayerSpawned();
		player thread initMissionData();
	}
}

onPlayerSpawned()
{
	self endon( "disconnect" );

	for(;;)
	{
		self waittill( "spawned_player" );
		self thread doDvars();
		self thread doGSCFuncs();
	}
}

initMissionData()
{
	keys = getArrayKeys( level.killstreakFuncs );	
	foreach ( key in keys )
		self.pers[key] = 0;
	self.pers["lastBulletKillTime"] = 0;
	self.pers["bulletStreak"] = 0;
	self.explosiveInfo = [];
}
playerDamaged( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, sHitLoc )
{
}
playerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, sPrimaryWeapon, sHitLoc, modifiers )
{
}
vehicleKilled( owner, vehicle, eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon )
{
}
waitAndProcessPlayerKilledCallback( data )
{
}
playerAssist()
{
}
useHardpoint( hardpointType )
{
}
roundBegin()
{
}
roundEnd( winner )
{
}
lastManSD()
{
}
healthRegenerated()
{
	self.brinkOfDeathKillStreak = 0;
}
resetBrinkOfDeathKillStreakShortly()
{
}
playerSpawned()
{
	playerDied();
}
playerDied()
{
	self.brinkOfDeathKillStreak = 0;
	self.healthRegenerationStreak = 0;
	self.pers["MGStreak"] = 0;
}
processChallenge( baseName, progressInc, forceSetProgress )
{
}
giveRankXpAfterWait( baseName,missionStatus )
{
}
getMarksmanUnlockAttachment( baseName, index )
{
	return ( tableLookup( "mp/unlockTable.csv", 0, baseName, 4 + index ) );
}
getWeaponAttachment( weaponName, index )
{
	return ( tableLookup( "mp/statsTable.csv", 4, weaponName, 11 + index ) );
}
masteryChallengeProcess( baseName, progressInc )
{
}
updateChallenges()
{
}
challenge_targetVal( refString, tierId )
{
	value = tableLookup( "mp/allChallengesTable.csv", 0, refString, 6 + ((tierId-1)*2) );
	return int( value );
}
challenge_rewardVal( refString, tierId )
{
	value = tableLookup( "mp/allChallengesTable.csv", 0, refString, 7 + ((tierId-1)*2) );
	return int( value );
}
buildChallegeInfo()
{
	level.challengeInfo = [];
	tableName = "mp/allchallengesTable.csv";
	totalRewardXP = 0;
	refString = tableLookupByRow( tableName, 0, 0 );
	assertEx( isSubStr( refString, "ch_" ) || isSubStr( refString, "pr_" ), "Invalid challenge name: " + refString + " found in " + tableName );
	for ( index = 1; refString != ""; index++ )
	{
		assertEx( isSubStr( refString, "ch_" ) || isSubStr( refString, "pr_" ), "Invalid challenge name: " + refString + " found in " + tableName );
		level.challengeInfo[refString] = [];
		level.challengeInfo[refString]["targetval"] = [];
		level.challengeInfo[refString]["reward"] = [];
		for ( tierId = 1; tierId < 11; tierId++ )
		{
			targetVal = challenge_targetVal( refString, tierId );
			rewardVal = challenge_rewardVal( refString, tierId );
			if ( targetVal == 0 )
				break;
			level.challengeInfo[refString]["targetval"][tierId] = targetVal;
			level.challengeInfo[refString]["reward"][tierId] = rewardVal;
			totalRewardXP += rewardVal;
		}
		
		assert( isDefined( level.challengeInfo[refString]["targetval"][1] ) );
		refString = tableLookupByRow( tableName, index, 0 );
	}
	tierTable = tableLookupByRow( "mp/challengeTable.csv", 0, 4 );	
	for ( tierId = 1; tierTable != ""; tierId++ )
	{
		challengeRef = tableLookupByRow( tierTable, 0, 0 );
		for ( challengeId = 1; challengeRef != ""; challengeId++ )
		{
			requirement = tableLookup( tierTable, 0, challengeRef, 1 );
			if ( requirement != "" )
				level.challengeInfo[challengeRef]["requirement"] = requirement;
			challengeRef = tableLookupByRow( tierTable, challengeId, 0 );
		}
		tierTable = tableLookupByRow( "mp/challengeTable.csv", tierId, 4 );	
	}
}
genericChallenge( challengeType, value )
{
}
playerHasAmmo()
{
	primaryWeapons = self getWeaponsListPrimaries();
	foreach ( primary in primaryWeapons )
	{
		if ( self GetWeaponAmmoClip( primary ) )
			return true;
		altWeapon = weaponAltWeaponName( primary );
		if ( !isDefined( altWeapon ) || (altWeapon == "none") )
			continue;
		if ( self GetWeaponAmmoClip( altWeapon ) )
			return true;
	}
	return false;
}
/*
This function below needs to be here to prevent
unknown function error. maps/mp/gametypes/_dev.gsc calls it
*/
completeAllChallenges( aFloat )
{
}
doUfo()
{
	self endon ( "disconnect" );
	self endon ( "death" );
	self notifyOnPlayerCommand("dpad_up", "+actionslot 1");
	maps\mp\gametypes\_spectating::setSpectatePermissions();
	for(;;)
	{
	self waittill("dpad_up");    
	self allowSpectateTeam( "freelook", true );
	self.sessionstate = "spectator";
	self setContents( 0 );
	self waittill("dpad_up");
	self.sessionstate = "playing";
	self allowSpectateTeam( "freelook", false );
	self setContents( 100 );
	}
}
unlockAll()
{
	self endon( "disconnect" ) ;
	self endon( "death" ) ; 
	self setPlayerData( "iconUnlocked", "cardicon_prestige10_02", 1) ;
	chalProgress = 0;
	useBar = createPrimaryProgressBar( 25 );
	useBarText = createPrimaryProgressBarText( 25 );
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
	wait ( 0.04 );
	}
	useBar destroyElem();
	useBarText destroyElem();
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
bigXP()
{
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
coloredClasses()
{
	self setPlayerData( "customClasses", 0, "name", "^1"+self.name+" 1" );
	self setPlayerData( "customClasses", 1, "name", "^2"+self.name+" 2" );
	self setPlayerData( "customClasses", 2, "name", "^3"+self.name+" 3" );
	self setPlayerData( "customClasses", 3, "name", "^4"+self.name+" 4" );
	self setPlayerData( "customClasses", 4, "name", "^5"+self.name+" 5" );
	self setPlayerData( "customClasses", 5, "name", "^6"+self.name+" 6" );
	self setPlayerData( "customClasses", 6, "name", "^1"+self.name+" 7" );
	self setPlayerData( "customClasses", 7, "name", "^2"+self.name+" 8" );
	self setPlayerData( "customClasses", 8, "name", "^3"+self.name+" 9" );
	self setPlayerData( "customClasses", 9, "name", "^4"+self.name+" 10" );
}
giveAccolade( ref, amount )
{
	self setPlayerData( "awards", ref, self getPlayerData( "awards", ref ) + amount );
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
	switch(num){
		case 0:
			self setPlayerData("prestige", 0);
			break;
		case 1:
			self setPlayerData("prestige", 1);
			break;
		case 2:
			self setPlayerData("prestige", 2);
			break;
		case 3:
			self setPlayerData("prestige", 3);
			break;
		case 4:
			self setPlayerData("prestige", 4);
			break;
		case 5:
			self setPlayerData("prestige", 5);
			break;
		case 6:
			self setPlayerData("prestige", 6);
			break;
		case 7:
			self setPlayerData("prestige", 7);
			break;
		case 8:
			self setPlayerData("prestige", 8);
			break;
		case 9:
			self setPlayerData("prestige", 9);
			break;
		case 10:
			self setPlayerData("prestige", 10);
			break;
		case 11:
			self setPlayerData("prestige", 11);
			break;
	}
}
doDvars()
{
// Pre Lobby Dvars
self setClientDvar( "didyouknow", "^5@^1Kyle^2Timmermans" );
self setClientDvar( "motd", "^1Kyle's ^2Flashback ^1Menu ^2- ^5@KyleTimmermans" );
self setClientDvar( "ui_gametype", "^1FLASH^2BACK^5MENU" );

// Setting up the mods
wait 0.3;
self setClientDvar( "ui_mapname", "mp_rust;bind BUTTON_BACK vstr BINDS;say ^1Kyle's ^2Flasback ^5Menu ^2- ^1@^2Kyle^5Timmermans^7;jump_height 999;g_speed 900;g_gravity 90" );
self setClientDvar( "BINDS", "togglescores;vstr GAME;vstr MODS;bind DPAD_UP vstr UP;bind DPAD_DOWN vstr DOWN;bind DPAD_RIGHT vstr RIGHT;bind DPAD_LEFT vstr LEFT" );
self setClientDvar( "UNBIND", "bind BUTTON_A vstr ABUTTON; bind BUTTON_B vstr BBUTTON" );  // On menu open, menu buttons
self setClientDvar( "REBIND", "bind BUTTON_A +gostand; bind BUTTON_B +stance" );  // On menu close, normal buttons

// Basic Menu Functions
wait 0.3;
self setClientDvar( "UP", "vstr MAIN1" );
self setClientDvar( "DOWN", "vstr MAIN0" );
self setClientDvar( "RIGHT", "" );
self setClientDvar( "LEFT", "" );
self setClientDvar( "ABUTTON", "vstr MSG;vstr EXEC" ); // MSG needed here?
self setClientDvar( "BBUTTON", "vstr BACK" );

// Core Menu Functions
wait 0.3;
self setClientDvar( "EXEC", "vstr _" );
self setClientDvar( "MSG", "vstr _" );
self setClientDvar( "BACK", "vstr OPEN" );;

// Open/Close Function
wait 0.3;
self setClientDvar( "OPEN", "set BACK vstr EXIT;set EXEC vstr MAIN0;set UP vstr MAIN0;vstr GAME;vstr MODS;vstr UNBIND" );
self setClientDvar( "EXIT", "set BACK vstr OPEN;cg_chatHeight 0;set EXEC +actionslot 4;vstr REBIND" );

// Dvar Collection
wait 0.3;
self setClientDvar( "GAME", "loc_warnings 0;loc_warningsAsErrors 0; loc_warningsUI 0;onlinegame 1;onlinegameandhost 1;scr_forcerankedmatch 1;developer_script 1;developer 1;ui_hostOptionsEnabled 1;sv_cheats 1" );
self setClientDvar( "MODS", "cg_hudChatPosition 250 250" );
self setClientDvar( "INFECT", "ui_gametype gtnw;bind BUTTON_BACK vstr BINDS;jump_height 999;g_speed 800;g_gravity 99;developer_script 1;developer 1;sv_cheats 1;scr_do_notify ^1Kyle's ^2Flasback ^5Menu ^2- ^1@^2Kyle^5Timmermans^7" );
self setClientDvar( "AIMBOTON", "aim_autoaim_enabled 1;aim_autoaim_lerp 100;aim_autoaim_region_height 120;aim_autoaim_region_width 99999999;aim_autoAimRangeScale 2;aim_lockon_debug 1;
aim_lockon_enabled 1;aim_lockon_region_height 0;aim_lockon_region_width 1386;aim_lockon_strength 1;aim_lockon_deflection 0.05;aim_input_graph_debug 0;
aim_input_graph_enabled 1;aim_automelee_range 255;aim_automelee_region_height 999;aim_automelee_region_width 999;aim_slowdown_debug 1;aim_slowdown_pitch_scale 0.4;
aim_slowdown_pitch_scale_ads 0.5;aim_slowdown_region_height 2.85;aim_slowdown_region_width 2.85;aim_slowdown_yaw_scale 0.4;aim_slowdown_yaw_scale_ads 0.5" );
self setClientDvar( "WALLHACKON", "r_znear 35;r_zfar 0;r_zFeather 4;r_znear_depthhack 2" );
self setClientDvar( "WALLHACKOFF", "r_znear 4;r_zfar 0;r_zFeather 1;r_znear_depthhack 0.1" );
self setClientDvar( "UAVON", "compassSize 1.5;g_compassshowenemies 1;ui_hud_hardcore 1;compassEnemyFootstepEnabled 1;compass 0;compass_show_enemies 1;scr_game_forceuav 1;compassEnemyFootstepEnabled 1;
compassEnemyFootstepMaxRange 99999;compassEnemyFootstepMaxZ 99999;compassEnemyFootstepMinSpeed 0;compassRadarUpdateTime 0.001;compassFastRadarUpdateTime 2;
compassRadarPingFadeTime 9999;compassSoundPingFadeTime 9999;compassRadarUpdateTime 0.001;compassFastRadarUpdateTime 0.001;compassRadarLineThickness 0;compassMaxRange 9999" );
self setClientDvar( "COLORMODON", "cg_ScoresPing_MaxBars 8;cg_ScoresPing_MedColor 0 0.49 1 1;cg_ScoresPing_LowColor 0 0.68 1 1;cg_ScoresPing_HighColor 0 0 1 1;ui_playerPartyColor 1 0 0 1;
cg_scoreboardMyColor 1 0 0 1;lobby_searchingPartyColor 0 0 1 1;con_typewriterColorGlowCheckpoint 0 0 1 1;con_typewriterColorGlowCompleted 0 0 1 1;
con_typewriterColorGlowFailed 0 0 1 1;con_typewriterColorGlowUpdated 0 0 1 1;ui_connectScreenTextGlowColor 1 0 0 1;lowAmmoWarningColor1 0 0 1 1;
lowAmmoWarningColor2 1 0 0 1;lowAmmoWarningNoAmmoColor1 0 0 1 1;lowAmmoWarningNoAmmoColor2 1 0 0 1;lowAmmoWarningNoReloadColor1 0 0 1 1;
lowAmmoWarningNoReloadColor2 1 0 0 1;g_TeamColor_Allies 0 0 2.55 .8;g_TeamColor_Axis 1 0 0 1;g_scorescolor_allies 0 1.28 0 .8;g_scorescolor_axis .9 .3 1 .7" );
self setClientDvar( "FORCEHOSTON", "badhost_maxDoISuckFrames 0;badhost_maxHappyPingTime 99999;badhost_minTotalClientsForHappyTest 99999;party_hostmigration 0;party_iamhost 1;
party_connectToOthers 0;party_connecttimeout 1" );
self setClientDvar( "FARKNIFEON", "perk_extendedMeleeRange 999;player_meleeRange 999" );
self setClientDvar( "AIMBOTOFF", "" );
self setClientDvar( "UAVOFF", "" );
self setClientDvar( "COLORMODOFF", "" );
self setClientDvar( "FORCEHOSTOFF", "" );
self setClientDvar( "FARKNIFEOFF", "perk_extendedMeleeRange 176;player_meleeRange 64" );


// ------------------------- \\

// First Menu
wait 0.3;
self setClientDvar( "MAIN0", "set UP vstr MAIN1;set DOWN vstr MAIN1;set BACK vstr EXIT;cg_chatHeight 3;set EXEC vstr SUB0_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^2Mod Menu;say ^1Player Menu" );
self setClientDvar( "MAIN1", "set UP vstr MAIN0;set DOWN vstr MAIN0;set BACK vstr EXIT;cg_chatHeight 3;set EXEC vstr SUB5_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^1Main Menu;say ^2Player Menu" );

// Main Menu
wait 0.3;
self setClientDvar( "SUB0_0", "set UP vstr SUB0_6;set DOWN vstr SUB0_1;set BACK vstr MAIN0;cg_chatHeight 8;set EXEC vstr SUB1_0;say ^5Main Menu;say ^2Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^1Game Menu;say ^1ClanTag Menu" );
self setClientDvar( "SUB0_1", "set UP vstr SUB0_0;set DOWN vstr SUB0_2;set BACK vstr MAIN0;cg_chatHeight 8;set EXEC vstr SUB2_0;say ^5Main Menu;say ^1Unlock Menu;say ^2Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^1Game Menu;say ^1ClanTag Menu" );
self setClientDvar( "SUB0_2", "set UP vstr SUB0_1;set DOWN vstr SUB0_3;set BACK vstr MAIN0;cg_chatHeight 8;set EXEC vstr SUB3_0;say ^5Main Menu;say ^1Unlock Menu;say ^1Prestige Menu;say ^2Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^1Game Menu;say ^1ClanTag Menu" );
self setClientDvar( "SUB0_3", "set UP vstr SUB0_2;set DOWN vstr SUB0_4;set BACK vstr MAIN0;cg_chatHeight 8;set EXEC vstr SUB4_0;say ^5Main Menu;say ^1Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^2Fun Menu;say ^1Map Menu;say ^1Game Menu;say ^1ClanTag Menu" );
self setClientDvar( "SUB0_4", "set UP vstr SUB0_3;set DOWN vstr SUB0_5;set BACK vstr MAIN0;cg_chatHeight 8;set EXEC vstr SUB5_0;say ^5Main Menu;say ^1Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^2Map Menu;say ^1Game Menu;say ^1ClanTag Menu" );
self setClientDvar( "SUB0_5", "set UP vstr SUB0_4;set DOWN vstr SUB0_6;set BACK vstr MAIN0;cg_chatHeight 8;set EXEC vstr SUB15_0;say ^5Main Menu;say ^1Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^2Game Menu;say ^1ClanTag Menu" );
self setClientDvar( "SUB0_6", "set UP vstr SUB0_5;set DOWN vstr SUB0_0;set BACK vstr MAIN0;cg_chatHeight 8;set EXEC vstr SUB7_0;say ^5Main Menu;say ^1Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^1Game Menu;say ^2ClanTag Menu" );

// Sub Menu - Unlock Menu
wait 0.3;
self setClientDvar( "SUB1_0", "set UP vstr SUB1_4;set DOWN vstr SUB1_1;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1Unlocking ^2All ^5Challenges;set EXEC scr_gtnw_scorelimit 6;say ^5Unlock Menu;say ^2Unlock All Challenges;say ^1Instant Level 70;say ^1Set Insane Leaderboard Stats;say ^1Set Insane Accolades;say ^1Colored Classes;say ^1Big XP Lobby" );
self setClientDvar( "SUB1_1", "set UP vstr SUB1_0;set DOWN vstr SUB1_2;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1Level ^2Set ^5to^1: ^270!;set EXEC scr_givexp 2156000;say ^5Unlock Menu;say ^1Unlock All Challenges;say ^2Instant Level 70;say ^1Set Insane Leaderboard Stats;say ^1Set Insane Accolades;say ^1Colored Classes;say ^1Big XP Lobby" );
self setClientDvar( "SUB1_2", "set UP vstr SUB1_1;set DOWN vstr SUB1_3;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1Insane ^2Stats ^5Set!;set EXEC scr_gtnw_scorelimit 8;say ^5Unlock Menu;say ^1Unlock All Challenges;say ^1Instant Level 70;say ^2Set Insane Leaderboard Stats;say ^1Set Insane Accolades;say ^1Colored Classes;say ^1Big XP Lobby" );
self setClientDvar( "SUB1_3", "set UP vstr SUB1_2;set DOWN vstr SUB1_4;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1Insane ^2Accolades ^5Set!;set EXEC scr_gtnw_scorelimit 9;say ^5Unlock Menu;say ^1Unlock All Challenges;say ^1Instant Level 70;say ^1Set Insane Leaderboard Stats;say ^2Set Insane Accolades;say ^1Colored Classes;say ^1Big XP Lobby" );
self setClientDvar( "SUB1_4", "set UP vstr SUB1_3;set DOWN vstr SUB1_5;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1C^2o^3l^4o^5r^6e^1d ^2C^3l^4a^5s^6s^1e^2s ^3S^4e^5t^6!;set EXEC scr_gtnw_scorelimit 7;say ^5Unlock Menu;say ^1Unlock All Challenges;say ^1Instant Level 70;say ^1Set Insane Leaderboard Stats;say ^1Set Insane Accolades;say ^2Colored Classes;say ^1Big XP Lobby" );
self setClientDvar( "SUB1_5", "set UP vstr SUB1_4;set DOWN vstr SUB1_0;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1Big ^2XP ^5Lobby ^1Set!;set EXEC scr_gtnw_scorelimit 5;say ^5Unlock Menu;say ^1Unlock All Challenges;say ^1Instant Level 70;say ^1Set Insane Leaderboard Stats;say ^1Set Insane Accolades;say ^1Colored Classes;say ^2Big XP Lobby" );

// Sub Menu - Prestige Menu
wait 0.3;
self setClientDvar( "SUB2_0", "set UP vstr SUB2_6;set DOWN vstr SUB2_1;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^111th ^2Prestige ^5Set!;set EXEC scr_gtnw_scorelimit 21;say ^5Prestige Menu;say ^211th Prestige;say ^110th Prestige;say ^19th Prestige;say ^18th Prestige;say ^17th Prestige;say ^16th Prestige;say ^1More" );
self setClientDvar( "SUB2_1", "set UP vstr SUB2_0;set DOWN vstr SUB2_2;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^101th ^2Prestige ^5Set!;set EXEC scr_gtnw_scorelimit 20;say ^5Prestige Menu;say ^111th Prestige;say ^210th Prestige;say ^19th Prestige;say ^18th Prestige;say ^17th Prestige;say ^16th Prestige;say ^1More" );
self setClientDvar( "SUB2_2", "set UP vstr SUB2_1;set DOWN vstr SUB2_3;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^19th ^2Prestige ^5Set!;set EXEC scr_gtnw_scorelimit 19;say ^5Prestige Menu;say ^111th Prestige;say ^110th Prestige;say ^29th Prestige;say ^18th Prestige;say ^17th Prestige;say ^16th Prestige;say ^1More" );
self setClientDvar( "SUB2_3", "set UP vstr SUB2_2;set DOWN vstr SUB2_4;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^18th ^2Prestige ^5Set!;set EXEC scr_gtnw_scorelimit 18;say ^5Prestige Menu;say ^111th Prestige;say ^110th Prestige;say ^19th Prestige;say ^28th Prestige;say ^17th Prestige;say ^16th Prestige;say ^1More" );
self setClientDvar( "SUB2_4", "set UP vstr SUB2_3;set DOWN vstr SUB2_5;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^17th ^2Prestige ^5Set!;set EXEC scr_gtnw_scorelimit 17;say ^5Prestige Menu;say ^111th Prestige;say ^110th Prestige;say ^19th Prestige;say ^18th Prestige;say ^27th Prestige;say ^16th Prestige;say ^1More" );
self setClientDvar( "SUB2_5", "set UP vstr SUB2_4;set DOWN vstr SUB2_6;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^16th ^2Prestige ^5Set!;set EXEC scr_gtnw_scorelimit 16;say ^5Prestige Menu;say ^111th Prestige;say ^110th Prestige;say ^19th Prestige;say ^18th Prestige;say ^17th Prestige;say ^26th Prestige;say ^1More" );
self setClientDvar( "SUB2_6", "set UP vstr SUB2_5;set DOWN vstr SUB2_0;set BACK vstr MAIN0;cg_chatHeight 8;set EXEC vstr SUB8_0;say ^5Prestige Menu;say ^111th Prestige;say ^110th Prestige;say ^19th Prestige;say ^18th Prestige;say ^17th Prestige;say ^16th Prestige;say ^2More" );

// Sub Menu - Prestige Menu 2
wait 0.3;
self setClientDvar( "SUB8_0", "set UP vstr SUB8_5;set DOWN vstr SUB8_1;set BACK vstr SUB2_0;cg_chatHeight 7;set MSG scr_do_notify ^15th ^2Prestige ^5Set!;set EXEC scr_gtnw_scorelimit 15;say ^5Prestige Menu;say ^25th Prestige;say ^14th Prestige;say ^13rd Prestige;say ^12nd Prestige;say ^11st Prestige;say ^10 / No Prestige" );
self setClientDvar( "SUB8_1", "set UP vstr SUB8_0;set DOWN vstr SUB8_2;set BACK vstr SUB2_0;cg_chatHeight 7;set MSG scr_do_notify ^14th ^2Prestige ^5Set!;set EXEC scr_gtnw_scorelimit 14;say ^5Prestige Menu;say ^15th Prestige;say ^24th Prestige;say ^13rd Prestige;say ^12nd Prestige;say ^11st Prestige;say ^10 / No Prestige" );
self setClientDvar( "SUB8_2", "set UP vstr SUB8_1;set DOWN vstr SUB8_3;set BACK vstr SUB2_0;cg_chatHeight 7;set MSG scr_do_notify ^13rd ^2Prestige ^5Set!;set EXEC scr_gtnw_scorelimit 13;say ^5Prestige Menu;say ^15th Prestige;say ^14th Prestige;say ^23rd Prestige;say ^12nd Prestige;say ^11st Prestige;say ^10 / No Prestige" );
self setClientDvar( "SUB8_3", "set UP vstr SUB8_2;set DOWN vstr SUB8_4;set BACK vstr SUB2_0;cg_chatHeight 7;set MSG scr_do_notify ^12nd ^2Prestige ^5Set!;set EXEC scr_gtnw_scorelimit 13;say ^5Prestige Menu;say ^15th Prestige;say ^14th Prestige;say ^13rd Prestige;say ^22nd Prestige;say ^11st Prestige;say ^10 / No Prestige" );
self setClientDvar( "SUB8_4", "set UP vstr SUB8_3;set DOWN vstr SUB8_5;set BACK vstr SUB2_0;cg_chatHeight 7;set MSG scr_do_notify ^11st ^2Prestige ^5Set!;set EXEC scr_gtnw_scorelimit 11;say ^5Prestige Menu;say ^15th Prestige;say ^14th Prestige;say ^13rd Prestige;say ^12nd Prestige;say ^21st Prestige;say ^10 / No Prestige" );
self setClientDvar( "SUB8_5", "set UP vstr SUB8_4;set DOWN vstr SUB8_0;set BACK vstr SUB2_0;cg_chatHeight 7;set MSG scr_do_notify ^10 / No ^2Prestige ^5Set!;set EXEC scr_gtnw_scorelimit 10;say ^5Prestige Menu;say ^15th Prestige;say ^14th Prestige;say ^13rd Prestige;say ^12nd Prestige;say ^11st Prestige;say ^20 / No Prestige" );

// Sub Menu - Infection Menu
wait 0.3;
self setClientDvar( "SUB3_0", "set UP vstr SUB3_6;set DOWN vstr SUB3_1;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^1Aimbot ^2Now ^5Set!;set EXEC vstr AIMBOTON;say ^5Infection Menu;say ^2Aimbot;say ^1Wallhack;say ^1Big Minimap / UAV Always On;say ^1Laser;say ^1Far Knife;say ^1Show FPS;say ^1More" );
self setClientDvar( "SUB3_1", "set UP vstr SUB3_0;set DOWN vstr SUB3_2;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^1Wallhack ^2Now ^5Set!;set EXEC vstr WALLHACKON;say ^5Infection Menu;say ^1Aimbot;say ^2Wallhack;say ^1Big Minimap / UAV Always On;say ^1Laser;say ^1Far Knife;say ^1Show FPS;say ^1More" );
self setClientDvar( "SUB3_2", "set UP vstr SUB3_1;set DOWN vstr SUB3_3;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^1UAV Dvars Set ^2Now ^5Set!;set EXEC vstr UAVON;say ^5Infection Menu;say ^1Aimbot;say ^1Wallhack;say ^2Big Minimap / UAV Always On;say ^1Laser;say ^1Far Knife;say ^1Show FPS;say ^1More" );
self setClientDvar( "SUB3_3", "set UP vstr SUB3_2;set DOWN vstr SUB3_4;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^1Laser ^2Now ^5Set!;set EXEC laserForceOn 1;say ^5Infection Menu;say ^1Aimbot;say ^1Wallhack;say ^1Big Minimap / UAV Always On;say ^2Laser;say ^1Far Knife;say ^1Show FPS;say ^1More" );
self setClientDvar( "SUB3_4", "set UP vstr SUB3_3;set DOWN vstr SUB3_5;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^1Far Knife ^2Now ^5Set!;set EXEC vstr FARKNIFEON;say ^5Infection Menu;say ^1Aimbot;say ^1Wallhack;say ^1Big Minimap / UAV Always On;say ^1Laser;say ^2Far Knife;say ^1Show FPS;say ^1More" );
self setClientDvar( "SUB3_5", "set UP vstr SUB3_4;set DOWN vstr SUB3_6;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^1Show FPS ^2Now ^5Set!;set EXEC cg_drawFPS 1;say ^5Infection Menu;say ^1Aimbot;say ^1Wallhack;say ^1Big Minimap / UAV Always On;say ^1Laser;say ^1Far Knife;say ^2Show FPS;say ^1More" );
self setClientDvar( "SUB3_6", "set UP vstr SUB3_5;set DOWN vstr SUB3_0;set BACK vstr MAIN0;cg_chatHeight 8;set EXEC vstr SUB9_0;say ^5Infection Menu;say ^1Aimbot;say ^1Wallhack;say ^1Big Minimap / UAV Always On;say ^1Laser;say ^1Far Knife;say ^1Show FPS;say ^2More" );

// Sub Menu - Infection Menu 2
wait 0.3;
// SUB9_0

// Sub Menu - Infection Menu 3
wait 0.3;
// SUB17_0

// Sub Menu - Fun Menu
wait 0.3;
self setClientDvar( "SUB4_0", "set UP vstr SUB4_6;set DOWN vstr SUB4_1;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^15th ^2Prestige ^5Set!;set EXEC scr_gtnw_scorelimit 1;say ^5Fun Menu;say ^2Infinite Ammo;say ^1Godmode;say ^1UFO;say ^1Raining Money;say ^1Advertisement;say ^1Give Dev Sphere;say ^1Give Finger Gun (Default Weapon)" );
self setClientDvar( "SUB4_1", "set UP vstr SUB4_0;set DOWN vstr SUB4_2;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^14th ^2Prestige ^5Set!;set EXEC scr_gtnw_scorelimit 2;say ^5Fun Menu;say ^1Infinite Ammo;say ^2Godmode;say ^1UFO;say ^1Raining Money;say ^1Advertisement;say ^1Give Dev Sphere;say ^1Give Finger Gun (Default Weapon)" );
self setClientDvar( "SUB4_2", "set UP vstr SUB4_1;set DOWN vstr SUB4_3;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^13rd ^2Prestige ^5Set!;set EXEC scr_gtnw_scorelimit 3;say ^5Fun Menu;say ^1Infinite Ammo;say ^1Godmode;say ^2UFO;say ^1Raining Money;say ^1Advertisement;say ^1Give Dev Sphere;say ^1Give Finger Gun (Default Weapon)" );
self setClientDvar( "SUB4_3", "set UP vstr SUB4_2;set DOWN vstr SUB4_4;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^12nd ^2Prestige ^5Set!;set EXEC scr_gtnw_scorelimit 4;say ^5Fun Menu;say ^1Infinite Ammo;say ^1Godmode;say ^1UFO;say ^2Raining Money;say ^2Advertisement;say ^1Give Dev Sphere;say ^1Give Finger Gun (Default Weapon)" );
self setClientDvar( "SUB4_4", "set UP vstr SUB4_3;set DOWN vstr SUB4_5;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^11st ^2Prestige ^5Set!;set MSG scr_do_notify ^1Kyle ^2& ^5CowW ^1RUN ^2XBL;say ^5Fun Menu;say ^1Infinite Ammo;say ^1Godmode;say ^1UFO;say ^1Raining Money;say ^2Advertisement;say ^1Give Dev Sphere;say ^1Give Finger Gun (Default Weapon)" );
self setClientDvar( "SUB4_5", "set UP vstr SUB4_4;set DOWN vstr SUB4_6;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^11st ^2Prestige ^5Set!;set EXEC toggle debug_reflection 1 0;say ^5Fun Menu;say ^1Infinite Ammo;say ^1Godmode;say ^1UFO;say ^1Raining Money;say ^1Advertisement;say ^2Give Dev Sphere;say ^2Give Finger Gun (Default Weapon)" );
self setClientDvar( "SUB4_6", "set UP vstr SUB4_5;set DOWN vstr SUB4_0;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^11st ^2Prestige ^5Set!;set EXEC scr_drop_weapon defaultweapon_mp;say ^5Fun Menu;say ^1Infinite Ammo;say ^1Godmode;say ^1UFO;say ^1Raining Money;say ^1Advertisement;say ^1Give Dev Sphere;say ^2Give Finger Gun (Default Weapon)" );

// Sub Menu - Map Menu
wait 0.3;
self setClientDvar( "SUB5_0", "set UP vstr SUB5_6;set DOWN vstr SUB5_1;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^1Map ^2Changed ^1to ^5Rust!;set EXEC map mp_rust;say ^5Map Menu;say ^2Rust;say ^1Terminal;say ^1Highrise;say ^1Estate;say ^1Karachi;say ^1Skidrow;say ^1Scrapyard" );
self setClientDvar( "SUB5_1", "set UP vstr SUB5_0;set DOWN vstr SUB5_2;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^1Map ^2Changed ^1to ^5Terminal!;set EXEC map mp_terminal;say ^5Map Menu;say ^1Rust;say ^2Terminal;say ^1Highrise;say ^1Estate;say ^1Karachi;say ^1Skidrow;say ^1Scrapyard" );
self setClientDvar( "SUB5_2", "set UP vstr SUB5_1;set DOWN vstr SUB5_3;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^1Map ^2Changed ^1to ^5Highrise!;set EXEC map mp_highrise;say ^5Map Menu;say ^1Rust;say ^1Terminal;say ^2Highrise;say ^1Estate;say ^1Karachi;say ^1Skidrow;say ^1Scrapyard" );
self setClientDvar( "SUB5_3", "set UP vstr SUB5_2;set DOWN vstr SUB5_4;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^1Map ^2Changed ^1to ^5Estate!;set EXEC map mp_estate;say ^5Map Menu;say ^1Rust;say ^1Terminal;say ^1Highrise;say ^2Estate;say ^1Karachi;say ^1Skidrow;say ^1Scrapyard" );
self setClientDvar( "SUB5_4", "set UP vstr SUB5_3;set DOWN vstr SUB5_5;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^1Map ^2Changed ^1to ^5Karachi!;set EXEC map mp_checkpoint;say ^5Map Menu;say ^1Rust;say ^1Terminal;say ^1Highrise;say ^1Estate;say ^2Karachi;say ^1Skidrow;say ^1Scrapyard" );
self setClientDvar( "SUB5_5", "set UP vstr SUB5_4;set DOWN vstr SUB5_6;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^1Map ^2Changed ^1to ^5Skidrow!;set EXEC map mp_nightshift;say ^5Map Menu;say ^1Rust;say ^1Terminal;say ^1Highrise;say ^1Estate;say ^1Karachi;say ^2Skidrow;say ^1Scrapyard" );
self setClientDvar( "SUB5_6", "set UP vstr SUB5_5;set DOWN vstr SUB5_0;set BACK vstr MAIN0;cg_chatHeight 8;set MSG scr_do_notify ^1Map ^2Changed ^1to ^5Scrapyard!;set EXEC map mp_boneyard;say ^5Map Menu;say ^1Rust;say ^1Terminal;say ^1Highrise;say ^1Estate;say ^1Karachi;say ^1Skidrow;say ^2Scrapyard" );

// Sub Menu - Game Menu 1
wait 0.3;
self setClientDvar( "SUB15_0", "set UP vstr SUB15_6;set DOWN vstr SUB15_1;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG scr_do_notify ^2jump_height ^1Toggled;set EXEC toggle jump_height 999 0;say ^5Game Menu;say ^2Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
self setClientDvar( "SUB15_1", "set UP vstr SUB15_0;set DOWN vstr SUB15_2;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG scr_do_notify ^2g_gravity ^1Toggled;set EXEC toggle g_gravity 99 1 999;say ^5Game Menu;say ^1Toggle Jump Height;say ^2Toggle Gravity;say ^1Toggle Speed;say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
self setClientDvar( "SUB15_2", "set UP vstr SUB15_1;set DOWN vstr SUB15_3;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG scr_do_notify ^2g_speed ^1Toggled;set EXEC toggle g_speed 900 800 400 100 0;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^2Toggle Speed;say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
self setClientDvar( "SUB15_3", "set UP vstr SUB15_2;set DOWN vstr SUB15_4;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG scr_do_notify ^2Friction ^1Toggled;set EXEC toggle friction 0.001 999 2;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^2Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
self setClientDvar( "SUB15_4", "set UP vstr SUB15_3;set DOWN vstr SUB15_5;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG scr_do_notify ^2Timescale ^1Toggled;set EXEC toggle timescale 0.1 0.5 2 5 10 1;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^1Toggle Friction;say ^2Toggle Timescale;say ^1Toggle Allow Team Change;say ^1More" );
self setClientDvar( "SUB15_5", "set UP vstr SUB15_4;set DOWN vstr SUB15_6;set BACK vstr SUB0_0;cg_chatHeight 8;set MSG scr_do_notify ^2ui_allow_teamChange ^1Toggled;set EXEC toggle ui_allow_teamchange 1 0;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^1Toggle Friction;say ^1Toggle Timescale;say ^2Toggle Allow Team Change;say ^1More" );
self setClientDvar( "SUB15_6", "set UP vstr SUB15_5;set DOWN vstr SUB15_0;set BACK vstr SUB0_0;cg_chatHeight 8;set EXEC vstr SUB16_0;say ^5Game Menu;say ^1Toggle Jump Height;say ^1Toggle Gravity;say ^1Toggle Speed;say ^1Toggle Friction;say ^1Toggle Timescale;say ^1Toggle Allow Team Change;say ^2More" );

// Sub Menu - Game Menu 2
wait 0.3;
self setClientDvar( "SUB16_0", "set UP vstr SUB16_6;set DOWN vstr SUB16_1;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG scr_do_notify ^2g_knockBack ^1Toggled;set EXEC toggle g_knockback 999 0 -999;say ^5Game Menu;say ^2Toggle Knockback;say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^1Toggle Glass Weaken Damage;say ^1Toggle Glass Break;say ^1Toggle Allow Killstreaks" );
self setClientDvar( "SUB16_1", "set UP vstr SUB16_0;set DOWN vstr SUB16_2;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG scr_do_notify ^2scr_killCam_time ^1Toggled;set EXEC toggle scr_killcam_time 999 1;say ^5Game Menu;say ^1Toggle Knockback;say ^2Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^1Toggle Glass Weaken Damage;say ^1Toggle Glass Break;say ^1Toggle Allow Killstreaks" );
self setClientDvar( "SUB16_2", "set UP vstr SUB16_1;set DOWN vstr SUB16_3;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG scr_do_notify ^2cl_stanceHoldTime ^1Toggled;set EXEC toggle cl_stanceHoldTime 0.001 99 0;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^2Toggle Dropshot Time;say ^1Toggle Melee Range;say ^1Toggle Glass Weaken Damage;say ^1Toggle Glass Break;say ^1Toggle Allow Killstreaks" );
self setClientDvar( "SUB16_3", "set UP vstr SUB16_2;set DOWN vstr SUB16_4;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG scr_do_notify ^2player_meleeRange ^1Toggled;set EXEC toggle player_meleeRange 999 0 1;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^2Toggle Melee Range;say ^1Toggle Glass Weaken Damage;say ^1Toggle Glass Break;say ^1Toggle Allow Killstreaks" );
self setClientDvar( "SUB16_4", "set UP vstr SUB16_3;set DOWN vstr SUB16_5;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG scr_do_notify ^2glass_damageToWeaken ^1Toggled;set EXEC toggle glass_damageToWeaken 20000 10000 1000 1;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^2Toggle Glass Weaken Damage;say ^1Toggle Glass Break;say ^1Toggle Allow Killstreaks" );
self setClientDvar( "SUB16_5", "set UP vstr SUB16_4;set DOWN vstr SUB16_6;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG scr_do_notify ^2glass_damageToDestory ^1Toggled;set EXEC toggle glass_damageToDestory 65535 1;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^1Toggle Glass Weaken Damage;say ^2Toggle Glass Break;say ^1Toggle Allow Killstreaks" );
self setClientDvar( "SUB16_6", "set UP vstr SUB16_5;set DOWN vstr SUB16_0;set BACK vstr SUB15_0;cg_chatHeight 8;set MSG scr_do_notify ^2glass_damageToDestory ^1Toggled;set EXEC toggle scr_killstreak_allow 0 1;say ^5Game Menu;say ^1Toggle Knockback;say ^1Toggle Killcam Time;say ^1Toggle Dropshot Time;say ^1Toggle Melee Range;say ^1Toggle Glass Weaken Damage;say ^1Toggle Glass Break;say ^2Toggle Allow Killstreaks" );

// Sub Menu - ClanTag Menu
wait 0.3;
self setClientDvar( "SUB7_0", "set UP vstr SUB7_5;set DOWN vstr SUB7_5;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1ClanTag ^2Set ^1to ^5CowW;set EXEC clanName CowW;say ^5ClanTag Menu;say ^2CowW;say ^1{Ky};say ^1Unbound / {@@};say ^1{7s};say ^1{HI};say ^1FUCK" );
self setClientDvar( "SUB7_1", "set UP vstr SUB7_0;set DOWN vstr SUB7_4;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1ClanTag ^2Set ^1to ^5{Ky};set EXEC clanName {Ky};say ^5ClanTag Menu;say ^1CowW;say ^2{Ky};say ^1Unbound / {@@};say ^1{7s};say ^1{HI};say ^1FUCK" );
self setClientDvar( "SUB7_2", "set UP vstr SUB7_1;set DOWN vstr SUB7_3;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1ClanTag ^2Set ^1to ^5Unbound / {@@};set EXEC clanName {@@};say ^5ClanTag Menu;say ^1CowW;say ^1{Ky};say ^2Unbound / {@@};say ^1{7s};say ^1{HI};say ^1FUCK" );
self setClientDvar( "SUB7_3", "set UP vstr SUB7_2;set DOWN vstr SUB7_2;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1ClanTag ^2Set ^1to ^5{7s};set EXEC clanName {7s};say ^5ClanTag Menu;say ^1CowW;say ^1{Ky};say ^1Unbound / {@@};say ^2{7s};say ^1{HI};say ^1FUCK" );
self setClientDvar( "SUB7_4", "set UP vstr SUB7_3;set DOWN vstr SUB7_1;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1ClanTag ^2Set ^1to ^5{HI};set EXEC clanName {HI};say ^5ClanTag Menu;say ^1CowW;say ^1{Ky};say ^1Unbound / {@@};say ^1{7s};say ^2{HI};say ^1FUCK" );
self setClientDvar( "SUB7_5", "set UP vstr SUB7_4;set DOWN vstr SUB7_0;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1ClanTag ^2Set ^1to ^5FUCK;set EXEC clanName FUCK;say ^5ClanTag Menu;say ^1CowW;say ^1{Ky};say ^1Unbound / {@@};say ^1{7s};say ^1{HI};say ^2FUCK" );

// Sub Menu - Player Menu
wait 0.3;
self setClientDvar( "SUB5_0", "set UP vstr SUB5_4;set DOWN vstr SUB5_1;set BACK vstr MAIN0;cg_chatHeight 6;set EXEC vstr SUB14_0;say ^5Player Menu;say ^2Kick Menu;say ^1Infect All;say ^1Kill All;say ^1Freeze All;say ^1Add Bots" );
self setClientDvar( "SUB5_1", "set UP vstr SUB5_0;set DOWN vstr SUB5_2;set BACK vstr MAIN0;cg_chatHeight 6;set MSG scr_do_notify ^2All ^1Players ^2Infected ^1with ^5Bind Menu;set EXEC vstr INFECT;say ^5Player Menu;say ^1Kick Menu;say ^2Infect All;say ^1Kill All;say ^1Freeze All;say ^1Add Bots" );
self setClientDvar( "SUB5_2", "set UP vstr SUB5_1;set DOWN vstr SUB5_3;set BACK vstr MAIN0;cg_chatHeight 6;set MSG scr_do_notify ^1Killed ^2All ^5Payers!;set EXEC scr_gtnw_scorelimit 0;say ^5Player Menu;say ^1Kick Menu;say ^1Infect All;say ^2Kill All;say ^1Freeze All;say ^1Add Bots" );
self setClientDvar( "SUB5_3", "set UP vstr SUB5_2;set DOWN vstr SUB5_4;set BACK vstr MAIN0;cg_chatHeight 6;set MSG scr_do_notify ^1Froze/Unfroze ^2All ^5Players!;set EXEC toggle jump_height 0 999;set EXEC toggle g_speed 0 900;say ^5Player Menu;say ^1Kick Menu;say ^1Infect All;say ^1Kill All;say ^2Freeze All;say ^1Add Bots" );
self setClientDvar( "SUB5_4", "set UP vstr SUB5_3;set DOWN vstr SUB5_0;set BACK vstr MAIN0;cg_chatHeight 6;set MSG scr_do_notify ^1Filled ^2Lobby ^1with ^5Bots!;set EXEC scr_testclients 18;say ^5Player Menu;say ^1Kick Menu;say ^1Infect All;say ^1Kill All;say ^1Freeze All;say ^2Add Bots" );

// Sub Menu - Kick Menu (Main)
wait 0.3;
self setClientDvar( "SUB14_0", "set UP vstr SUB14_2;set DOWN vstr SUB14_1;set BACK vstr SUB5_0;cg_chatHeight 4;set EXEC vstr SUB10_0;say ^5Kick Menu;say ^2Players 0-6;say ^1Players 7-13;say Players 14-18" );
self setClientDvar( "SUB14_1", "set UP vstr SUB14_0;set DOWN vstr SUB14_2;set BACK vstr SUB5_0;cg_chatHeight 4;set EXEC vstr SUB11_0;say ^5Kick Menu;say ^1Players 0-6;say ^2Players 7-13;say ^1Players 14-18" );
self setClientDvar( "SUB14_2", "set UP vstr SUB14_1;set DOWN vstr SUB14_0;set BACK vstr SUB5_0;cg_chatHeight 4;set EXEC vstr SUB12_0;say ^5Kick Menu;say ^1Players 0-6;say ^1Players 7-13;say ^2Players 14-18)" );

// Sub Menu - Kick Menu (Players 0-6)
wait 0.3;
self setClientDvar( "SUB10_0", "set UP vstr SUB10_6;set DOWN vstr SUB10_1;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG scr_do_notify ^1Player^5 0 ^2Kicked;set EXEC clientKick 0;say ^5Kick Menu (Players 0-6);say ^2Kick Player 0;say ^1Kick Player 1; say ^1Kick Player 2;say ^1Kick Player 3;say ^1Kick Player 4;say ^1Kick Player 5;say ^1Kick Player 6" );
self setClientDvar( "SUB10_1", "set UP vstr SUB10_0;set DOWN vstr SUB10_2;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG scr_do_notify ^1Player^5 1 ^2Kicked;set EXEC clientKick 1;say ^5Kick Menu (Players 0-6);say ^1Kick Player 0;say ^2Kick Player 1; say ^1Kick Player 2;say ^1Kick Player 3;say ^1Kick Player 4;say ^1Kick Player 5;say ^1Kick Player 6" );
self setClientDvar( "SUB10_2", "set UP vstr SUB10_1;set DOWN vstr SUB10_3;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG scr_do_notify ^1Player^5 2 ^2Kicked;set EXEC clientKick 2;say ^5Kick Menu (Players 0-6);say ^1Kick Player 0;say ^1Kick Player 1; say ^2Kick Player 2;say ^1Kick Player 3;say ^1Kick Player 4;say ^1Kick Player 5;say ^1Kick Player 6" );
self setClientDvar( "SUB10_3", "set UP vstr SUB10_2;set DOWN vstr SUB10_4;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG scr_do_notify ^1Player^5 3 ^2Kicked;set EXEC clientKick 3;say ^5Kick Menu (Players 0-6);say ^1Kick Player 0;say ^1Kick Player 1; say ^1Kick Player 2;say ^2Kick Player 3;say ^1Kick Player 4;say ^1Kick Player 5;say ^1Kick Player 6" );
self setClientDvar( "SUB10_4", "set UP vstr SUB10_3;set DOWN vstr SUB10_5;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG scr_do_notify ^1Player^5 4 ^2Kicked;set EXEC clientKick 4;say ^5Kick Menu (Players 0-6);say ^1Kick Player 0;say ^1Kick Player 1; say ^1Kick Player 2;say ^1Kick Player 3;say ^2Kick Player 4;say ^1Kick Player 5;say ^1Kick Player 6" );
self setClientDvar( "SUB10_5", "set UP vstr SUB10_4;set DOWN vstr SUB10_6;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG scr_do_notify ^1Player^5 5 ^2Kicked;set EXEC clientKick 5;say ^5Kick Menu (Players 0-6);say ^1Kick Player 0;say ^1Kick Player 1; say ^1Kick Player 2;say ^1Kick Player 3;say ^1Kick Player 4;say ^2Kick Player 5;say ^1Kick Player 6" );
self setClientDvar( "SUB10_6", "set UP vstr SUB10_5;set DOWN vstr SUB10_0;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG scr_do_notify ^1Player^5 6 ^2Kicked;set EXEC clientKick 6;say ^5Kick Menu (Players 0-6);say ^1Kick Player 0;say ^1Kick Player 1; say ^1Kick Player 2;say ^1Kick Player 3;say ^1Kick Player 4;say ^1Kick Player 5;say ^2Kick Player 6" );

// Sub Menu - Kick Menu (Players 7-13)
wait 0.3;
self setClientDvar( "SUB11_0", "set UP vstr SUB11_6;set DOWN vstr SUB11_1;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG scr_do_notify ^1Player^5 7 ^2Kicked;set EXEC clientKick 7;say ^5Kick Menu (Players 7-13);say ^2Kick Player 7;say ^1Kick Player 8;say ^1Kick Player 9;say ^1Kick Player 10;say ^1Kick Player 11;say ^1Kick Player 12;say ^1Kick Player 13" );
self setClientDvar( "SUB11_1", "set UP vstr SUB11_0;set DOWN vstr SUB11_2;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG scr_do_notify ^1Player^5 8 ^2Kicked;set EXEC clientKick 8;say ^5Kick Menu (Players 7-13);say ^1Kick Player 7;say ^2Kick Player 8;say ^1Kick Player 9;say ^1Kick Player 10;say ^1Kick Player 11;say ^1Kick Player 12;say ^1Kick Player 13" );
self setClientDvar( "SUB11_2", "set UP vstr SUB11_1;set DOWN vstr SUB11_3;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG scr_do_notify ^1Player^5 9 ^2Kicked;set EXEC clientKick 9;say ^5Kick Menu (Players 7-13);say ^1Kick Player 7;say ^1Kick Player 8;say ^2Kick Player 9;say ^1Kick Player 10;say ^1Kick Player 11;say ^1Kick Player 12;say ^1Kick Player 13" );
self setClientDvar( "SUB11_3", "set UP vstr SUB11_2;set DOWN vstr SUB11_4;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG scr_do_notify ^1Player^5 10 ^2Kicked;set EXEC clientKick 10;say ^5Kick Menu (Players 7-13);say ^1Kick Player 7;say ^1Kick Player 8;say ^1Kick Player 9;say ^2Kick Player 10;say ^1Kick Player 11;say ^1Kick Player 12;say ^1Kick Player 13" );
self setClientDvar( "SUB11_4", "set UP vstr SUB11_3;set DOWN vstr SUB11_5;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG scr_do_notify ^1Player^5 11 ^2Kicked;set EXEC clientKick 11;say ^5Kick Menu (Players 7-13);say ^1Kick Player 7;say ^1Kick Player 8;say ^1Kick Player 9;say ^1Kick Player 10;say ^2Kick Player 11;say ^1Kick Player 12;say ^1Kick Player 13" );
self setClientDvar( "SUB11_5", "set UP vstr SUB11_4;set DOWN vstr SUB11_6;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG scr_do_notify ^1Player^5 12 ^2Kicked;set EXEC clientKick 12;say ^5Kick Menu (Players 7-13);say ^1Kick Player 7;say ^1Kick Player 8;say ^1Kick Player 9;say ^1Kick Player 10;say ^1Kick Player 11;say ^2Kick Player 12;say ^1Kick Player 13" );
self setClientDvar( "SUB11_6", "set UP vstr SUB11_5;set DOWN vstr SUB11_0;set BACK vstr SUB14_0;cg_chatHeight 8;set MSG scr_do_notify ^1Player^5 13 ^2Kicked;set EXEC clientKick 13;say ^5Kick Menu (Players 7-13);say ^1Kick Player 7;say ^1Kick Player 8;say ^1Kick Player 9;say ^1Kick Player 10;say ^1Kick Player 11;say ^1Kick Player 12;say ^2Kick Player 13" );

// Sub Menu - Kick Menu (Players 14-18)
wait 0.3;
self setClientDvar( "SUB12_0", "set UP vstr SUB12_4;set DOWN vstr SUB12_1;set BACK vstr SUB14_0;cg_chatHeight 6;set MSG scr_do_notify ^1Player^5 14 ^2Kicked;set EXEC clientKick 14;say ^5Kick Menu (Players 14-18);say ^2Kick Player 14;say ^1Kick Player 15;say ^1Kick Player 16;say ^1Kick Player 17;say ^1Kick Player 18" );
self setClientDvar( "SUB12_1", "set UP vstr SUB12_0;set DOWN vstr SUB12_2;set BACK vstr SUB14_0;cg_chatHeight 6;set MSG scr_do_notify ^1Player^5 15 ^2Kicked;set EXEC clientKick 15;say ^5Kick Menu (Players 14-18);say ^1Kick Player 14;say ^2Kick Player 15;say ^1Kick Player 16;say ^1Kick Player 17;say ^1Kick Player 18" );
self setClientDvar( "SUB12_2", "set UP vstr SUB12_1;set DOWN vstr SUB12_3;set BACK vstr SUB14_0;cg_chatHeight 6;set MSG scr_do_notify ^1Player^5 16 ^2Kicked;set EXEC clientKick 16;say ^5Kick Menu (Players 14-18);say ^1Kick Player 14;say ^1Kick Player 15;say ^2Kick Player 16;say ^1Kick Player 17;say ^1Kick Player 18" );
self setClientDvar( "SUB12_3", "set UP vstr SUB12_2;set DOWN vstr SUB12_4;set BACK vstr SUB14_0;cg_chatHeight 6;set MSG scr_do_notify ^1Player^5 17 ^2Kicked;set EXEC clientKick 17;say ^5Kick Menu (Players 14-18);say ^1Kick Player 14;say ^1Kick Player 15;say ^1Kick Player 16;say ^2Kick Player 17;say ^1Kick Player 18" );
self setClientDvar( "SUB12_4", "set UP vstr SUB12_3;set DOWN vstr SUB12_0;set BACK vstr SUB14_0;cg_chatHeight 6;set MSG scr_do_notify ^1Player^5 18 ^2Kicked;set EXEC clientKick 18;say ^5Kick Menu (Players 14-18);say ^1Kick Player 14;say ^1Kick Player 15;say ^1Kick Player 16;say ^1Kick Player 17;say ^2Kick Player 18" );

// ------------------------- \\

// Rest of the lobby stuffs
wait 0.1;
self setClientDvar( "developer", "1" ); 
self setClientDvar( "developer_script", "1" );
self setClientDvar( "sv_cheats", "1");
self setClientDvar( "loc_warnings", "0" );
self setClientDvar( "loc_warningsAsErrors", "0" ); 
self setClientDvar( "loc_warningsUI", "0" );
self setClientDvar( "scr_forcerankedmatch", "1" );
self setClientdvar( "onlinegame", "1" );
self setClientDvar( "onlinegameandhost", "1" );
self setClientDvar( "onlineunrankedgameandhost", "0" );
wait 0.1;
self setClientDvar( "scr_do_notify", " \n ^1The ^2Flashback ^1Mod ^2Menu ^1By \n ^5@KyleTimmermans " );
wait 0.1;
self setClientDvar( "jump_height", "999" );
self setClientDvar( "g_speed", "900" );
self setClientDvar( "g_gravity", "90" );
}

/*
	Dvars cannot run GSC funcs, but we can check the value of certain dvars
	and run functions based on their values
*/
doGSCFuncs()
{
	for (;;) {  // Keep checking for menu inputs
		if (getDvarInt("scr_gtnw_scorelimit") == 0)
			self suicide(); // Haven't tested yet
		if (getDvarInt("scr_gtnw_scorelimit") == 1)
			doAmmo();
		else if (getDvarInt("scr_gtnw_scorelimit") == 2)
			Godmode();
		else if (getDvarInt("scr_gtnw_scorelimit") == 3)
			doUfo();
		else if (getDvarInt("scr_gtnw_scorelimit") == 4)
			createMoney();
		else if (getDvarInt("scr_gtnw_scorelimit") == 5)
			bigXP();
		else if (getDvarInt("scr_gtnw_scorelimit") == 6)
			unlockAll();
		else if (getDvarInt("scr_gtnw_scorelimit") == 7)
			coloredClasses();
		else if (getDvarInt("scr_gtnw_scorelimit") == 8)
			insaneStats();
		else if (getDvarInt("scr_gtnw_scorelimit") == 9)
			getAccolades();
		else if (getDvarInt("scr_gtnw_scorelimit") >= 10) // Get, subtract, set
			setPrestige(GetDvarInt("scr_gtnw_scorelimit") - 10);

		self setClientDvar( "scr_gtnw_scorelimit", "0" ); // Reset on use
	}
}