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

// Basic Menu Functions
wait 0.3;
self setClientDvar( "UP", "vstr MAIN0" );
self setClientDvar( "RIGHT", "vstr MSG;vstr EXEC" ); // MSG needed here?
self setClientDvar( "LEFT", "vstr BACK" );

// Core Menu Functions
wait 0.3;
self setClientDvar( "EXEC", "vstr _" );
self setClientDvar( "MSG", "vstr _" );
self setClientDvar( "BACK", "vstr OPEN" );;

// Open/Close Function
wait 0.3;
self setClientDvar( "OPEN", "set BACK vstr EXIT;set EXEC vstr MAIN0;set UP vstr MAIN0;vstr GAME;vstr MODS" );
self setClientDvar( "EXIT", "set BACK vstr OPEN;cg_chatHeight 0;set EXEC +actionslot 4" );

// Dvar Collection
wait 0.3;
self setClientDvar( "GAME", "loc_warnings 0;loc_warningsAsErrors 0; loc_warningsUI 0;onlinegame 1;onlinegameandhost 1;scr_forcerankedmatch 1;developer_script 1;developer 1;ui_hostOptionsEnabled 1;sv_cheats 1" );
self setClientDvar( "MODS", "cg_hudChatPosition 250 250" );

// ------------------------- \\

//Main Menu
wait 0.3;
self setClientDvar( "MAIN0", "set UP vstr MAIN6;set DOWN vstr MAIN1;set BACK vstr EXIT;cg_chatHeight 8;set EXEC vstr SUB1_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^2Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^1Player Menu;say ^1ClanTag Menu" );
self setClientDvar( "MAIN1", "set UP vstr MAIN0;set DOWN vstr MAIN2;set BACK vstr EXIT;cg_chatHeight 8;set EXEC vstr SUB2_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^1Unlock Menu;say ^2Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^1Player Menu;say ^1ClanTag Menu" );
self setClientDvar( "MAIN2", "set UP vstr MAIN1;set DOWN vstr MAIN3;set BACK vstr EXIT;cg_chatHeight 8;set EXEC vstr SUB3_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^1Unlock Menu;say ^1Prestige Menu;say ^2Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^1Player Menu;say ^1ClanTag Menu" );
self setClientDvar( "MAIN3", "set UP vstr MAIN2;set DOWN vstr MAIN4;set BACK vstr EXIT;cg_chatHeight 8;set EXEC vstr SUB4_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^1Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^2Fun Menu;say ^1Map Menu;say ^1Player Menu;say ^1ClanTag Menu" );
self setClientDvar( "MAIN4", "set UP vstr MAIN3;set DOWN vstr MAIN5;set BACK vstr EXIT;cg_chatHeight 8;set EXEC vstr SUB5_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^1Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^2Map Menu;say ^1Player Menu;say ^1ClanTag Menu" );
self setClientDvar( "MAIN5", "set UP vstr MAIN4;set DOWN vstr MAIN6;set BACK vstr EXIT;cg_chatHeight 8;set EXEC vstr SUB6_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^1Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^2Player Menu;say ^1ClanTag Menu" );
self setClientDvar( "MAIN6", "set UP vstr MAIN5;set DOWN vstr MAIN0;set BACK vstr EXIT;cg_chatHeight 8;set EXEC vstr SUB7_0;say ^1K^2y^3l^4e^5'^6s ^1F^2l^3a^4s^5h^6b^1a^2c^3k ^4M^5e^6n^1u ^2v^31^4.^50;say ^1Unlock Menu;say ^1Prestige Menu;say ^1Infection Menu;say ^1Fun Menu;say ^1Map Menu;say ^1Player Menu;say ^2ClanTag Menu" );

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
// SUB3_0

// Sub Menu - Infection Menu 2
wait 0.3;
// SUB9_0

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

// Sub Menu - Player Menu
wait 0.3;
self setClientDvar( "SUB5_0", "set UP vstr SUB5_3;set DOWN vstr SUB5_1;set BACK vstr MAIN0;cg_chatHeight 5;set EXEC vstr SUB10_0;say ^5Player Menu;say ^2Kick Menu;say ^1Kill All;say ^1Freeze All;say ^1Add Bots" );
self setClientDvar( "SUB5_1", "set UP vstr SUB5_0;set DOWN vstr SUB5_2;set BACK vstr MAIN0;cg_chatHeight 5;set MSG scr_do_notify ^1Killed ^2All ^5Payers!;set EXEC ;say ^5Player Menu;say ^1Kick Menu;say ^2Kill All;say ^1Freeze All;say ^1Add Bots" );
self setClientDvar( "SUB5_2", "set UP vstr SUB5_1;set DOWN vstr SUB5_3;set BACK vstr MAIN0;cg_chatHeight 5;set MSG scr_do_notify ^1Froze/Unfroze ^2All ^5Players!;set EXEC toggle jump_height 0 999;set EXEC toggle g_speed 0 900;say ^5Player Menu;say ^1Kick Menu;say ^1Kill All;say ^2Freeze All;say ^1Add Bots" );
self setClientDvar( "SUB5_3", "set UP vstr SUB5_2;set DOWN vstr SUB5_0;set BACK vstr MAIN0;cg_chatHeight 5;set MSG scr_do_notify ^1Filled ^2Lobby ^1with ^5Bots!;set EXEC scr_testclients 18;say ^5Player Menu;say ^1Kick Menu;say ^1Kill All;say ^1Freeze All;say ^2Add Bots" );

// Kick Menu (Players 0-6)
wait 0.3;
// SUB10_0

// Kick Menu (Players 7-14)
wait 0.3;
// SUB11_0

// Kick Menu (Players 15-18)
wait 0.3;
// SUB12_0

// Sub Menu - ClanTag Menu
wait 0.3;
self setClientDvar( "SUB7_0", "set UP vstr SUB7_5;set DOWN vstr SUB7_5;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1ClanTag ^2Set ^1to ^5CowW;set EXEC clanName CowW;say ^5ClanTag Menu;say ^2CowW;say ^1{Ky};say ^1Unbound / {@@};say ^1{7s};say ^1{HI};say ^1FUCK" );
self setClientDvar( "SUB7_1", "set UP vstr SUB7_0;set DOWN vstr SUB7_4;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1ClanTag ^2Set ^1to ^5{Ky};set EXEC clanName {Ky};say ^5ClanTag Menu;say ^1CowW;say ^2{Ky};say ^1Unbound / {@@};say ^1{7s};say ^1{HI};say ^1FUCK" );
self setClientDvar( "SUB7_2", "set UP vstr SUB7_1;set DOWN vstr SUB7_3;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1ClanTag ^2Set ^1to ^5Unbound / {@@};set EXEC clanName {@@};say ^5ClanTag Menu;say ^1CowW;say ^1{Ky};say ^2Unbound / {@@};say ^1{7s};say ^1{HI};say ^1FUCK" );
self setClientDvar( "SUB7_3", "set UP vstr SUB7_2;set DOWN vstr SUB7_2;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1ClanTag ^2Set ^1to ^5{7s};set EXEC clanName {7s};say ^5ClanTag Menu;say ^1CowW;say ^1{Ky};say ^1Unbound / {@@};say ^2{7s};say ^1{HI};say ^1FUCK" );
self setClientDvar( "SUB7_4", "set UP vstr SUB7_3;set DOWN vstr SUB7_1;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1ClanTag ^2Set ^1to ^5{HI};set EXEC clanName {HI};say ^5ClanTag Menu;say ^1CowW;say ^1{Ky};say ^1Unbound / {@@};say ^1{7s};say ^2{HI};say ^1FUCK" );
self setClientDvar( "SUB7_5", "set UP vstr SUB7_4;set DOWN vstr SUB7_0;set BACK vstr MAIN0;cg_chatHeight 7;set MSG scr_do_notify ^1ClanTag ^2Set ^1to ^5FUCK;set EXEC clanName FUCK;say ^5ClanTag Menu;say ^1CowW;say ^1{Ky};say ^1Unbound / {@@};say ^1{7s};say ^1{HI};say ^2FUCK" );

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
