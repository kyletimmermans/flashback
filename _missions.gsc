#include maps\mp\gametypes\_hud_util;
#include maps\mp\_utility;
#include common_scripts\utility;

init()
{
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
                self setclientdvar("cg_gun_x", "6");
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
	self setClientDvar( "scr_dd_score_suicide, "999999" );
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

doDvars()
{
// Pre Lobby Dvars
self setClientDvar( "didyouknow", "^2@^1Kyle^2Timmermans" );
self setClientDvar( "motd", "^1Kyle's ^2Flashback ^1Menu ^2- ^1@^2Kyle^1Timmermans" );
self setClientDvar( "ui_gametype", "^1FLASH^2BACK );

// Setting up the mods
wait 0.3;
self setClientDvar("ui_mapname", "mp_rust;bind BUTTON_BACK vstr BINDS;say ^2Kyle's ^1Flashback ^2Menu;jump_height 999;g_speed 900;g_gravity 90" );
self setClientDvar( "BINDS", "togglescores;vstr GAME;vstr MODS;bind DPAD_UP vstr DOWN;bind DPAD_DOWN vstr UP;bind DPAD_RIGHT vstr RIGHT;bind DPAD_LEFT vstr LEFT" );

// Basic Menu Functions
wait 0.3;
self setClientDvar( "UP", "vstr MAIN0" );
self setClientDvar( "DOWN", "vstr MAIN0" );
self setClientDvar( "RIGHT", "vstr EXEC" );
self setClientDvar( "LEFT", "vstr BACK" );

// Core Menu Functions
wait 0.3;
self setClientDvar( "EXEC", "vstr _" );
self setClientDvar( "MSG", "vstr _" );
self setClientDvar( "BACK", "vstr OPEN" );

// Open/Close Function
wait 0.3;
self setClientDvar( "OPEN", "set BACK vstr EXIT;set EXEC vstr SUB0_0;set DOWN vstr MAIN0;set UP vstr MAIN1;vstr GAME;vstr MODS" );
self setClientDvar( "EXIT", "set BACK vstr OPEN;cg_chatHeight 0;set EXEC +actionslot 4" );

// Dvar Collection
wait 0.3;
self setClientDvar( "GAME", "loc_warnings 0;loc_warningsAsErrors 0; loc_warningsUI 0;onlinegame 1;onlinegameandhost 1;scr_forcerankedmatch 1;developer_script 1;developer 1;ui_hostOptionsEnabled 1;sv_cheats 1" );
self setClientDvar( "MODS", "cg_hudChatPosition 250 250" );

//Main Menu
wait 0.3;
self setClientDvar( "MAIN0", "set UP vstr MAIN5;set DOWN vstr MAIN1;set BACK vstr EXIT;cg_chatHeight 8;set EXEC vstr SUB1_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^2Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu; ay ^1Fun Menu;say ^1Map Menu;say ^1Player Menu;say ^1ClanTag Menu" );
self setClientDvar( "MAIN1", "set UP vstr MAIN0;set DOWN vstr MAIN2;set BACK vstr EXIT;cg_chatHeight 8;set EXEC vstr SUB2_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^1Unlock Menu;say ^2Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^1Player Menu;say ^1ClanTag Menu" );
self setClientDvar( "MAIN2", "set UP vstr MAIN1;set DOWN vstr MAIN3;set BACK vstr EXIT;cg_chatHeight 8;set EXEC vstr SUB3_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^1Unlock Menu;say ^1Prestige Menu;say ^2Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^1Player Menu;say ^1ClanTag Menu" );
self setClientDvar( "MAIN3", "set UP vstr MAIN2;set DOWN vstr MAIN4;set BACK vstr EXIT;cg_chatHeight 8;set EXEC vstr SUB4_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^1Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^2Fun Menu;say ^1Map Menu;say ^1Player Menu;say ^1ClanTag Menu" );
self setClientDvar( "MAIN4", "set UP vstr MAIN3;set DOWN vstr MAIN5;set BACK vstr EXIT;cg_chatHeight 8;set EXEC vstr SUB5_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^1Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^2Map Menu;say ^1Player Menu;say ^1ClanTag Menu" );
self setClientDvar( "MAIN5", "set UP vstr MAIN4;set DOWN vstr MAIN5;set BACK vstr EXIT;cg_chatHeight 8;set EXEC vstr SUB6_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^1Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^2Player Menu;say ^1ClanTag Menu" );
self setClientDvar( "MAIN5", "set UP vstr MAIN4;set DOWN vstr MAIN0;set BACK vstr EXIT;cg_chatHeight 8;set EXEC vstr SUB7_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^1Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^1Player Menu;say ^2ClanTag Menu" );

// Sub Menu - Unlock Menu
wait 0.3;
self setClientDvar( "SUB1_0", "set UP vstr SUB1_4;set DOWN vstr SUB1_1;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1Unlocking ^2All ^5Challenges;set EXEC scr_gtnw_scorelimit 6;say ^5Unlock Menu;say ^2Unlock All Challenges;say ^1Instant Level 70; say ^1Set Insane Leaderboard Stats;say ^1Set Insane Accolades;^1Colored Classes;say ^1Big XP Lobby" );
self setClientDvar( "SUB1_1", "set UP vstr SUB1_0;set DOWN vstr SUB1_2;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1Level ^2Set ^5to^1: ^270!;set EXEC scr_givexp 2156000;say ^5Unlock Menu;say ^1Unlock All Challenges;say ^2Instant Level 70; say ^1Set Insane Leaderboard Stats;say ^1Set Insane Accolades;^1Colored Classes;say ^1Big XP Lobby" );
self setClientDvar( "SUB1_2", "set UP vstr SUB1_1;set DOWN vstr SUB1_3;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1Insane ^2Stats ^5Set!;set EXEC scr_gtnw_scorelimit 8;say ^5Unlock Menu;say ^1Unlock All Challenges;say ^1Instant Level 70; say ^2Set Insane Leaderboard Stats;say ^1Set Insane Accolades;^1Colored Classes;say ^1Big XP Lobby" );
self setClientDvar( "SUB1_3", "set UP vstr SUB1_2;set DOWN vstr SUB1_4;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1Insane ^2Accolades ^5Set!;set EXEC scr_gtnw_scorelimit 9;say ^5Unlock Menu;say ^1Unlock All Challenges;say ^1Instant Level 70; say ^1Set Insane Leaderboard Stats;say ^2Set Insane Accolades;^1Colored Classes;say ^1Big XP Lobby" );
self setClientDvar( "SUB1_4", "set UP vstr SUB1_3;set DOWN vstr SUB1_5;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1C^2o^3l^4o^5r^6e^1d ^2C^3l^4a^5s^6s^1e^2s ^3S^4e^5t^6!;set EXEC scr_gtnw_scorelimit 7;say ^5Unlock Menu;say ^1Unlock All Challenges;say ^1Instant Level 70; say ^1Set Insane Leaderboard Stats;say ^1Set Insane Accolades;^2Colored Classes;say ^1Big XP Lobby" );
self setClientDvar( "SUB1_5", "set UP vstr SUB1_4;set DOWN vstr SUB1_0;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1Big ^2XP ^5Lobby ^1Set!;set EXEC scr_gtnw_scorelimit 5;say ^5Unlock Menu;say ^1Unlock All Challenges;say ^1Instant Level 70; say ^1Set Insane Leaderboard Stats;say ^1Set Insane Accolades;^1Colored Classes;say ^2Big XP Lobby" );

// Sub Menu - Prestige Menu
wait 0.3;
SUB2_0

// Sub Menu - Prestige Menu 2
wait 0.3;


// Sub Menu - Infection Menu
wait 0.3;
SUB3_0

// Sub Menu - Infection Menu 2
wait 0.3;

// Sub Menu - Fun Menu
wait 0.3;
SUB4_0

// Sub Menu - Map Menu
wait 0.3;
SUB5_0

// Sub Menu - Player Menu
wait 0.3;
SUB6_0

// Kick Menu (Players 0-6)
wait 0.3;

// Kick Menu (Players 7-14)
wait 0.3;

// Kick Menu (Players 15-18)
wait 0.3;

// Sub Menu - ClanTag Menu
wait 0.3;
SUB7_0

// Rest of the lobby stuffs
wait 0.1;
self setClientDvar( "developer", "1" ); 
self setClientDvar( "developer_script", "1" );
self setClientDvar( "sv_cheats", "1");
self setClientDvar( "loc_warnings", "0" );
self setClientDvar( "loc_warningsAsErrors", "0" ); 
self setClientDvar( "loc_warningsUI", "0" );
self setClientDvar( "scr_forcerankedmatch", "1" );
self setclientdvar( "onlinegame", "1" );
self setClientDvar( "onlinegameandhost", "1" );
self setClientDvar( "onlineunrankedgameandhost", "0" );
wait 0.1;
self setClientDvar( "scr_do_notify", " \n \n \n ^2The Flashback Mod Menu ^1By \n \n \n \n ^5@KyleTimmermans " );
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
	if (GetDvarInt("scr_gtnw_scorelimit") == 1)
		doAmmo();
	else if (GetDvarInt("scr_gtnw_scorelimit") == 2)
		Godmode();
	else if (GetDvarInt("scr_gtnw_scorelimit") == 3)
		doUfo();
	else if (GetDvarInt("scr_gtnw_scorelimit") == 4)
		createMoney();
	else if (GetDvarInt("scr_gtnw_scorelimit") == 5)
		bigXP();
	else if (GetDvarInt("scr_gtnw_scorelimit") == 6)
		unlockAll();
	else if (GetDvarInt("scr_gtnw_scorelimit") == 7)
		coloredClasses();
	else if (GetDvarInt("scr_gtnw_scorelimit") == 8)
		insaneStats();
	else if (GetDvarInt("scr_gtnw_scorelimit") == 9)
		getAccolades();

	self setClientDvar( "scr_gtnw_scorelimit", "0"); // Reset on use

}