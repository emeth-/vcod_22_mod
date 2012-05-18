

Callback_StartGameType()
{
	// Set up variables
	setupVariables();

	// Find map limits
	findmapdimensions();

	// Find play area by checking all the spawnpoints
	findPlayArea();

	// Show AWE logo under compass
	showlogo();

	// Precache
	if(!isdefined(game["gamestarted"]))
		doPrecaching();

	// Warm up round
	warmupround();

	// Start threads
	startThreads();
}

startThreads()
{
	level notify("awe_boot");

	// Override fog settings
	overridefog();

	// Start Ravirs admin tools
	thread maps\mp\gametypes\_user_Ravir_admin::main();


	
	// Stukas
	if(level.awe_stukas)
		thread stukas();
	
	// Bombers
      if(level.awe_bombers) {
		// Calculate start positions for C47 planes
		iX = (int)(level.awe_vMax[0] + level.awe_vMin[0])/2;
	
		if(level.awe_bombers_distance)
			iY = level.awe_bombers_distance;
		else
			iY = level.awe_vMin[1];	
	
		if(level.awe_bombers_altitude)
			iZ = level.awe_bombers_altitude;
		else
			iZ = level.awe_vMax[2];	
	
		// Loop effect
		maps\mp\_fx::loopfx("bombers", (iX - 500, iY, iZ), level.awe_bombers_delay);
		thread C47sounds( (iX - 500, iY, iZ), level.awe_bombers_delay);
		maps\mp\_fx::loopfx("bombers", (iX + 500, iY, iZ), level.awe_bombers_delay + 10);
		thread C47sounds( (iX + 500, iY, iZ), level.awe_bombers_delay + 10);

      }	
	
	//Ambient tracers
	if(level.awe_tracers)
		for(i = 0; i < level.awe_tracers; i++)
			thread tracers();
	
	// Ambient sky flashes
	if(level.awe_skyflashes)
		for(i = 0; i < level.awe_skyflashes; i++)
			thread skyflashes();

	// Do maprotation randomization
	thread randomMapRotation();

	// Announce next map and display server messages
	if(!level.awe_messageindividual)
		thread serverMessages();

	// Setup turrets
	thread turretStuff();

	// Rain/snow
	if(isdefined(level.awe_rainfx))
		thread rain();

	// Bots
	thread addBotClients();

	// Start thread for updating variables from cvars
	thread updateGametypeCvars(false);
}

setupVariables()
{
	// defaults if not defined in level script
	if(!isDefined(game["allies"]))
		game["allies"] = "american";
	if(!isDefined(game["axis"]))
		game["axis"] = "german";

	// Set up the number of available punishments
	level.awe_punishments = 3;

	// Setup variables depending on gametypes
	switch(getCvar("g_gametype"))
	{
		// Demolition
		case "dem":
			level.awe_teamplay = true;
			level.awe_roundbased = true;
			level.awe_demolition = true;
			level.awe_spawnalliedname = "mp_searchanddestroy_spawn_allied";
			level.awe_spawnaxisname	= "mp_searchanddestroy_spawn_axis";
			break;
		case "mc_dem":
			level.awe_teamplay = true;
			level.awe_roundbased = true;
			level.awe_demolition = true;
			level.awe_merciless = true;
			level.awe_spawnalliedname = "mp_searchanddestroy_spawn_allied";
			level.awe_spawnaxisname	= "mp_searchanddestroy_spawn_axis";
			break;

		case "dm":
			level.awe_spawnalliedname = "mp_deathmatch_spawn";
			level.awe_spawnaxisname = "mp_deathmatch_spawn";
			break;
		case "sdm":
			level.awe_spawnalliedname = "mp_deathmatch_spawn";
			level.awe_spawnaxisname = "mp_deathmatch_spawn";
			break;
		case "mc_dm":
			level.awe_merciless = true;
			level.awe_spawnalliedname = "mp_deathmatch_spawn";
			level.awe_spawnaxisname = "mp_deathmatch_spawn";
			break;

		case "re":
		case "gen":
			level.awe_teamplay = true;
			level.awe_roundbased = true;
			level.awe_spawnalliedname = "mp_retrieval_spawn_allied";
			level.awe_spawnaxisname = "mp_retrieval_spawn_axis";
			break;
		case "mc_re":
			level.awe_teamplay = true;
			level.awe_roundbased = true;
			level.awe_merciless = true;
			level.awe_spawnalliedname = "mp_retrieval_spawn_allied";
			level.awe_spawnaxisname = "mp_retrieval_spawn_axis";
			break;

		case "rsd":
			level.awe_teamplay = true;
			level.awe_roundbased = true;
			level.awe_spawnalliedname = "mp_searchanddestroy_spawn_allied";
			level.awe_spawnaxisname	= "mp_searchanddestroy_spawn_axis";
			level.awe_rsd = true;
			break;
		case "mc_rsd":
			level.awe_teamplay = true;
			level.awe_roundbased = true;
			level.awe_merciless = true;
			level.awe_spawnalliedname = "mp_searchanddestroy_spawn_allied";
			level.awe_spawnaxisname	= "mp_searchanddestroy_spawn_axis";
			level.awe_rsd = true;
			break;

		case "sd":
		case "lts":
			level.awe_teamplay = true;
			level.awe_roundbased = true;
			level.awe_spawnalliedname = "mp_searchanddestroy_spawn_allied";
			level.awe_spawnaxisname	= "mp_searchanddestroy_spawn_axis";
			break;
		case "mc_sd":
		case "mc_lts":
			level.awe_teamplay = true;
			level.awe_roundbased = true;
			level.awe_merciless = true;
			level.awe_spawnalliedname = "mp_searchanddestroy_spawn_allied";
			level.awe_spawnaxisname	= "mp_searchanddestroy_spawn_axis";
			break;
		case "mc_tdom":
			level.awe_teamplay = true;
//			level.awe_roundbased = true;
			level.awe_merciless = true;
			level.awe_classbased = true;
			level.awe_tdom = true;
			level.awe_spawnalliedname = "mp_searchanddestroy_spawn_allied";
			level.awe_spawnaxisname	= "mp_searchanddestroy_spawn_axis";
			break;

		case "ctf":
			level.awe_teamplay = true;
			level.awe_spawnalliedname = "mp_retrieval_spawn_allied";
			level.awe_spawnaxisname	= "mp_retrieval_spawn_axis";
			break;
		case "mc_ctf":
			level.awe_teamplay = true;
			level.awe_merciless = true;
			level.awe_spawnalliedname = "mp_retrieval_spawn_allied";
			level.awe_spawnaxisname	= "mp_retrieval_spawn_axis";
			break;

		case "cnq":
		case "tdm":
		case "bel":
		case "hq":
			level.awe_teamplay = true;
			level.awe_spawnalliedname = "mp_teamdeathmatch_spawn";
			level.awe_spawnaxisname = "mp_teamdeathmatch_spawn";
			break;
		case "mc_cnq":
		case "mc_tdm":
		case "mc_bel":
		case "mc_hq":
			level.awe_teamplay = true;
			level.awe_merciless = true;
			level.awe_spawnalliedname = "mp_teamdeathmatch_spawn";
			level.awe_spawnaxisname = "mp_teamdeathmatch_spawn";
			break;

		default:
			level.awe_teamplay = true;
			level.awe_spawnalliedname = "mp_teamdeathmatch_spawn";
			level.awe_spawnaxisname = "mp_teamdeathmatch_spawn";
			break;
	}

	// Set up number of voices
	level.awe_voices["german"] = 3;
	level.awe_voices["american"] = 7;
	level.awe_voices["russian"] = 6;
	level.awe_voices["british"] = 6;

	// Set up grenade voices
	level.awe_grenadevoices["german"][0]="german_grenade";
	level.awe_grenadevoices["german"][1]="generic_grenadeattack_german_1";
	level.awe_grenadevoices["german"][2]="generic_grenadeattack_german_2";
	level.awe_grenadevoices["german"][3]="generic_grenadeattack_german_3";	

	level.awe_grenadevoices["american"][0]="american_grenade";
	level.awe_grenadevoices["american"][1]="generic_grenadeattack_american_1";
	level.awe_grenadevoices["american"][2]="generic_grenadeattack_american_2";
	level.awe_grenadevoices["american"][3]="generic_grenadeattack_american_3";
	level.awe_grenadevoices["american"][4]="generic_grenadeattack_american_4";
	level.awe_grenadevoices["american"][5]="generic_grenadeattack_american_5";
	level.awe_grenadevoices["american"][6]="generic_grenadeattack_american_6";	

	level.awe_grenadevoices["russian"][0]="russian_grenade";
	level.awe_grenadevoices["russian"][1]="generic_grenadeattack_russian_3";
	level.awe_grenadevoices["russian"][2]="generic_grenadeattack_russian_4";
	level.awe_grenadevoices["russian"][3]="generic_grenadeattack_russian_5";
	level.awe_grenadevoices["russian"][4]="generic_grenadeattack_russian_6";	

	level.awe_grenadevoices["british"][0]="british_grenade";
	level.awe_grenadevoices["british"][1]="generic_grenadeattack_british_1";
	level.awe_grenadevoices["british"][2]="generic_grenadeattack_british_2";
	level.awe_grenadevoices["british"][3]="generic_grenadeattack_british_4";
	level.awe_grenadevoices["british"][4]="generic_grenadeattack_british_5";
	level.awe_grenadevoices["british"][5]="generic_grenadeattack_british_6";	

	// Reserve objective 6 to 15 for all gametypes but BEL and DEM
	if(getCvar("g_gametype") != "bel" && getCvar("g_gametype") != "mc_bel" && !isdefined(level.awe_demolition))
		level.awe_objnum_min = 6;
	else							// Reserve only the last 5 objectives for BEL and DEM
		level.awe_objnum_min = 11;		// (requires modification of bel.gsc)
	level.awe_objnum_cur = level.awe_objnum_min;
	level.awe_objnum_max = 15;

	// Initialize variables from cvars
	updateGametypeCvars(true);	

	if(isdefined(game["german_soldiervariation"]) && game["german_soldiervariation"] == "winter")
		level.awe_wintermap = true;
	overrideteams();

	if(level.awe_spawnprotection && !isdefined(level.awe_demolition))
		game["headicon_protect"] = "gfx/hud/hud@health_cross.tga";

	if( level.awe_anticamptime && !level.awe_anticampmethod && !isdefined(level.awe_tdom) )
	{
		game["headicon_star"]	= "gfx/hud/headicon@re_objcarrier.dds";
		game["objective_default"]="gfx/hud/objective.dds";
	}

	if( isdefined(level.awe_teamplay) && level.awe_anticamptime && !level.awe_anticampmethod && !isdefined(level.awe_tdom) )
	{
		// Precache radio objectives
		game["radio_axis"] = "gfx/hud/hud@objective_german.tga";
		game["headicon_axis"] = "gfx/hud/headicon@german.tga";

		switch(game["allies"])
		{
			case "american":
				game["radio_allies"] = "gfx/hud/hud@objective_american.tga";
				game["headicon_allies"] = "gfx/hud/headicon@american.tga";
				break;
	
			case "british":
				game["radio_allies"] = "gfx/hud/hud@objective_british.tga";
				game["headicon_allies"] = "gfx/hud/headicon@british.tga";
				break;
	
			case "russian":
				game["radio_allies"] = "gfx/hud/hud@objective_russian.tga";
				game["headicon_allies"] = "gfx/hud/headicon@russian.tga";
				break;
		}
	}

	if(isdefined(level.awe_teamplay) && level.awe_showteamstatus == 1)
	{
		game["radio_axis"] = "gfx/hud/hud@objective_german.tga";
		switch(game["allies"])
		{
			case "american":
				game["radio_allies"] = "gfx/hud/hud@objective_american.tga";
				break;
	
			case "british":
				game["radio_allies"] = "gfx/hud/hud@objective_british.tga";
				break;
	
			case "russian":
				game["radio_allies"] = "gfx/hud/hud@objective_russian.tga";
				break;
		}
	}

	if(isdefined(level.awe_teamplay) && level.awe_showteamstatus == 2)
	{
		game["headicon_axis"] = "gfx/hud/headicon@german.tga";
		switch(game["allies"])
		{
			case "american":
				game["headicon_allies"] = "gfx/hud/headicon@american.tga";
				break;
	
			case "british":
				game["headicon_allies"] = "gfx/hud/headicon@british.tga";
				break;
	
			case "russian":
				game["headicon_allies"] = "gfx/hud/headicon@russian.tga";
				break;
		}
	}
	// C47 planes
      if(level.awe_bombers)
		level._effect["bombers"] 	= loadfx ("fx/atmosphere/c47flyover2d.efx");
	
	// Load effect for bomb explosion (used by anticamp, antiteamkill, antiteamdamage and grenade cooking)
	level._effect["bombexplosion"]= loadfx("fx/explosions/pathfinder_explosion.efx");

	if(level.awe_cookablegrenades && level.awe_smokegrenades)
		level._effect["smokeexplosion"]= loadfx("fx/impacts/newimps/v_blast1.efx");
	
	//Ambient tracers
	if(level.awe_tracers)
		level._effect["awe_tracers"] = loadfx("fx/atmosphere/antiair_tracers.efx");
	
	// Ambient sky flashes
	if(level.awe_skyflashes)
	{
		level.awe_skyeffects = [];
		level.awe_skyeffects[level.awe_skyeffects.size]["effect"]	= loadfx("fx/atmosphere/cloudflash1.efx");
		level.awe_skyeffects[level.awe_skyeffects.size-1]["delay"]	= 0.0;
		level.awe_skyeffects[level.awe_skyeffects.size]["effect"]	= loadfx("fx/atmosphere/longrangeflash_altocloud.efx");
		level.awe_skyeffects[level.awe_skyeffects.size-1]["delay"]	= 0.0;
		level.awe_skyeffects[level.awe_skyeffects.size]["effect"]	= loadfx("fx/atmosphere/antiair_tracerscloseup.efx");
		level.awe_skyeffects[level.awe_skyeffects.size-1]["delay"]	= 6.5;
//		level.awe_skyeffects[level.awe_skyeffects.size]["effect"]	= loadfx("fx/atmosphere/overhill_flash.efx");
//		level.awe_skyeffects[level.awe_skyeffects.size-1]["delay"]	= 0;
		level.awe_skyeffects[level.awe_skyeffects.size]["effect"]	= loadfx("fx/atmosphere/thunderhead.efx");
		level.awe_skyeffects[level.awe_skyeffects.size-1]["delay"]	= 0;
		level.awe_skyeffects[level.awe_skyeffects.size]["effect"]	= loadfx("fx/atmosphere/lowlevelburst.efx");
		level.awe_skyeffects[level.awe_skyeffects.size-1]["delay"]	= 0;
	}

	// Flesh hit effect used by bouncing heads
	if(level.awe_pophead)
		level.awe_popheadfx = loadfx("fx/impacts/flesh_hit.efx");

	if(level.awe_bleeding)
		level.awe_bleedingfx = loadfx("fx/atmosphere/drop1.efx");

	if(isdefined(level.awe_wintermap) && randomInt(100)<level.awe_snow )
		level.awe_rainfx = loadfx("fx/atmosphere/rainstorm.efx");

	if(!isdefined(level.awe_wintermap) && randomInt(100)<level.awe_rain)
		level.awe_rainfx = loadfx("fx/atmosphere/chateau_rain.efx");

	if(level.awe_turretmobile)
	{
		level.awe_turretpickupmessage	= &"^7Hold MELEE [{+melee}] to pick up";
		level.awe_turretplacemessage	= &"^7Hold MELEE [{+melee}] to place";
		if(level.awe_turretpicktime)
			level.awe_turretpickingmessage= &"^7Picking up...";
		if(level.awe_turretplanttime)
			level.awe_turretplacingmessage= &"^7Placing...";
	}

	if(level.awe_tripwire)
	{
		level.awe_tripwireplacemessage = &"^7Hold MELEE [{+melee}] to place tripwire";
		level.awe_tripwirepickupmessage= &"^7Hold MELEE [{+melee}] to defuse tripwire";
		if(level.awe_tripwirepicktime)
			level.awe_turretpickingmessage= &"^7Picking up...";
		if(level.awe_tripwireplanttime)
			level.awe_turretplacingmessage= &"^7Placing...";
	}

	if(
		level.awe_secondaryweapon["default"] == "select"	|| level.awe_secondaryweapon["default"] == "selectother"	||
		level.awe_secondaryweapon["american"] == "select"	|| level.awe_secondaryweapon["american"] == "selectother"	||
		level.awe_secondaryweapon["british"] == "select"	|| level.awe_secondaryweapon["british"] == "selectother"	||
		level.awe_secondaryweapon["german"] == "select"		|| level.awe_secondaryweapon["german"] == "selectother"	||
		level.awe_secondaryweapon["russian"] == "select"	|| level.awe_secondaryweapon["russian"] == "selectother"
	  )
	{
		level.awe_secondaryweapontext = &"Select your secondary weapon";
	}

	// Disable minefields?
	if(level.awe_disableminefields)
	{
		minefields = getentarray( "minefield", "targetname" );
		if(minefields.size)
			for(i=0;i< minefields.size;i++)
				if(isdefined(minefields[i]))
					minefields[i] delete();
	}

		level.awe_logotext = &"^1=22= ^9Clan ^7(www.22clan.com)";	
}

doPrecaching()
{	
	precachemodel("xmodel/vehicle_tank_tiger_snow");
	precachemodel("xmodel/static_vehicle_german_kubelwagen");	
	precachemodel("xmodel/cow_standing");			
	precachemodel("xmodel/barrel_benzin_stalingrad");
	precachemodel("xmodel/weapon_mp44");
	precachemodel("xmodel/crate_misc_red1");
	precachemodel("xmodel/bottle_wine");
	precachemodel("xmodel/cow_dead2");
	precachemodel("xmodel/tree_ShortPine");
	precachemodel("xmodel/weapon_kar98k_sniper_mp");
	if(level.awe_debug)
	{
		precacheModel("xmodel/vehicle_plane_stuka");
		precacheModel("xmodel/cow_standing");
	}

	if(level.awe_laserdot)
		precacheShader("white");

	// Precache stukas
	if(level.awe_stukas)
		precacheModel("xmodel/vehicle_plane_stuka");
	if(level.awe_stukascrash)
		precacheModel("xmodel/vehicle_plane_stuka_d");



	if(level.awe_turretmobile)
	{
		precacheString( level.awe_turretpickupmessage );
		precacheString( level.awe_turretplacemessage );
		if(level.awe_turretpicktime)
			precacheString( level.awe_turretpickingmessage );
		if(level.awe_turretplanttime)
			precacheString( level.awe_turretplacingmessage );
	}

	if(level.awe_tripwire)
	{
		precacheString( level.awe_tripwirepickupmessage );
		precacheString( level.awe_tripwireplacemessage );
		if(level.awe_tripwirepicktime)
			precacheString( level.awe_turretpickingmessage );
		if(level.awe_tripwireplanttime)
			precacheString( level.awe_turretplacingmessage );

		switch(game["allies"])
		{
			case "american":
				precacheShader("gfx/hud/hud@death_us_grenade.dds");
				break;

			case "british":
				precacheShader("gfx/hud/hud@death_british_grenade.dds");
				break;

			case "russian":
				precacheShader("gfx/hud/hud@death_russian_grenade.dds");
				break;
		}
		precacheShader("gfx/hud/hud@death_steilhandgrenate.dds");
	}

	if(level.awe_turretmobile && (level.awe_turretplanttime || level.awe_turretpicktime))
		precacheShader("white");

	if(level.awe_tripwire && (level.awe_tripwireplanttime || level.awe_tripwirepicktime))
		precacheShader("white");

	// Precache MG42
	if(level.awe_mg42spawnextra)
		precacheModel("xmodel/mg42_bipod");

	// Precache PTRS41
	if(level.awe_ptrs41spawnextra) 
		precacheModel("xmodel/weapon_antitankrifle");
	
	// Precache turrets
	if(level.awe_turretmobile || cvardef("scr_awe_turret_w0", "", "", "", "string") != "")
	{
		// MG42
		precacheModel("xmodel/mg42_bipod");
		precacheItem("mg42_bipod_stand_mp");
		precacheItem("mg42_bipod_prone_mp");
		precacheItem("mg42_bipod_duck_mp");
		precacheTurret("mg42_bipod_duck_mp");
		precacheTurret("mg42_bipod_prone_mp");
		precacheTurret("mg42_bipod_stand_mp");

		// PTRS41
		precacheModel("xmodel/weapon_antitankrifle");
		precacheItem("PTRS41_Antitank_Rifle_mp");
		precacheTurret("PTRS41_Antitank_Rifle_mp");
	}

	if(level.awe_turretmobile)
	{
		precacheShader("gfx/hud/hud@death_mg42.tga");
		precacheShader("gfx/hud/hud@death_antitank.tga");
	}

	// Bloodscreen
	if(level.awe_bloodyscreen && !isdefined(level.awe_merciless))
	{
		precacheShader("gfx/impact/flesh_hit1.tga");
		precacheShader("gfx/impact/flesh_hit2.tga");
		precacheShader("gfx/impact/flesh_hitgib.tga");
	}
	
	// Precache parachute
	if(level.awe_parachutes)
		precacheModel("xmodel/parachute_animrig");

	// Precache bullethole
	if(level.awe_bulletholes)
	{
		precacheShader("gfx/impact/bullethit_glass.tga");
		precacheShader("gfx/impact/bullethit_glass2.tga");
	}
	
	// Precache hit blip
	if(level.awe_showhit && !isdefined(level.awe_demolition))
		precacheShader("gfx/hud/hud@fire_ready.tga");

	// Precache weapons
	if(!isdefined(level.awe_classbased))
	{
		precacheForcedWeapon(level.awe_primaryweapon["default"]);
		precacheForcedWeapon(level.awe_primaryweapon["american"]);
		precacheForcedWeapon(level.awe_primaryweapon["british"]);
		precacheForcedWeapon(level.awe_primaryweapon["german"]);
		precacheForcedWeapon(level.awe_primaryweapon["russian"]);

		precacheForcedWeapon(level.awe_secondaryweapon["default"]);
		precacheForcedWeapon(level.awe_secondaryweapon["american"]);
		precacheForcedWeapon(level.awe_secondaryweapon["british"]);
		precacheForcedWeapon(level.awe_secondaryweapon["german"]);
		precacheForcedWeapon(level.awe_secondaryweapon["russian"]);	
	
		precacheForcedWeapon(level.awe_pistoltype["default"]);
		precacheForcedWeapon(level.awe_pistoltype["american"]);
		precacheForcedWeapon(level.awe_pistoltype["british"]);
		precacheForcedWeapon(level.awe_pistoltype["german"]);
		precacheForcedWeapon(level.awe_pistoltype["russian"]);

		precacheForcedWeapon(level.awe_grenadetype["default"]);
		precacheForcedWeapon(level.awe_grenadetype["american"]);
		precacheForcedWeapon(level.awe_grenadetype["british"]);
		precacheForcedWeapon(level.awe_grenadetype["german"]);
		precacheForcedWeapon(level.awe_grenadetype["russian"]);
	}

	if(level.awe_smokegrenades)
		precacheItem("smokegrenade_mp");

	// Shellshocks      
	precacheShellshock("default");
	if(!isdefined(level.awe_merciless) && !isdefined(level.awe_demolition) && !isdefined(level.awe_rsd) )
	{
		precacheShellshock("death");
		precacheShellshock("stop");
	}

	if(level.awe_spawnprotection && !isdefined(level.awe_demolition))
	{
		precacheHeadIcon(game["headicon_protect"]);
		precacheShader(game["headicon_protect"]);
	}

	// Precache suicide icon for teamstatus usage
	if(isdefined(level.awe_teamplay) && level.awe_showteamstatus)
		precacheShader("gfx/hud/death_suicide.dds");

	if(level.awe_painscreen && !isdefined(level.awe_merciless) )
		precacheShader("white");

	if(level.awe_cookablegrenades)
	{
		// Precache shaders for progressbar
		precacheString(&"Cooking grenade");
		precacheShader("white");
	}	
	
	if(
		level.awe_secondaryweapon["default"] == "select"	|| level.awe_secondaryweapon["default"] == "selectother"	||
		level.awe_secondaryweapon["american"] == "select"	|| level.awe_secondaryweapon["american"] == "selectother"	||
		level.awe_secondaryweapon["british"] == "select"	|| level.awe_secondaryweapon["british"] == "selectother"	||
		level.awe_secondaryweapon["german"] == "select"		|| level.awe_secondaryweapon["german"] == "selectother"	||
		level.awe_secondaryweapon["russian"] == "select"	|| level.awe_secondaryweapon["russian"] == "selectother"
	  )
	{
		precacheString(level.awe_secondaryweapontext);
	}

	if( level.awe_anticamptime && !level.awe_anticampmethod && !isdefined(level.awe_tdom) )
	{
		// Precache headicons and shaders
		precacheHeadIcon(game["headicon_star"]);
		// Precache compass shaders
		precacheShader("gfx/hud/objective.dds");
		precacheShader("gfx/hud/objective_down.dds");
		precacheShader("gfx/hud/objective_up.dds");	
	}

	if(isdefined(level.awe_teamplay) && level.awe_anticamptime && !level.awe_anticampmethod && !isdefined(level.awe_tdom) )
	{
		precacheShader(game["radio_allies"]);
		precacheShader(game["radio_axis"]);
		precacheShader("gfx/hud/hud@objective_german_up.tga");
		precacheShader("gfx/hud/hud@objective_german_down.tga");
		switch(game["allies"])
		{
			case "russian":
				precacheShader("gfx/hud/hud@objective_russian_up.tga");
				precacheShader("gfx/hud/hud@objective_russian_down.tga");
				break;

			case "british":
				precacheShader("gfx/hud/hud@objective_british_up.tga");
				precacheShader("gfx/hud/hud@objective_british_down.tga");
				break;

			case "american":
				precacheShader("gfx/hud/hud@objective_american_up.tga");
				precacheShader("gfx/hud/hud@objective_american_down.tga");
				break;
		}
	}

	if(isdefined(level.awe_teamplay) && level.awe_showteamstatus == 1)
	{
		precacheShader(game["radio_allies"]);
		precacheShader(game["radio_axis"]);
	}
	if(isdefined(level.awe_teamplay) && level.awe_showteamstatus == 2)
	{
		precacheShader(game["headicon_allies"]);
		precacheShader(game["headicon_axis"]);
	}
}
	
randomMapRotation()
{
	level endon("awe_boot");

	// Do random maprotation?
	if(!level.awe_randommaprotation)
		return;

	// Randomize maps of maprotationcurrent is empty or on a fresh start
	if( strip(getcvar("sv_maprotationcurrent")) == "" || level.awe_randommaprotation == 1)
	{
		maprot = strip(getcvar("sv_maprotation"));

		// Check if there is anything to randomize
		if(maprot=="")
			return;

		// Explode entries into an array
		temparr = explode(maprot," ");
		j=0;
		for(i=0;i<temparr.size;)
		{
			if(temparr[i]=="gametype")
			{
				maps[j] = "gametype " + temparr[i+1] + " map " + temparr[i+3];
				i += 4;
			}
			else
			{
				maps[j] = "map " + temparr[i+1];
				i += 2;
			}
			j++;
		}

		// Shuffle the maps 10 times
		for(k = 0; k < 10; k++)
		{
			for(i = 0; i < maps.size; i++)
			{
				j = randomInt(maps.size);
				map = maps[i];
				maps[i] = maps[j];
				maps[j] = map;
			}
		}

		// Built new maprotation string
		newmaprotation = "";
		for(i = 0; i < maps.size; i++)
		{
			// Add map to rotation
			newmaprotation += maps[i] + " ";
		}

		// Set the new rotation
		setCvar("sv_maprotationcurrent", " " + strip(newmaprotation) );

		// Set scr_awe_random_maprotation to "2" to indicate that initial randomizing is done
		setCvar("scr_awe_random_maprotation", "2");
	}
}

showWelcomeMessages()
{
	self endon("awe_spawned");
	self endon("awe_died");

	if(isdefined(self.pers["awe_welcomed"])) return;
	self.pers["awe_welcomed"] = true;

	wait 2;

	count = 0;
	message = cvardef("scr_awe_welcome" + count, "", "", "", "string");
	while(message != "")
	{
		self iprintlnbold(message);
		count++;
		message = cvardef("scr_awe_welcome" + count, "", "", "", "string");
		wait level.awe_welcomedelay;
	}
}

serverMessages()
{
	level endon("awe_boot");
	if(level.awe_messageindividual)
	{
		// Check if thread has allready been called.
		if(isdefined(self.pers["awe_serverMessages"]))
			return;

		// End if player disconnects (I believe that it is done automaticly)
		self endon("awe_spawned");
		self endon("awe_died");
	}
	else
	{
		// Check if thread has allready been called.
		if(isdefined(game["serverMessages"]))
			return;
	}

	wait level.awe_messagedelay;

	for(;;)
	{
		maprotcur = strip(getcvar("sv_maprotationcurrent"));
		if(maprotcur!="")
		{
			// Get next map
			temparr = explode(maprotcur," ");
			if(temparr[0]=="gametype")
			{
				nextgt=temparr[1];
				nextmap=temparr[3];
			}
			else
			{
				nextgt=getcvar("g_gametype");
				nextmap=temparr[1];
			}

				if(level.awe_messageindividual)
					self iprintln("Check your stats or apply to join at ^122clan.com^7");
				else
					iprintln("Check your stats or apply to join at ^122clan.com^7");

			wait 1;
			if(level.awe_messageindividual)
				self iprintln("^3Next gametype: ^5" + getGametypeName(nextgt) );
			else
				iprintln("^3Next gametype: ^5" + getGametypeName(nextgt) );
			wait 1;
			if(level.awe_messageindividual)
				self iprintln("^3Next map: ^5" + getMapName(nextmap) );
			else
				iprintln("^3Next map: ^5" + getMapName(nextmap) );
		}
	
		// Get first message
		count = 0;
		message = cvardef("scr_awe_message" + count, "", "", "", "string");

		// Avoid infinite loop
		if(message == "" && maprotcur == "")
			wait level.awe_messagedelay;

		// Announce messages
		while(message != "")
		{
			wait level.awe_messagedelay;
			if(level.awe_messageindividual)
				self iprintln(message);
			else
				iprintln(message);
			count++;
			message = cvardef("scr_awe_message" + count, "", "", "", "string");
		}

		// Loop?
		if(!level.awe_messageloop)
			break;

		wait level.awe_messagedelay+10;
	}
	// Set flag to indicate that this thread has been called and run all through once
	if(level.awe_messageindividual)
		self.pers["awe_serverMessages"] = true;
	else
		game["serverMessages"] = true;
}

getGametypeName(gt)
{
	switch(gt)
	{
		case "dm":
		case "mc_dm":
			gtname = "Deathmatch";
			break;

		case "sdm":
			gtname = "Elimination";
			break;
		
		case "tdm":
		case "mc_tdm":
			gtname = "Team Deathmatch";
			break;

		case "sd":
		case "mc_sd":
			gtname = "Search & Destroy";
			break;

		case "rsd":
		case "mc_rsd":
			gtname = "Reinforced Search & Destroy";
			break;

		case "re":
		case "mc_re":
			gtname = "Retrieval";
			break;

		case "hq":
		case "mc_hq":
			gtname = "Headquarters";
			break;

		case "bel":
		case "mc_bel":
			gtname = "Behind Enemy Lines";
			break;
		
		case "dem":
		case "mc_dem":
			gtname = "Demolition";
			break;

		case "cnq":
		case "mc_cnq":
			gtname = "Conquest TDM";
			break;

		case "lts":
		case "mc_lts":
			gtname = "Last Team Standing";
			break;

		case "ctf":
		case "mc_ctf":
			gtname = "Capture The Flag";
			break;

		case "mc_tdom":
			gtname = "Team Domination";
			break;
		
		default:
			gtname = gt;
			break;
	}

	return gtname;
}

getMapName(map)
{
	switch(map)
	{
		case "mp_bocage":
			mapname = "Bocage";
			break;
		
		case "mp_brecourt":
			mapname = "Brecourt";
			break;

		case "mp_carentan":
			mapname = "Carentan";
			break;
		
		case "mp_chateau":
			mapname = "Chateau";
			break;
		
		case "mp_dawnville":
			mapname = "Dawnville";
			break;
		
		case "mp_depot":
			mapname = "Depot";
			break;
		
		case "mp_harbor":
			mapname = "Harbor";
			break;
		
		case "mp_hurtgen":
			mapname = "Hurtgen";
			break;
		
		case "mp_neuville":
			mapname = "Neuville";
			break;
		
		case "mp_pavlov":
			mapname = "Pavlov";
			break;
		
		case "mp_powcamp":
			mapname = "P.O.W Camp";
			break;
		
		case "mp_railyard":
			mapname = "Railyard";
			break;

		case "mp_rocket":
			mapname = "Rocket";
			break;
		
		case "mp_ship":
			mapname = "Ship";
			break;
		
		case "mp_stalingrad":
			mapname = "Stalingrad";
			break;
		
		case "mp_stanjel":
		case "mc_stanjel":
			mapname = "Stanjel";
			break;

		case "mp_bazolles":
		case "mc_bazolles":
			mapname = "Bazolles";
			break;

		case "mp_townville":
		case "mc_townville":
			mapname = "Town ville";
			break;

		case "mp_german_town":
		case "mc_german_town":
			mapname = "German Town";
			break;
		
		default:
			mapname = map;
			break;
	}

	return mapname;
}

explode(s,delimiter)
{
	j=0;
	temparr[j] = "";	

	for(i=0;i<s.size;i++)
	{
		if(s[i]==delimiter)
		{
			j++;
			temparr[j] = "";
		}
		else
			temparr[j] += s[i];
	}
	return temparr;
}


// Strip blanks at start and end of string
strip(s)
{
	if(s=="")
		return "";

	s2="";
	s3="";

	i=0;
	while(s[i]==" " && i<s.size)
		i++;

	// String is just blanks?
	if(i==s.size)
		return "";
	
	for(;i<s.size;i++)
	{
		s2 += s[i];
	}

	i=s2.size-1;
	while(s2[i]==" " && i>0)
		i--;

	for(j=0;j<=i;j++)
	{
		s3 += s2[j];
	}
		
	return s3;
}


updateGametypeCvars(init)
{
	level endon("awe_boot");

	// Debug
	level.awe_debug = cvardef("scr_awe_debug", 0, 0, 1, "int");

	// Disable minefields
	level.awe_disableminefields = cvardef("scr_awe_disable_minefields", 0, 0, 1, "int");

	// Rain/Snow 0-100%
	level.awe_rain	= cvardef("scr_awe_rain", 0, 0, 100, "int");
	level.awe_snow	= cvardef("scr_awe_snow", 0, 0, 100, "int");

	// Laserdot
	level.awe_laserdot	= cvardef("scr_awe_laserdot", 0, 0, 1, "float");		// 0 = don't show, 1 = solid
	level.awe_laserdotsize	= cvardef("scr_awe_laserdot_size", 2, 0.5, 5, "float");	// size
	level.awe_laserdotred	= cvardef("scr_awe_laserdot_red", 1, 0, 1, "float");		// amount of red in dot
	level.awe_laserdotgreen	= cvardef("scr_awe_laserdot_green", 0, 0, 1, "float");	// amount of green in dot
	level.awe_laserdotblue	= cvardef("scr_awe_laserdot_blue", 0, 0, 1, "float");		// amount of blue in dot

	// Show team status on hud
	level.awe_showteamstatus = cvardef("scr_awe_show_team_status", 0, 0, 2, "int");

	// Show hit blip
	level.awe_showhit = cvardef("scr_awe_showhit", 0, 0, 1, "int");

	// Painscreen
	level.awe_painscreen = cvardef("scr_awe_painscreen", 0, 0, 100, "int");

	// Bloodyscreen
	level.awe_bloodyscreen = cvardef("scr_awe_bloodyscreen", 0, 0, 1, "int");

	// Bulletholes
	level.awe_bulletholes = cvardef("scr_awe_bulletholes", 0, 0, 2, "int");
	
	// shell & death shock
	level.awe_shellshock = cvardef("scr_awe_shellshock", 0, 0, 1, "int");
	level.awe_deathshock = cvardef("scr_awe_deathshock", 1, 0, 1, "int");			

	// Weapon options
	level.awe_primaryweapon["default"]  = cvardef("scr_awe_primary_weapon", "", "", "", "string");
	level.awe_primaryweapon["american"]  = cvardef("scr_awe_primary_weapon_american", "", "", "", "string");
	level.awe_primaryweapon["british"]  = cvardef("scr_awe_primary_weapon_british", "", "", "", "string");
	level.awe_primaryweapon["german"]  = cvardef("scr_awe_primary_weapon_german", "", "", "", "string");
	level.awe_primaryweapon["russian"]  = cvardef("scr_awe_primary_weapon_russian", "", "", "", "string");

	level.awe_secondaryweaponkeepold	= cvardef("scr_awe_secondary_weapon_keepold", 1, 0, 1, "int");
	level.awe_secondaryweapon["default"]= cvardef("scr_awe_secondary_weapon", "", "", "", "string");
	level.awe_secondaryweapon["american"]=cvardef("scr_awe_secondary_weapon_american", "", "", "", "string");
	level.awe_secondaryweapon["british"]= cvardef("scr_awe_secondary_weapon_british", "", "", "", "string");
	level.awe_secondaryweapon["german"]	= cvardef("scr_awe_secondary_weapon_german", "", "", "", "string");
	level.awe_secondaryweapon["russian"]= cvardef("scr_awe_secondary_weapon_russian", "", "", "", "string");

	level.awe_pistoltype["default"]  = cvardef("scr_awe_pistol_type", "", "", "", "string");
	level.awe_pistoltype["american"]  = cvardef("scr_awe_pistol_type_american", "", "", "", "string");
	level.awe_pistoltype["british"]  = cvardef("scr_awe_pistol_type_british", "", "", "", "string");
	level.awe_pistoltype["german"]  = cvardef("scr_awe_pistol_type_german", "", "", "", "string");
	level.awe_pistoltype["russian"]  = cvardef("scr_awe_pistol_type_russian", "", "", "", "string");

	level.awe_grenadetype["default"]  = cvardef("scr_awe_grenade_type", "", "", "", "string");
	level.awe_grenadetype["american"]  = cvardef("scr_awe_grenade_type_american", "", "", "", "string");
	level.awe_grenadetype["british"]  = cvardef("scr_awe_grenade_type_british", "", "", "", "string");
	level.awe_grenadetype["german"]  = cvardef("scr_awe_grenade_type_german", "", "", "", "string");
	level.awe_grenadetype["russian"]  = cvardef("scr_awe_grenade_type_russian", "", "", "", "string");

	// Grenade options
	level.awe_cookablegrenades = cvardef("scr_awe_cookable_grenades", 0, 0, 1, "int");
	level.awe_smokegrenades = cvardef("scr_awe_smokegrenades", 0, 0, 99, "int");

	// Parachuting
	level.awe_parachutes = cvardef("scr_awe_parachutes", 0, 0, 2, "int");
	level.awe_parachutesrooflandings = cvardef("scr_awe_parachutes_roof_landings", 0, 0, 1, "int");
	level.awe_parachutesonlyattackers = cvardef("scr_awe_parachutes_only_attackers", 1, 0, 1, "int");
	level.awe_parachutesprotection = cvardef("scr_awe_parachutes_protection", 1, 0, 1, "int");
	level.awe_parachuteslimitaltitude = cvardef("scr_awe_parachutes_limit_altitude", 1700, 0, 50000, "int");

	// Turret options
	level.awe_turretmobile		= cvardef("scr_awe_turret_mobile", 0, 0, 2, "int");
	level.awe_turretplanttime	= cvardef("scr_awe_turret_plant_time", 2, 0, 30, "float");
	level.awe_turretpicktime	= cvardef("scr_awe_turret_pick_time", 1, 0, 30, "float");
	level.awe_mg42spawnextra	= cvardef("scr_awe_mg42_spawn_extra", 0, 0, 20, "int");
	level.awe_ptrs41spawnextra	= cvardef("scr_awe_ptrs41_spawn_extra", 0, 0, 20, "int");

	// Tripwire options
	level.awe_tripwire		= cvardef("scr_awe_tripwire", 0, 0, 3, "int");
	level.awe_tripwireplanttime	= cvardef("scr_awe_tripwire_plant_time", 3, 0, 30, "float");
	level.awe_tripwirepicktime	= cvardef("scr_awe_tripwire_pick_time", 5, 0, 30, "float");

	// Spawn protection
	level.awe_spawnprotection	= cvardef("scr_awe_spawn_protection", 0, 0, 99, "int");

	// Stukas
	level.awe_stukas			= cvardef("scr_awe_stukas", 0, 0, 99, "int");
	level.awe_stukascrash		= cvardef("scr_awe_stukas_crash", 20, 0, 100, "int");
	level.awe_stukascrashsafety	= cvardef("scr_awe_stukas_crash_safety", 0, 0, 1, "int");
	level.awe_stukascrashquake	= cvardef("scr_awe_stukas_crash_quake", 1, 0, 1, "int");
	level.awe_stukascrashstay	= cvardef("scr_awe_stukas_crash_stay", 60, 0, 10000, "int");
	level.awe_stukasdelay		= cvardef("scr_awe_stukas_delay", 500, 1, 10000, "int"); 

	// Pop head
	level.awe_pophead	= cvardef("scr_awe_pophead", 0, 0, 100, "int");
	level.awe_popheadstay = cvardef("scr_awe_pophead_stay", 60, 0, 10000, "int");

	// Anticamping
	level.awe_anticamptime = cvardef("scr_awe_anticamp_time", 0, 0, 1440, "int");
	level.awe_anticampmethod = cvardef("scr_awe_anticamp_method", 0, 0, level.awe_punishments + 1, "int");

	for(;;)
	{
		// Tag player with this name
		level.awe_shootme = cvardef("scr_awe_shootme", "Unknown Soldier", "", "", "string");
		level.awe_shootmetag = cvardef("scr_awe_shootme_tag", "SHOOT ME!", "", "", "string");

		// Use bots (for debugging)
		level.awe_bots = cvardef("scr_awe_bots", 0, 0, 99, "int");

		// Disable crosshair?
		level.awe_nocrosshair = cvardef("scr_awe_no_crosshair", 0, 0, 1, "int");
		// warm up round for round based gametypes
		level.awe_warmupround 	= cvardef("scr_awe_warmup_round", 0, 0, 1, "int");

		// team overriding
		level.awe_teamallies	= cvardef("scr_awe_team_allies","","","","string");
		level.awe_teamswap	= cvardef("scr_awe_team_swap", 1, 0, 1,"int");

		// fog options
		level.awe_cfog 		= cvardef("scr_awe_cfog", 0, 0, 100, "int");
		level.awe_cfogdistance	= cvardef("scr_awe_cfog_distance", 5000, 0, 30000, "int");
		level.awe_cfogdistance2	= cvardef("scr_awe_cfog_distance2", 0, 0, 30000, "int");
		level.awe_cfogred		= cvardef("scr_awe_cfog_red", 0.5, 0, 1, "float");
		level.awe_cfoggreen	= cvardef("scr_awe_cfog_green", 0.5, 0, 1, "float");
		level.awe_cfogblue	= cvardef("scr_awe_cfog_blue", 0.5, 0, 1, "float");

		level.awe_efog 		= cvardef("scr_awe_efog", 0, 0, 100, "int");
		level.awe_efogdensity	= cvardef("scr_awe_efog_density", 0.001, 0, 0.02, "float");
		level.awe_efogdensity2	= cvardef("scr_awe_efog_density2", 0, 0, 1, "float");
		level.awe_efogred		= cvardef("scr_awe_efog_red", 0.5, 0, 1, "float");
		level.awe_efoggreen	= cvardef("scr_awe_efog_green", 0.5, 0, 1, "float");
		level.awe_efogblue	= cvardef("scr_awe_efog_blue", 0.5, 0, 1, "float");

		// welcome message
		level.awe_welcomedelay		= cvardef("scr_awe_welcome_delay", 1, 0.05, 30, "float");

		// Server messages
		level.awe_messagedelay		= cvardef("scr_awe_message_delay", 30, 1, 1440, "int");
		level.awe_messageloop		= cvardef("scr_awe_message_loop", 1, 0, 1, "int");
		level.awe_messageindividual	= cvardef("scr_awe_message_individual", 0, 0, 1, "int");

		// Drop weapon options
		level.awe_droponarmhit	= cvardef("scr_awe_droponarmhit", 0, 0, 1, "int");
		level.awe_droponhandhit = cvardef("scr_awe_droponhandhit", 0, 0, 1, "int");

		// Trip on foot/leg hit
		level.awe_triponleghit	= cvardef("scr_awe_triponleghit", 0, 0, 1, "int");
		level.awe_triponfoothit	= cvardef("scr_awe_triponfoothit", 0, 0, 1, "int");
			
		// Pop helmet
		level.awe_pophelmet = cvardef("scr_awe_pophelmet", 50, 0, 100, "int");
		level.awe_pophelmetstay = cvardef("scr_awe_pophelmet_stay", 60, 0, 10000, "int");

	     	// pain & death sounds
		level.awe_painsound	= cvardef("scr_awe_painsound", 1, 0, 1, "int");
		level.awe_deathsound	= cvardef("scr_awe_deathsound", 1, 0, 1, "int");

	      // C47 planes
		level.awe_bombers = cvardef("scr_awe_bombers", 0, 0, 1, "int");
      	// C47 planes delay
		level.awe_bombers_delay = cvardef("scr_awe_bombers_delay", 300, 1, 1440, "int");	

	      // Override altitude?
		level.awe_bombers_altitude = cvardef("scr_awe_bombers_altitude", 0, 0, 10000, "int");
	      // Override distance?
		level.awe_bombers_distance = cvardef("scr_awe_bombers_distance", 0, -25000, 25000, "int");

		// Ambient tracers
		level.awe_tracers			= cvardef("scr_awe_tracers", 0, 0, 100, "int");
		level.awe_tracersdelaymin	= cvardef("scr_awe_tracers_delay_min", 5, 1, 1440, "int");
		level.awe_tracersdelaymax	= cvardef("scr_awe_tracers_delay_max", 15, 1, 1440, "int");

		// Ambient skyflashes
		level.awe_skyflashes		= cvardef("scr_awe_skyflashes", 5, 0, 100, "int");
		level.awe_skyflashesdelaymin	= cvardef("scr_awe_skyflashes_delay_min", 5, 1, 1440, "int");
		level.awe_skyflashesdelaymax	= cvardef("scr_awe_skyflashes_delay_max", 15, 1, 1440, "int");

		// Anti teamkilling
		level.awe_teamkillmax = cvardef("scr_awe_teamkill_max", 3, 0, 99, "int");
		level.awe_teamkillwarn = cvardef("scr_awe_teamkill_warn", 1, 0, 99, "int");
		level.awe_teamkillmethod = cvardef("scr_awe_teamkill_method", 0, 0, level.awe_punishments + 1, "int");
		level.awe_teamkillreflect = cvardef("scr_awe_teamkill_reflect", 1, 0, 1, "int");
		level.awe_teamkillmsg = cvardef("scr_awe_teamkill_msg","^6Good damnit! ^7Learn the difference between ^4friend ^7and ^1foe ^7you bastard!.","","","string");

		// Anti teamdamage
		level.awe_teamdamagemax = cvardef("scr_awe_teamdamage_max", 0, 0, 10000, "int");
		level.awe_teamdamagewarn = cvardef("scr_awe_teamdamage_warn", 0, 0, 10000, "int");
		level.awe_teamdamagemethod = cvardef("scr_awe_teamdamage_method", 0, 0, level.awe_punishments + 1, "int");
		level.awe_teamdamagereflect = cvardef("scr_awe_teamdamage_reflect", 1, 0, 1, "int");
		level.awe_teamdamagemsg = cvardef("scr_awe_teamdamage_msg","^6Good damnit! ^7Learn the difference between ^4friend ^7and ^1foe ^7you bastard!.","","","string");

		// Anticamping
		level.awe_anticampmarktime = cvardef("scr_awe_anticamp_marktime", 90, 0, 1440, "int");
		level.awe_anticampfun = cvardef("scr_awe_anticamp_fun", 0, 0, 1440, "int");
		level.awe_anticampmsgsurvived = cvardef("scr_awe_anticamp_msg_survived", "^6Congratulations! ^7You are no longer marked and still alive.", "", "", "string");
		level.awe_anticampmsgdied = cvardef("scr_awe_anticamp_msg_died", "A ^1dead ^7camper is a ^2good ^7camper!", "", "", "string");

		// Grenade options
		level.awe_fusetime = cvardef("scr_awe_fuse_time", 4, 1, 99, "int");
		level.awe_grenadewarning = cvardef("scr_awe_grenade_warning", 100, 0, 100, "int");
		level.awe_grenadewarningrange = cvardef("scr_awe_grenade_warning_range", 500, 0, 100000, "int");
		level.awe_grenadecount = cvardef("scr_awe_grenade_count", 0, 0, 999, "int");
		level.awe_grenadecountrandom = cvardef("scr_awe_grenade_count_random", 0, 0, 2, "int");
		
		// Ammo limiting
		level.awe_ammomin = cvardef("scr_awe_ammo_min",100,0,100,"int");
		level.awe_ammomax = cvardef("scr_awe_ammo_max",100,level.awe_ammomin,100,"int");

		// Hud
		level.awe_showlogo = cvardef("scr_awe_show_logo", 1, 0, 1, "int");	
		level.awe_showsdtimer_cvar = cvardef("scr_awe_show_sd_timer", 0, 0, 1, "int");	
		if(level.awe_showsdtimer_cvar)
			level.awe_showsdtimer = true;
		else
			level.awe_showsdtimer = undefined;

		// Use random maprotation?
		level.awe_randommaprotation = cvardef("scr_awe_random_maprotation", 0, 0, 2, "int");	

		// Spawn protection
		level.awe_spawnprotectionrange= cvardef("scr_awe_spawn_protection_range", 50, 0, 10000, "int");
		level.awe_spawnprotectionhud	= cvardef("scr_awe_spawn_protection_hud", 1, 0, 2, "int");

		// Turret stuff
		level.awe_mg42disable 		= cvardef("scr_awe_mg42_disable", 0, 0, 1, "int");
		level.awe_ptrs41disable 	= cvardef("scr_awe_ptrs41_disable", 0, 0, 1, "int");
		level.awe_turretpenalty 	= cvardef("scr_awe_turret_penalty", 1, 0, 1, "int");
		level.awe_turretrecover		= cvardef("scr_awe_turret_recover", 1, 0, 1, "int");

		// Bleeding & taunts
		level.awe_bleeding	= cvardef("scr_awe_bleeding", 0, 0, 1, "int");
		level.awe_taunts		= cvardef("scr_awe_taunts", 0, 0, 1, "int");

		// If we are initializing variables, break here
		if(init) break;

		if(getcvar("let_it_all_pour_down")=="1" && !isdefined(level.awe_raining))
			thread letItRain();
		
		if(!isdefined(level.awe_tdom))
		{
			// Delete all stale objectives
			for(i=level.awe_objnum_min;i<=level.awe_objnum_max;i++)	// Set up array and flag all as unused
				objectives[i]=false;

			allplayers = getentarray("player", "classname");		// Get all players and flag all used objectives
			for(i = 0; i < allplayers.size; i++)
				if( allplayers[i].sessionstate == "playing" && isdefined(allplayers[i].awe_objnum) )
					objectives[allplayers[i].awe_objnum]=true;

			for(i=level.awe_objnum_min;i<=level.awe_objnum_max;i++)	// Delete unused objectives
				if(!objectives[i])
					objective_delete(i);
		}
		// Update team status
		if(level.awe_showteamstatus && isdefined(level.awe_teamplay))
			updateteamstatus();
	
		wait 2;
	}
}
/*
USAGE OF "cvardef"
cvardef replaces the multiple lines of code used repeatedly in the setup areas of the script.
The function requires 5 parameters, and returns the set value of the specified cvar
Parameters:
	varname - The name of the variable, i.e. "scr_teambalance", or "scr_dem_respawn"
		This function will automatically find map-sensitive overrides, i.e. "src_dem_respawn_mp_brecourt"

	vardefault - The default value for the variable.  
		Numbers do not require quotes, but strings do.  i.e.   10, "10", or "wave"

	min - The minimum value if the variable is an "int" or "float" type
		If there is no minimum, use "" as the parameter in the function call

	max - The maximum value if the variable is an "int" or "float" type
		If there is no maximum, use "" as the parameter in the function call

	type - The type of data to be contained in the vairable.
		"int" - integer value: 1, 2, 3, etc.
		"float" - floating point value: 1.0, 2.5, 10.384, etc.
		"string" - a character string: "wave", "player", "none", etc.
*/
cvardef(varname, vardefault, min, max, type)
{
	mapname = getcvar("mapname");		// "mp_dawnville", "mp_rocket", etc.
	gametype = getcvar("g_gametype");	// "tdm", "bel", etc.

//	if(getcvar(varname) == "")		// if the cvar is blank
//		setcvar(varname, vardefault); // set the default

	tempvar = varname + "_" + gametype;	// i.e., scr_teambalance becomes scr_teambalance_tdm
	if(getcvar(tempvar) != "") 		// if the gametype override is being used
		varname = tempvar; 		// use the gametype override instead of the standard variable

	tempvar = varname + "_" + mapname;	// i.e., scr_teambalance becomes scr_teambalance_mp_dawnville
	if(getcvar(tempvar) != "")		// if the map override is being used
		varname = tempvar;		// use the map override instead of the standard variable


	// get the variable's definition
	switch(type)
	{
		case "int":
			if(getcvar(varname) == "")		// if the cvar is blank
				definition = vardefault;	// set the default
			else
				definition = getcvarint(varname);
			break;
		case "float":
			if(getcvar(varname) == "")	// if the cvar is blank
				definition = vardefault;	// set the default
			else
				definition = getcvarfloat(varname);
			break;
		case "string":
		default:
			if(getcvar(varname) == "")		// if the cvar is blank
				definition = vardefault;	// set the default
			else
				definition = getcvar(varname);
			break;
	}

	// if it's a number, with a minimum, that violates the parameter
	if((type == "int" || type == "float") && min != "" && definition < min)
		definition = min;

	// if it's a number, with a maximum, that violates the parameter
	if((type == "int" || type == "float") && max != "" && definition > max)
		definition = max;

	return definition;
}

spawn_model(model,name,origin,angles)
{
	if (!isdefined(model) || !isdefined(name) || !isdefined(origin))
		return undefined;

	if (!isdefined(angles))
		angles = (0,0,0);

	spawn = spawn ("script_model",(0,0,0));
	spawn.origin = origin;
	spawn setmodel (model);
	spawn.targetname = name;
	spawn.angles = angles;

	return spawn;
}

// sort a list of entities with ".origin" properties in ascending order by their distance from the "startpoint"
// "points" is the array to be sorted
// "startpoint" (or the closest point to it) is the first entity in the returned list
// "maxdist" is the farthest distance allowed in the returned list
// "mindist" is the nearest distance to be allowed in the returned list
sortByDist(points, startpoint, maxdist, mindist)
{
	if(!isdefined(points))
		return undefined;
	if(!isdefineD(startpoint))
		return undefined;

	if(!isdefined(mindist))
		mindist = -1000000;
	if(!isdefined(maxdist))
		maxdist = 1000000; // almost 16 miles, should cover everything.

	sortedpoints = [];

	max = points.size-1;
	for(i = 0; i < max; i++)
	{
		nextdist = 1000000;
		next = undefined;

		for(j = 0; j < points.size; j++)
		{
			thisdist = distance(startpoint.origin, points[j].origin);
			if(thisdist <= nextdist && thisdist <= maxdist && thisdist >= mindist)
			{
				next = j;
				nextdist = thisdist;
			}
		}

		if(!isdefined(next))
			break; // didn't find one that fit the range, stop trying

		sortedpoints[i] = points[next];

		// shorten the list, fewer compares
		points[next] = points[points.size-1]; // replace the closest point with the end of the list
		points[points.size-1] = undefined; // cut off the end of the list
	}

	sortedpoints[sortedpoints.size] = points[0]; // the last point in the list

	return sortedpoints;
}

shockme(damage, means)
{

}

painsound()
{

}

taunts(victim)
{
	self notify("awe_taunts");
	self endon("awe_taunts");
	self endon("awe_spawned");
	self endon("awe_died");

	if(isdefined(level.awe_teamplay))
	{
		if(isPlayer(self) && self != victim && self.sessionteam != victim.sessionteam )
			self.awe_killspree++;
		else
			return;
	}
	else
	{
		if (isPlayer(self) && self != victim)
			self.awe_killspree++;
		else
			return;
	}

	rn = randomint(16);

	if(self.awe_killspree == 2 || self.awe_killspree == 3)
		rn = randomint(10);
	if(self.awe_killspree == 4 || self.awe_killspree == 5)
		rn = randomint(8);
	if(self.awe_killspree > 5)
		rn = randomint(5);

	wait (.5);

	if(self.sessionstate == "playing")
	{
//		self iprintlnbold("TAUNT! RN:" + rn + " killspree:" + self.awe_killspree);

		if(isdefined(level.awe_teamplay))
		{
			team = self.sessionteam;
			otherteam = victim.sessionteam;
		}
		else
		{
			team = self.pers["team"];
			otherteam = victim.pers["team"];
		}

		nationality = game[team];
		if(nationality == "british") nationality = "american";
		
		if (rn == 1 || rn == 2)
			self playsound("awe_" + nationality + "_taunt");
		if (rn == 3)
		{
			if((game[team] == "russian") && (game[team] == "german"))
				self playsound ("awe_RvG");
			else if ((game[team] == "german") && (game[team] == "american"))
				self playsound ("awe_GvA");
			else if ((game[team] == "german") && (game[team] == "russian"))
				self playsound ("awe_GvR");
			else 
				self playsound("awe_" + nationality + "_taunt");
		}
	}	
}


PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc)
{
	self notify("awe_died");

	self cleanupPlayer1();

	if(!isdefined(level.awe_merciless) && level.awe_taunts)
		attacker thread taunts(self);

	dropTurret(undefined, sMeansOfDeath);

	// Check for headpopping
	switch(sHitLoc)
	{
		case "head":
		case "helmet":
			if (sMeansofDeath == "MOD_MELEE")
				dopop = true;
			else {
				switch (sWeapon)
				{
					case "m1garand_mp": case "kar98k_mp": case "mosin_nagant_mp":case "enfield_mp": 
					case "kar98k_sniper_mp": case "springfield_mp":	case "mosin_nagant_sniper_mp": 
					case "mg42_bipod_stand_mp": case "mg42_bipod_duck_mp": case "mg42_bipod_prone_mp":
					case "PTRS41_Antitank_Rifle_mp":
					dopop = true;
					break;
				}
			}
			break;

		case "none":
			switch (sWeapon)
			{
				case "panzerfaust_mp":
					if (iDamage >= 500)
						dopop = true;
					break;
		
				//grenades
				case "stielhandgranate_mp": case "rgd-33russianfrag_mp": case "fraggrenade_mp": case "mk1britishfrag_mp":
					if (iDamage >= 100)
						dopop = true;
					break;
			}
			break;
	}

	// Pop head/helmet?
	if(isdefined(dopop))
	{
		if(randomInt(100) < level.awe_pophead && !isdefined(self.awe_headpopped) )
			self popHead( vDir, iDamage);
		else if(randomInt(100) < level.awe_pophelmet && !isdefined(self.awe_helmetpopped) )
			self popHelmet( vDir, iDamage);
	}

	// Shellshock
	if(level.awe_deathshock && !isdefined(level.awe_merciless) && !isdefined(level.awe_demolition) && !isdefined(level.awe_rsd) )
	{

	}

	// Pains sound
	if(level.awe_deathsound && !isdefined(level.awe_merciless) && !isdefined(level.awe_demolition) )
	{
		if(isdefined(level.awe_teamplay))
			team = self.sessionteam;
		else
			team = self.pers["team"];

		nationality = game[team];
		num = randomInt(level.awe_voices[nationality]) + 1;
		scream = "generic_death_" + game[team] + "_" + num;


	}
}

teamkill()
{
	if (!level.awe_teamkillmax)
		return;

	// Increase value
	self.pers["awe_teamkills"]++;	
	
	// Check if it reached or passed the max level
	if (self.pers["awe_teamkills"]>=level.awe_teamkillmax)
	{
		if(level.awe_teamkillmethod)
			iprintln(self.name + " ^7has killed ^1" + self.pers["awe_teamkills"] + " ^7teammate(s) and will be punished.");
		if(level.awe_teamkillreflect)
			iprintln(self.name + " ^7has killed ^1" + self.pers["awe_teamkills"] + " ^7teammate(s) and will reflect damage.");

		self iprintlnbold(level.awe_teamkillmsg);
		self thread punishme(level.awe_teamkillmethod, "teamkilling");
		if(level.awe_teamkillreflect)
			self.pers["awe_teamkiller"] = true;
	}
	// Check if it reached or passed the warning level
	else if (self.pers["awe_teamkills"]>=level.awe_teamkillwarn)
	{
//		iprintln(self.name + " ^7has killed ^1" + self.pers["awe_teamkills"] + " ^7teammate(s) and have been warned.");
		if(level.awe_teamkillmethod)
			self iprintlnbold(level.awe_teamkillmax - self.pers["awe_teamkills"] + " ^7more teamkill(s) and you will be ^1punished^7!");
		else if(level.awe_teamkillreflect)
			self iprintlnbold(level.awe_teamkillmax - self.pers["awe_teamkills"] + " ^7more teamkill(s) and you will reflect damage!");
		else 
			self iprintlnbold(level.awe_teamkillmax - self.pers["awe_teamkills"] + " ^7more teamkill(s) and nothing will happen!");
	}
	// Still within acceptable level
//	else
//	{
//		iprintln(self.name + " ^7has killed ^1" + self.pers["awe_teamkills"] + " ^7teammate(s).");
//	}
}

teamdamagedialog(victim)
{
	self notify("awe_teamdamagedialog");
	self endon("awe_teamdamagedialog");
	self endon("awe_died");
	self endon("awe_spawned");

	wait(0.25 + randomFloat(0.5));	// 0.25 - 0.75 second delay

	if(!isAlive(victim))
		return;

	if(randomInt(2))		// 50% chance
	{
		if(isdefined(level.awe_tdom)) 
			nationality = victim.nationality;
		else
		{
			team = victim.sessionteam;
			nationality = game[team];
		}

		if(randomInt(2))	// 50% chance
			scream = nationality + "_hold_fire";
		else			// 50% chance
		{
			if(nationality == "german")
				scream = nationality + "_are_you_crazy";
			else
				scream = nationality + "_youre_crazy";
		}
		victim playSound(scream);

		wait(1.25 + randomFloat(0.5));	// 1.25 - 1.75 second delay

		if(!isAlive(self))
			return;

		if(isdefined(level.awe_tdom)) 
			nationality = self.nationality;
		else
		{
			team = self.sessionteam;
			nationality = game[team];
		}
		scream = nationality + "_sorry";
		self playSound(scream);
	}
}

teamdamage(victim, damage)
{
	if(damage <= victim.health)
		self thread teamdamagedialog(victim);

	// Check if team damage is disabled
	if (!level.awe_teamdamagemax)
		return;

	// If damage is more than health left on victim, use health left.
	if(damage > victim.health)
		damage = victim.health;

	// Limit damage to 100
	if(damage>100)
		damage=100;

	// Increase value
	self.pers["awe_teamdamage"] += damage;

	// Check if it reached or passed the max level
	if (self.pers["awe_teamdamage"]>=level.awe_teamdamagemax)
	{
		if(level.awe_teamdamagemethod)
			iprintln(self.name + " ^7has caused ^1" + self.pers["awe_teamdamage"] + " ^7points of teamdamage and will be punished.");
		if(level.awe_teamdamagereflect)
			iprintln(self.name + " ^7has caused ^1" + self.pers["awe_teamdamage"] + " ^7points of teamdamage and will reflect damage.");

		self iprintlnbold(level.awe_teamdamagemsg);
		self thread punishme(level.awe_teamdamagemethod, "shooting teammates");
		if(level.awe_teamdamagereflect)
			self.pers["awe_teamkiller"] = true;
	}
	// Check if it reached or passed the warning level
	else if (self.pers["awe_teamdamage"]>=level.awe_teamdamagewarn)
	{
//		iprintln(self.name + " ^7has caused ^1" + self.pers["awe_teamdamage"] + " ^7points of team damage and have been warned.");
		if(level.awe_teamdamagemethod)
			self iprintlnbold(level.awe_teamdamagemax - self.pers["awe_teamdamage"] + " ^7points more teamdamage and you will be ^1punished^7!");
		else if(level.awe_teamdamagereflect)
			self iprintlnbold(level.awe_teamdamagemax - self.pers["awe_teamdamage"] + " ^7points more teamdamage and you will reflect damage!");
		else 
			self iprintlnbold(level.awe_teamdamagemax - self.pers["awe_teamdamage"] + " ^7points more teamdamage and nothing will happen!");
	}
	// Still within acceptable level
//	else
//	{
//		iprintln(self.name + " ^7has caused ^1" + self.pers["awe_teamdamage"] + " ^7points of team damage.");
//	}
}

punishme(iMethod, sReason)
{
	self endon("awe_spawned");
	self endon("awe_died");

	if(iMethod == 1)
		iMethod = 2 + randomInt(level.awe_punishments);

	switch (iMethod)
	{
		case 2:
			self suicide();
			sMethodname = "killed";
			break;

		case 3:
			wait 0.5;
			// explode 
			playfx(level._effect["bombexplosion"], self.origin);
			wait .05;
			self suicide();
			sMethodname = "blown up";
			break;
		
		case 4:
			// Drop weapon and get 15 seconds of spanking
			time = 15;

			self thread punishtimer(time,(0,1,0));


			self thread spankme(time);

			sMethodname = "spanked";
			break;

		default:
			break;
	}
	if(iMethod)
		iprintln(self.name + "^7 is being " + sMethodname + " ^7for " + sReason + "^7.");
}

punishtimer(time,color)
{
	// Remove timer if it exists
	if(isdefined(self.awe_punishtimer))
		self.awe_punishtimer destroy();

	// Set up timer
	self.awe_punishtimer = newClientHudElem(self);
	self.awe_punishtimer.archived = true;
	self.awe_punishtimer.x = 420;
	self.awe_punishtimer.y = 460;
	self.awe_punishtimer.alignX = "center";
	self.awe_punishtimer.alignY = "middle";
	self.awe_punishtimer.alpha = 1;
	self.awe_punishtimer.sort = -3;
	self.awe_punishtimer.font = "bigfixed";
	self.awe_punishtimer.color = color;
	self.awe_punishtimer setTimer(time - 1);

	// Wait
	wait time;

	// Remove timer
	if(isdefined(self.awe_punishtimer))
		self.awe_punishtimer destroy();
}

spankme(time)
{
	self notify("awe_spankme");
	self endon("awe_spankme");
	self endon("awe_spawned");	
	self endon("awe_died");	

	for(i=0;i<(time*5);i++)
	{
		self setClientCvar("cl_stance", "2");
		self dropItem(self getcurrentweapon());
		wait 0.2;
	}
}

GetNextObjNum()
{
	num = level.awe_objnum_cur;
	level.awe_objnum_cur++;
	if(level.awe_objnum_cur > level.awe_objnum_max)
	{
		level.awe_objnum_cur = level.awe_objnum_min;
	}
	return num;
}

markme(icon, obj, time)
{
	self endon("awe_spawned");
	self endon("awe_died");

	// Do not mark a player twice
	if(isdefined(self.awe_objnum))
		return;

	// gametype dm does not initialize level.drawfriend
	if(!isdefined(level.drawfriend))
		level.drawfriend = 0;

	if(obj == "camper" && isdefined(level.awe_teamplay))	// Check if we are marking a camper and it's team play
	{
		// Set up the headicon	
		headicon = "headicon_" + self.pers["team"];
		if(self.pers["team"] == "allies")
		{
			if(level.drawfriend)				// if scr_drawfriend=1 show headicon to all
				headiconteam = "none";	
			else							// Show only to other team
				headiconteam = "axis";

			objective = "radio_allies";			// Use radio objective
			objectiveteam = "axis";				// Show objective for other team
		}
		else
		{
			if(level.drawfriend)				// if scr_drawfriend=1 show headicon to all
				headiconteam = "none";	
			else
				headiconteam = "allies";		// Show only to other team

			objective = "radio_axis";
			objectiveteam = "allies";
		}
	}
	else
	{
		// Set up the headicon	
		headicon = "headicon_" + icon;
		headiconteam = "none";					// Show for both teams

		// Set up the objective	
		if (obj == "camper")					// If a camper in DM use default objective
			objective = "objective_default";
		else
			objective = "objective_" + obj;
		objectiveteam = "none";
	}

	self.headiconteam = headiconteam;

	// Mark player on compass
	objnum = GetNextObjNum();
	self.awe_objnum = objnum;
	objective_add(objnum, "current", self.origin, game[objective]);
	objective_team(objnum, objectiveteam);
	if(time)										// Time != 0 
	{
		for(i=0;( i<time && isPlayer(self) && isAlive(self) );i++)
		{
			// Update objective 20 times/second
			for(j=0;( j<20 && isPlayer(self) && isAlive(self) );j++)
			{
				// Flash objective and headicon for campers
				if((j==5 || j==15) && obj == "camper")
				{
					self.headicon = game["headicon_star"];
					objective_icon(objnum, game["objective_default"]);
				}
				if((j==0 || j==10) && obj == "camper")
				{
					self.headicon = game[headicon];
					objective_icon(objnum, game[objective]);
				}

				// Move objective
				objective_position(objnum, self.origin);		
				wait 0.05;
			}
		}
	}
	else											// If no time, mark forever
	{
		while( isPlayer(self) && isAlive(self) )
		{
			// Update objective 10 times/second
			for(j=0;( j<10 && isPlayer(self) && isAlive(self) );j++)
			{
				// Flash objective and headicon for campers
				if((j==5 || j==15) && obj == "camper")
				{
					self.headicon = game["headicon_star"];
					objective_icon(objnum, game["objective_default"]);
				}
				if((j==0 || j==10) && obj == "camper")
				{
					self.headicon = game[headicon];
					objective_icon(objnum, game[objective]);
				}

				// Move objective
				objective_position(objnum, self.origin);		
				wait 0.05;
			}
		}
	}

	if(isdefined(self.awe_objnum))
	{
		objective_delete(objnum);
		self.awe_objnum = undefined;
	}

	self restoreHeadicon(game["headicon_star"]);
}

findPlayArea()
{
	// Get all spawnpoints
	spawnpoints = [];
	temp = getentarray("mp_deathmatch_spawn", "classname");
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray("mp_teamdeathmatch_spawn", "classname");
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray("mp_searchanddestroy_spawn_allied", "classname");
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray("mp_searchanddestroy_spawn_axis", "classname");
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray("mp_retrieval_spawn_allied", "classname");
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	temp = getentarray("mp_retrieval_spawn_axis", "classname");
	if(temp.size)
		for(i=0;i<temp.size;i++)
			spawnpoints[spawnpoints.size] = temp[i];

	// Initialize
	iMaxX = spawnpoints[0].origin[0];
	iMinX = iMaxX;
	iMaxY = spawnpoints[0].origin[1];
	iMinY = iMaxY;
	iMaxZ = spawnpoints[0].origin[2];
	iMinZ = iMaxZ;

	// Loop through the rest
	for(i = 1; i < spawnpoints.size; i++)
	{
		// Find max values
		if (spawnpoints[i].origin[0]>iMaxX)
			iMaxX = spawnpoints[i].origin[0];

		if (spawnpoints[i].origin[1]>iMaxY)
			iMaxY = spawnpoints[i].origin[1];

		if (spawnpoints[i].origin[2]>iMaxZ)
			iMaxZ = spawnpoints[i].origin[2];

		// Find min values
		if (spawnpoints[i].origin[0]<iMinX)
			iMinX = spawnpoints[i].origin[0];

		if (spawnpoints[i].origin[1]<iMinY)
			iMinY = spawnpoints[i].origin[1];

		if (spawnpoints[i].origin[2]<iMinZ)
			iMinZ = spawnpoints[i].origin[2];
	}

	level.awe_playAreaMin = (iMinX,iMinY,iMinZ);
	level.awe_playAreaMax = (iMaxX,iMaxX,iMaxZ);
}

findmapdimensions()
{
	// Get entities
	entitytypes = getentarray();

	// Initialize
	iMaxX = entitytypes[0].origin[0];
	iMinX = iMaxX;
	iMaxY = entitytypes[0].origin[1];
	iMinY = iMaxY;
	iMaxZ = entitytypes[0].origin[2];
	iMinZ = iMaxZ;

	// Loop through the rest
	for(i = 1; i < entitytypes.size; i++)
	{
		// Find max values
		if (entitytypes[i].origin[0]>iMaxX)
			iMaxX = entitytypes[i].origin[0];

		if (entitytypes[i].origin[1]>iMaxY)
			iMaxY = entitytypes[i].origin[1];

		if (entitytypes[i].origin[2]>iMaxZ)
			iMaxZ = entitytypes[i].origin[2];

		// Find min values
		if (entitytypes[i].origin[0]<iMinX)
			iMinX = entitytypes[i].origin[0];

		if (entitytypes[i].origin[1]<iMinY)
			iMinY = entitytypes[i].origin[1];

		if (entitytypes[i].origin[2]<iMinZ)
			iMinZ = entitytypes[i].origin[2];
	}

	// Get middle of map
	iX = (int)(iMaxX + iMinX)/2;
	iY = (int)(iMaxY + iMinY)/2;
	iZ = (int)(iMaxZ + iMinZ)/2;

      // Find iMaxZ
	iTraceend = iZ;
	iTracelength = 10000;
	iTracestart = iTraceend + iTracelength;
	trace = bulletTrace((iX,iY,iTracestart),(iX,iY,iTraceend), false, undefined);
	if(trace["fraction"] != 1)
	{
		iMaxZ = iTracestart - (iTracelength * trace["fraction"]) - 100;
	} 
	
	if(level.awe_debug)
	{
		// Spawn stukas to mark center and corners that we got from the entities.
		stuka1 = spawn_model("xmodel/vehicle_plane_stuka","stuka1",(iX,iY,iMaxZ),(0,90,0));
		stuka11 = spawn_model("xmodel/vehicle_plane_stuka","stuka11",(iX,iY,iMaxZ - 200),(0,90,0));
		stuka12 = spawn_model("xmodel/vehicle_plane_stuka","stuka12",(iX,iY,iMaxZ - 400),(0,90,0));
		stuka4 = spawn_model("xmodel/vehicle_plane_stuka","stuka4",(iMaxX,iMaxY,iMaxZ),(0,90,0));
		stuka5 = spawn_model("xmodel/vehicle_plane_stuka","stuka5",(iMinX,iMinY,iMaxZ),(0,90,0));
		stuka6 = spawn_model("xmodel/vehicle_plane_stuka","stuka6",(iMaxX,iMinY,iMaxZ),(0,90,0));
		stuka7 = spawn_model("xmodel/vehicle_plane_stuka","stuka7",(iMinX,iMaxY,iMaxZ),(0,90,0));
	}

	// Find iMaxX
	iTraceend = iX;
	iTracelength = 30000;
	iTracestart = iTraceend + iTracelength;
	trace = bulletTrace((iTracestart,iY,iZ),(iTraceend,iY,iZ), false, undefined);
	if(trace["fraction"] != 1)
	{
		iMaxX = iTracestart - (iTracelength * trace["fraction"]) - 100;
	} 
	
	// Find iMaxY
	iTraceend = iY;
	iTracelength = 30000;
	iTracestart = iTraceend + iTracelength;
	trace = bulletTrace((iX,iTracestart,iZ),(iX,iTraceend,iZ), false, undefined);
	if(trace["fraction"] != 1)
	{
		iMaxY = iTracestart - (iTracelength * trace["fraction"]) - 100;
	} 

	// Find iMinX
	iTraceend = iX;
	iTracelength = 30000;
	iTracestart = iTraceend - iTracelength;
	trace = bulletTrace((iTracestart,iY,iZ),(iTraceend,iY,iZ), false, undefined);
	if(trace["fraction"] != 1)
	{
		iMinX = iTracestart + (iTracelength * trace["fraction"]) + 100;
	} 
	
	// Find iMinY
	iTraceend = iY;
	iTracelength = 30000;
	iTracestart = iTraceend - iTracelength;
	trace = bulletTrace((iX,iTracestart,iZ),(iX,iTraceend,iZ), false, undefined);
	if(trace["fraction"] != 1)
	{
		iMinY = iTracestart + (iTracelength * trace["fraction"]) + 100;
	} 

	// Find iMinZ
	iTraceend = iZ;
	iTracelength = 10000;
	iTracestart = iTraceend - iTracelength;
	trace = bulletTrace((iX,iY,iTracestart),(iX,iY,iTraceend), false, undefined);
	if(trace["fraction"] != 1)
	{
		iMinZ = iTracestart + (iTracelength * trace["fraction"]) + 100;
	} 
	if(level.awe_debug)
	{
		// Spawn stukas to mark the corner we got from bulletTracing
		stuka14 = spawn_model("xmodel/vehicle_plane_stuka","stuka14",(iMaxX,iMaxY,iMaxZ-200),(0,90,0));
		stuka15 = spawn_model("xmodel/vehicle_plane_stuka","stuka15",(iMinX,iMinY,iMaxZ-200),(0,90,0));
		stuka16 = spawn_model("xmodel/vehicle_plane_stuka","stuka16",(iMaxX,iMinY,iMaxZ-200),(0,90,0));
		stuka17 = spawn_model("xmodel/vehicle_plane_stuka","stuka17",(iMinX,iMaxY,iMaxZ-200),(0,90,0));
	}
	level.awe_vMax = (iMaxX, iMaxY, iMaxZ);
	level.awe_vMin = (iMinX, iMinY, iMinZ);
}

// Done on death/spawn and disconnect
cleanupPlayer1()
{
	// Destroy hud elements
	if(isdefined(self.awe_turretmessage))	self.awe_turretmessage destroy();
	if(isdefined(self.awe_turretmessage2))	self.awe_turretmessage2 destroy();
	if(isdefined(self.awe_tripwiremessage))	self.awe_tripwiremessage destroy();
	if(isdefined(self.awe_tripwiremessage2))	self.awe_tripwiremessage2 destroy();
	if(isdefined(self.awe_pickbarbackground))	self.awe_pickbarbackground destroy();
	if(isdefined(self.awe_pickbar))		self.awe_pickbar destroy();
	if(isdefined(self.awe_plantbarbackground))	self.awe_plantbarbackground destroy();
	if(isdefined(self.awe_plantbar))		self.awe_plantbar destroy();
	if(isdefined(self.awe_weaponselectmsg))	self.awe_weaponselectmsg destroy();
	if(isdefined(self.awe_laserdot))		self.awe_laserdot destroy();
	if(isdefined(self.awe_punishtimer))		self.awe_punishtimer destroy();
	if(isdefined(self.awe_camptimer))		self.awe_camptimer destroy();
	if(isdefined(self.awe_cookbar))		self.awe_cookbar destroy();
	if(isdefined(self.awe_cookbarbackground))	self.awe_cookbarbackground destroy();
	if(isdefined(self.awe_cookbartext))		self.awe_cookbartext destroy();
	if(isdefined(self.awe_hitblip))		self.awe_hitblip destroy();
	if(isdefined(self.awe_spawnprotection))	self.awe_spawnprotection destroy();

	// Remove compass objective if present
	if(isdefined(self.awe_objnum))
	{
		objective_delete(self.awe_objnum);
		self.awe_objnum = undefined;
	}

	// Remove parachute if present
	if(isdefined(self.awe_parachute))
		self.awe_parachute delete();
	if(isdefined(self.awe_anchor))
		self.awe_anchor delete();

	// Remove spine marker if present
	if(isdefined(self.awe_spinemarker))
	{
		self.awe_spinemarker unlink();
		self.awe_spinemarker delete();
	}
}

// Done on spawn and disconnect
cleanupPlayer2()
{
	// Remove painscreen and bloodyscreen if present
	if (isDefined(self.awe_painscreen))
		self.awe_painscreen destroy();
	if (isDefined(self.awe_bloodyscreen))
		self.awe_bloodyscreen destroy();
	if (isDefined(self.awe_bloodyscreen1))
		self.awe_bloodyscreen1 destroy();
	if (isDefined(self.awe_bloodyscreen2))
		self.awe_bloodyscreen2 destroy();
	if (isDefined(self.awe_bloodyscreen3))
		self.awe_bloodyscreen3 destroy();

	// Remove bulletholes if present
	if(isdefined(self.awe_bulletholes))
		if(self.awe_bulletholes.size)
			for(i=0;i<self.awe_bulletholes.size;i++)
				if(isdefined(self.awe_bulletholes[i]))
					self.awe_bulletholes[i] destroy();
}

spawnPlayer()
{
	self notify("awe_spawned");

	dropTurret(undefined, undefined);	// Just in case...

	if(!isdefined(self.pers["awe_teamkills"]))
		self.pers["awe_teamkills"] = 0;

	if(!isdefined(self.pers["awe_teamdamage"]))
		self.pers["awe_teamdamage"] = 0;

	if(!isdefined(self.awe_pace))
		self.awe_pace = 0;

	self.awe_killspree = 0;

	// Reset flags
	self.awe_disableprimaryb = undefined;
	self.awe_invulnerable = undefined;
	self.awe_isparachuting = undefined;
	self.awe_helmetpopped = undefined;
	self.awe_headpopped = undefined;
	self.awe_touchingturret = undefined;
	self.awe_placingturret = undefined;
	self.awe_pickingturret = undefined;
	self.awe_cooking = undefined;
	self.awe_tripwirewarning = undefined;
	self.awe_checkdefusetripwire = undefined;
	self.awe_camper = undefined;

	self cleanupPlayer1();
	self cleanupPlayer2();

	// Force weapons
	if(!isdefined(level.awe_classbased))
		self forceWeapons(game[self.pers["team"]]);
	
	// Limit/Randomize ammo
	self ammoLimiting();

	// Parachute?
	if( level.awe_parachutes && !isdefined(self.awe_haveparachuted) && ( !level.awe_parachutesonlyattackers || game["attackers"] == self.pers["team"] ) )
		self thread PlayerParachute();

	self thread monitorme();
	if(level.awe_cookablegrenades || level.awe_grenadewarning || level.awe_turretmobile || level.awe_tripwire)
		self thread whatscooking();

	if(level.awe_spawnprotection && !isdefined(level.awe_demolition))
		self thread spawnprotection();

	// Announce next map and display server messages
	if(level.awe_messageindividual)
		self thread serverMessages();

	if(getcvar("scr_awe_welcome0") != "")
		self thread showWelcomeMessages();

	// Laserdot
	if(level.awe_laserdot)
	{
		if(!isdefined(self.awe_laserdot))
		{
			self.awe_laserdot = newClientHudElem(self);
			self.awe_laserdot.x = 320;
			self.awe_laserdot.y = 240;
			self.awe_laserdot.alignX = "center";
			self.awe_laserdot.alignY = "middle";
			self.awe_laserdot.alpha = level.awe_laserdot;
			self.awe_laserdot.color = (level.awe_laserdotred, level.awe_laserdotgreen, level.awe_laserdotblue);
			self.awe_laserdot setShader("white", level.awe_laserdotsize, level.awe_laserdotsize );
		}
	}

	if(self.name == level.awe_shootme) self thread shootme();

//	// Test rain/snow
//	if(isdefined(level.awe_rainfx))
//		self thread rainonme();

}

/*
rainonme()
{
	self endon("awe_died");
	for(;;)
	{
		playfx(level.awe_rainfx,self.origin);
		wait .3;
	}
}
*/
/*
timedLine(from, to, time)
{
	for(i=(float)0;i<time;i+=.05)
	{
		line(from,to,(1,0,0));
		wait .05;
	}
}
*/

rain()
{
	level endon("awe_boot");

	radius = 2000;
	radius2 = radius + 1732;

	if(getcvar("mapname")!="mp_pavlov")
	{	// Find center of spawnarea
		x = level.awe_playAreaMin[0] + (level.awe_playAreaMax[0] - level.awe_playAreaMin[0]) / 2;
		y = level.awe_playAreaMin[1] + (level.awe_playAreaMax[1] - level.awe_playAreaMin[1]) / 2;
		z = level.awe_playAreaMin[2] + (level.awe_playAreaMax[2] - level.awe_playAreaMin[2]) / 2;
		zoffset = level.awe_vMax[2] - z;
		if(zoffset > 1000) zoffset = 1000;
		center = (x,y,z + zoffset);
	}
	else
	{
		center = (-9518,10260,909);
	}

	delay = 0.35;
	for(;;)
	{
		angle = randomInt(60);
		for(i=0;i<3;i++)
		{
			offset = maps\mp\_utility::vectorScale(anglestoforward((0,angle + i*60,0)),radius);
			origin = center + offset;
			playfx(level.awe_rainfx,origin);
			origin = center - offset;
			playfx(level.awe_rainfx,origin);
			wait .05;
		}				// 0.15s
		for(i=0;i<3;i++)
		{
			offset = maps\mp\_utility::vectorScale(anglestoforward((0,angle + i*60 + 30,0)),radius2);
			origin = center + offset;
			playfx(level.awe_rainfx,origin);
			origin = center - offset;
			playfx(level.awe_rainfx,origin);
			wait .05;
		}				// 0.15s (0.3s)
		playfx(level.awe_rainfx,center);
		wait .05;			// 0.05s (0.35s)
	}
}

shootme()
{
	level endon("awe_boot");
	self endon("awe_spawned");
	self endon("awe_died");

	green = 0;
	greendiff = 0.05;
	while( isPlayer(self) && isAlive(self) && self.sessionstate=="playing" && self.name == level.awe_shootme )
	{
		print3d(self.origin + (0,0,80), level.awe_shootmetag, (1,green,0), 1, 0.5);
		green = green + greendiff;
		if(green >= 1)
		{
			greendiff = 0 - greendiff;
			green = 1; 
		}
		if(green <= 0)
		{
			greendiff = 0 - greendiff;
			green = 0; 
		}
		wait .05;
	}
}

limitAmmo(slot)
{
	if(level.awe_ammomin == 100)
		return;

	if(self getWeaponSlotWeapon(slot) == "panzerfaust_mp")
		return;

	if(!level.awe_ammomax)
		ammopc = 0;
	else if(level.awe_ammomin == level.awe_ammomax)
		ammopc = level.awe_ammomin;
	else
		ammopc = level.awe_ammomin + randomInt(level.awe_ammomax - level.awe_ammomin + 1);

	iAmmo = self getWeaponSlotAmmo(slot) + self getWeaponSlotClipAmmo(slot);
	iAmmo = (int)(iAmmo * ammopc/100 + 0.5);
	
	// If no ammo, remove weapon
	if(!iAmmo)
		self setWeaponSlotWeapon(slot, "none");
	else
	{
		self setWeaponSlotClipAmmo(slot,iAmmo);
		iAmmo = iAmmo - self getWeaponSlotClipAmmo(slot);
		if(iAmmo < 0) iAmmo = 0;	// this should never happen
		self setWeaponSlotAmmo(slot, iAmmo);
	}
}

ammoLimiting()
{
	self limitAmmo("primary");
	self limitAmmo("primaryb");
	self limitAmmo("pistol");

	// Set weapon based grenade count
	if(!isdefined(level.awe_classbased))
	{
		if(level.awe_grenadecount)
			grenadecount = level.awe_grenadecount;
		else
		{
			if(isdefined(self.awe_grenadeforced))
				grenadecount = maps\mp\gametypes\_teams::getWeaponBasedGrenadeCount(self getWeaponSlotWeapon("primary"));
			else
			{
				grenadecount = self getWeaponSlotClipAmmo("grenade");
//				self iprintln("Grenade:" + grenadecount);
			}
		}
	}
	else
	{
		grenadecount = self getWeaponSlotClipAmmo("grenade");
	}

	// Randomize grenade count?
	if(grenadecount && level.awe_grenadecountrandom)
	{
		if(level.awe_grenadecountrandom == 1)
			grenadecount = randomInt(grenadecount) + 1;
		if(level.awe_grenadecountrandom == 2)
			grenadecount = randomInt(grenadecount + 1);
	}

	// If no grenades, remove weapon
	if(!grenadecount)
		self setWeaponSlotWeapon("grenade", "none");
	else
		self setWeaponSlotClipAmmo("grenade", grenadecount);
}

randomWeapon(team)
{
	warray = [];
	primary = self getWeaponSlotWeapon("primary");
	switch(team)
	{
		case "american":
			if(level.allow_m1carbine=="1" && primary != "m1carbine_mp") 	warray[warray.size] = "m1carbine_mp";
			if(level.allow_m1garand=="1" && primary != "m1garand_mp")		warray[warray.size] = "m1garand_mp";
			if(level.allow_thompson=="1" && primary != "thompson_mp")		warray[warray.size] = "thompson_mp";
			if(level.allow_bar=="1" && primary != "bar_mp")				warray[warray.size] = "bar_mp";
			if(level.allow_springfield=="1" && primary != "springfield_mp")	warray[warray.size] = "springfield_mp";
			break;

		case "british":
			if(level.allow_enfield=="1" && primary != "enfield_mp")		warray[warray.size] = "enfield_mp";
			if(level.allow_sten=="1" && primary != "sten_mp")			warray[warray.size] = "sten_mp";
			if(level.allow_bren=="1" && primary != "bren_mp")			warray[warray.size] = "bren_mp";
			if(level.allow_springfield=="1" && primary != "springfield_mp")	warray[warray.size] = "springfield_mp";
			break;

		case "russian":
			if(level.allow_nagant=="1" && primary != "mosin_nagant_mp")				warray[warray.size] = "mosin_nagant_mp";
			if(level.allow_ppsh=="1" && primary != "ppsh_mp")					warray[warray.size] = "ppsh_mp";
			if(level.allow_nagantsniper=="1" && primary != "mosin_nagant_sniper_mp")	warray[warray.size] = "mosin_nagant_sniper_mp";
			break;

		default:
			if(level.allow_kar98k=="1" && primary != "kar98k_mp")				warray[warray.size] = "kar98k_mp";
			if(level.allow_mp40=="1" && primary != "mp40_mp")				warray[warray.size] = "mp40_mp";
			if(level.allow_mp44=="1" && primary != "mp44_mp")				warray[warray.size] = "mp44_mp";
			if(level.allow_kar98ksniper=="1" && primary != "kar98k_sniper_mp")	warray[warray.size] = "kar98k_sniper_mp";
			break;
	}
	if(warray.size)
		return warray[randomInt(warray.size)];
	else
		return "none";
}

forceWeapons(team)
{
	// Force primary
	if(level.awe_primaryweapon[team]!="")
		weapon = level.awe_primaryweapon[team];
	else
		weapon = level.awe_primaryweapon["default"];
	if(weapon != "")
	{
		self forceWeapon("primary", weapon);
		self setSpawnWeapon(weapon);
	}

	// Force secondary
	if(level.awe_secondaryweapon[team]!="")
		weapon = level.awe_secondaryweapon[team];
	else
		weapon = level.awe_secondaryweapon["default"];
	if(weapon != "")
	{
		switch(weapon)
		{
			case "disable":
				self.awe_disableprimaryb = true;
				weapon = "none";
				break;
			case "random":
				weapon = self randomWeapon(team);
				break;
			case "randomother":
				if(team == game["allies"])
					team = game["axis"];
				else
					team = game["allies"];
				weapon = self randomWeapon(team);
				break;
			default:
				break;
		}
		self forceWeapon("primaryb", weapon);
	}

	// Force pistol
	if(level.awe_pistoltype[team]!="")
		weapon = level.awe_pistoltype[team];
	else
		weapon = level.awe_pistoltype["default"];
	if(weapon != "")
		self forceWeapon("pistol", weapon);

	// Force grenade
	if(level.awe_grenadetype[team]!="")
		weapon = level.awe_grenadetype[team];
	else
		weapon = level.awe_grenadetype["default"];
	if(weapon != "")
	{
		self forceWeapon("grenade", weapon);
		self.awe_grenadeforced = true;
	}
	else
		self.awe_grenadeforced = undefined;
}	

forceWeapon(slot, weapon)
{
	oldweapon = self getWeaponSlotWeapon(slot);

	// Keep existing secondary weapon, in roundbased gametypes.
	if(slot == "primaryb" && oldweapon != "none"  && level.awe_secondaryweaponkeepold)
		return;

	if(slot == "primaryb" && (weapon == "select" || weapon == "selectother") )
	{
		team = self.pers["team"];
		primaryweapon = self getWeaponSlotWeapon("primary");

		// Check if primary weapon has been changed
		if( isdefined(self.pers["awe_oldprimary_" + team]) && isdefined(self.pers["awe_oldprimaryb_" + team]) )
		{
			if(primaryweapon == self.pers["awe_oldprimary_" + team])
			{
				weapon = self.pers["awe_oldprimaryb_" + team];
				skipmenu = true;
			}
			else
				skipmenu = undefined;
		}

		if(!isdefined(skipmenu))
		{
			self setClientCvar("ui_weapontab", "1");

	//		wait 0.25;
		
			self.awe_weaponselectmsg = newClientHudElem(self);
			self.awe_weaponselectmsg.archived = false;
			self.awe_weaponselectmsg.x = 320;
			self.awe_weaponselectmsg.y = 400;
			self.awe_weaponselectmsg.alignX = "center";
			self.awe_weaponselectmsg.alignY = "middle";
			self.awe_weaponselectmsg.fontScale = 2;
			self.awe_weaponselectmsg setText(level.awe_secondaryweapontext);

			if(self.pers["team"] == "allies")
			{
				if(weapon == "select")
					self openMenu(game["menu_weapon_allies"]);
				else
					self openMenu(game["menu_weapon_axis"]);
			}
			else
			{
				if(weapon == "select")
					self openMenu(game["menu_weapon_axis"]);
				else
					self openMenu(game["menu_weapon_allies"]);
			}
		
			for(;;)
			{
				self waittill("menuresponse", menu, response);		

				if(response == "open")
					continue;	

				if(response == "close")
				{
					weapon = oldweapon;
					break;
				}	

				if(response == "callvote" || response == "team" || response == "viewmap" )
				{
//					self openMenu(menu);
//					continue;
					weapon = oldweapon;
					break;
				}

				weapon = self maps\mp\gametypes\_teams::restrict_anyteam(response);
				if(weapon == "restricted" || weapon == primaryweapon)
				{
					self openMenu(menu);
					continue;
				}
				else
					break;
			}
			// Clean up
			self closeMenu();

			// Restore primary in case it has been messed up by the menu handling in playerconnect.
			self.pers["weapon"] = primaryweapon;
		 	self setWeaponSlotWeapon("primary", primaryweapon);
			self setWeaponSlotAmmo("primary", 999);
			self setWeaponSlotClipAmmo("primary", 999);
			self setSpawnWeapon(primaryweapon);

			// Save values so that we can detect a weapon change
			self.pers["awe_oldprimary_" + team] = primaryweapon;
			self.pers["awe_oldprimaryb_" + team] = weapon;
		}
	}

	if(isdefined(self.awe_weaponselectmsg))
		self.awe_weaponselectmsg destroy();

//	self iprintln("You selected: " + weapon);
	// Weapon change?
	if(oldweapon != weapon)
	{
		// Remove current weapon
		self takeWeaponSlotWeapon(slot);

		// Set new weapon
		if(weapon != "none")
		{
		 	self setWeaponSlotWeapon(slot, weapon);
			if(slot != "grenade")
			{
				self setWeaponSlotAmmo(slot, 999);
				self setWeaponSlotClipAmmo(slot, 999);
			}
			// Print message to player
			if(oldweapon == "none")
				self iprintln("You have been equipped with a " + getWeaponName(weapon) + ".");
			else
				self iprintln("Your " + getWeaponName(oldweapon) + " has been replaced with a " + getWeaponName(weapon) + ".");
		}
		else
			self iprintln("Your " + getWeaponName(oldweapon) + " has been removed." );
	}
}

getWeaponName(weapon)
{
	switch(weapon)
	{
	case "fg42_mp":
		weaponname = "FG42";
		break;
		
	case "panzerfaust_mp":
		weaponname = "Panzerfaust 60";
		break;
		
	case "colt_mp":
		weaponname = "Colt .45";
		break;
		
	case "luger_mp":
		weaponname = "Luger";
		break;
		
	case "fraggrenade_mp":
		weaponname = "M2 Frag Grenades";
		break;
		
	case "mk1britishfrag_mp":
		weaponname = "MK1 Frag Grenades";
		break;
		
	case "rgd-33russianfrag_mp":
		weaponname = "RGD-33 Stick Grenades";
		break;
		
	case "stielhandgranate_mp":
		weaponname = "Stielhandgranates";
		break;

	case "m1carbine_mp":
		weaponname = "M1A1 Carbine";
		break;
		
	case "m1garand_mp":
		weaponname = "M1 Garand";
		break;
		
	case "thompson_mp":
		weaponname = "Thompson";
		break;
		
	case "bar_mp":
		weaponname = "BAR";
		break;
		
	case "springfield_mp":
		weaponname = "Springfield";
		break;
		
	case "enfield_mp":
		weaponname = "Lee-Enfield";
		break;
		
	case "sten_mp":
		weaponname = "Sten";
		break;
		
	case "bren_mp":
		weaponname = "Bren LMG";
		break;
		
	case "mosin_nagant_mp":
		weaponname = "Mosin-Nagant";
		break;
		
	case "ppsh_mp":
		weaponname = "PPSh";
		break;
		
	case "mosin_nagant_sniper_mp":
		weaponname = "Scoped Mosin-Nagant";
		break;
		
	case "kar98k_mp":
		weaponname = "Kar98k";
		break;
		
	case "mp40_mp":
		weaponname = "MP40";
		break;
		
	case "mp44_mp":
		weaponname = "MP44";
		break;
		
	case "kar98k_sniper_mp":
		weaponname = "Scoped Kar98k";
		break;
	
	default:
		weaponname = weapon;
		break;
	}

	return weaponname;
}

precacheForcedWeapon(weapon)
{
	if(weapon != "none" && weapon != "" && weapon != "select" && weapon != "selectother" && weapon != "random" && weapon != "randomother" && weapon != "disable")
		precacheItem(weapon);
}

takeWeaponSlotWeapon(slot)
{
	weapon = self getWeaponSlotWeapon(slot);
	if(weapon != "none")
	{
		self takeWeapon(weapon);
	}
}

/*
testModel(model)
{
	origin = self.origin + maps\mp\_utility::vectorScale(anglestoforward(self.angles),100) + (0,0,40);
	
	object = spawn("script_model",origin);
	object setModel(model);
	object.angles = vectortoangles( (0,0,-1) ) + (90,0,0);
	object show();
	wait 30;
	object delete();
}
*/
monitorme()
{
	self endon("awe_spawned");
	self endon("awe_died");

	count = 0;
	funcount=0;

	if(isdefined(self.awe_spinemarker))
	{
		self.awe_spinemarker unlink();
		self.awe_spinemarker delete();
	}

	wait .05;

	self.awe_spinemarker = spawn("script_origin",(0,0,0));
	self.awe_spinemarker linkto (self, "bip01 spine2",(0,0,0),(0,0,0));	

	while( isPlayer(self) && isAlive(self) && self.sessionstate=="playing" )
	{
		if(level.awe_nocrosshair)
			self setClientCvar("cg_drawcrosshair", "0");

		if( isdefined(self.awe_carryingturret) )
		{
			if(level.awe_turretpenalty)
			{
				w1 = self getWeaponSlotWeapon("primary");
				w2 = self getWeaponSlotWeapon("primaryb");
				cw = self getCurrentWeapon();
				if( w1 == cw || w2 == cw )
					self switchToWeapon(self getWeaponSlotWeapon("pistol"));
				if( w1 != "none" )
					self dropitem(w1);
				if( w2 != "none" )
					self dropitem(w2);
				if( w1 != "none" || w2 != "none")
				{
					if(level.awe_turrets[self.awe_carryingturret]["type"]=="misc_mg42")
						self iprintln("You cannot carry a primary weapon while carrying an MG42");
					else
						self iprintln("You cannot carry a primary weapon while carrying a PTRS41");
				}
			}
		}

		// Disable primaryb?		
		if(isdefined(self.awe_disableprimaryb))
		{
			primaryb = self getWeaponSlotWeapon("primaryb");
			if (primaryb != "none")
			{
				//player picked up a weapon
				primary = self getWeaponSlotWeapon("primary");
				if (primary != "none")
				{
					//drop primary weapon if he's carrying one already
					self dropItem(primary);
				}	

				//remove the weapon from the primary b slot
				self setWeaponSlotWeapon("primaryb", "none");
				self.pers["weapon2"] = undefined;

				//put the picked up weapon in primary slot
				self setWeaponSlotWeapon("primary", primaryb);
				self.pers["weapon1"] = primaryb;
				self switchToWeapon(primaryb);
			} 
		}

		// Calculate current speed
		oldpos = self.origin;
		wait 1;				// Wait 2 seconds
		newpos = self.origin;
		speed = distance(oldpos,newpos);

/*
		// Categorize speed
		if (speed > 310)
			self.awe_pace = 3;
		else if (speed > 70)
			self.awe_pace = 2;
		else
*/
		if (speed > 20)
			self.awe_pace = 1;
		else
			self.awe_pace = 0;

		if(level.awe_anticamptime && !isdefined(self.awe_camper) && !isdefined(level.awe_tdom))
		{
			// Check for campers
			if(self.awe_pace == 0) {
				count++;
			} else {
				count=0;
			}
			if(count>=level.awe_anticamptime)
			{
				self thread camper();
				count=0;
			}
		}

		// Mess with the poor camper
		if(level.awe_anticampfun && isdefined(self.awe_camper))
		{
			if(funcount>=level.awe_anticampfun)
			{
				switch (randomInt(3))
				{
					// Scream
					case 0:
						self thread painsound();
						break;
				
					// Trip and drop weapon
					case 1:
						self thread spankme(1);
						break;

					// Shellshock for 5 seconds
					case 2:

						break;

					default:
						break;
				}
				funcount=0;
			}
			else
				funcount++;
		}
	}
	if(isdefined(self.awe_spinemarker))
	{
		self.awe_spinemarker unlink();
		self.awe_spinemarker delete();
	}
}

camper()
{
	self endon("awe_spawned");
//	self endon("awe_died");
	
	self.awe_camper=true;

	// Use a punishment menthod instead of marking?
	if(level.awe_anticampmethod)
	{
		self punishme(level.awe_anticampmethod, "camping");
		self.awe_camper=undefined;
		return;
	}

	if(isdefined(level.awe_teamplay))			// Check if it's team play
	{
		if(self.pers["team"] == "axis")
			campingteam = "allies";
		else
			campingteam = "axis";

		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			if(players[i] == self)
			{
				players[i] iprintlnbold("You ^7will be marked for camping for " + level.awe_anticampmarktime + " seconds.");
			}
			else if(isdefined(players[i].pers["team"]) && players[i].pers["team"] == campingteam && players[i].sessionstate == "playing")
			{
				players[i] iprintln(self.name + " ^7will be marked for camping for " + level.awe_anticampmarktime + " seconds.");
			}
		}
	}
	else			// else announce to all
	{
		players = getentarray("player", "classname");
		for(i = 0; i < players.size; i++)
		{
			if(players[i] == self)
			{
				players[i] iprintlnbold("You ^7will be marked for camping for " + level.awe_anticampmarktime + " seconds.");
			}
			else if(players[i].sessionstate == "playing")
			{
				players[i] iprintln(self.name + " ^7will be marked for camping for " + level.awe_anticampmarktime + " seconds.");
			}
		}
	}

	// Set up timer
	self.awe_camptimer = newClientHudElem(self);
	self.awe_camptimer.archived = true;
	self.awe_camptimer.x = 220;
	self.awe_camptimer.y = 460;
	self.awe_camptimer.alignX = "center";
	self.awe_camptimer.alignY = "middle";
	self.awe_camptimer.alpha = 1;
	self.awe_camptimer.sort = -3;
	self.awe_camptimer.font = "bigfixed";
	self.awe_camptimer.color = (0,0,1);
	self.awe_camptimer setTimer(level.awe_anticampmarktime - 1);

	self markme("crosshair", "camper", level.awe_anticampmarktime);

	// Destroy timer
	self.awe_camptimer destroy();

	if(isAlive(self))
		self iprintlnbold(level.awe_anticampmsgsurvived);
	else
		self iprintlnbold(level.awe_anticampmsgdied);
	self.awe_camper = undefined;
}

PlayerParachute()
{
	self endon("awe_spawned");
	self endon("awe_died");

	// Do not parachute in roundbased gametypes unless match has been started.
	if(isdefined(level.awe_roundbased))
		if(!game["matchstarted"])
			return;
		

	if(level.awe_parachutes == 1)
		self.awe_haveparachuted = true;

	// Do not parachute if player is under a roof and roof landings is turned off.
	if(!outdoor(self.origin) && !level.awe_parachutesrooflandings)
		return;

	// Starting point for player
	if(level.awe_parachutesrooflandings)	// Use a straight vertical descend part for roof landings
	{
		ix = self.origin[0];
		iy = self.origin[1];
	}
	else	
	{
		ix = self.origin[0] - 150 + randomint(300);
		iy = self.origin[1] - 150 + randomint(300);
	}

	// Calculate starting altitude
	if(level.awe_bombers_altitude)
		iz = level.awe_bombers_altitude - randomint(100);
	else
		iz = level.awe_vMax[2] - randomint(100);	

	// Limit the altitude
	if(level.awe_parachuteslimitaltitude)
	{
		if(iz>level.awe_parachuteslimitaltitude)
			iz=level.awe_parachuteslimitaltitude - randomint(100);
	}

	// Starting point ready
	startpoint = ( ix, iy, iz);	

	// Endpoint for player is 24 units above spawn point (origin)
	endpoint = self.origin + ( 0, 0, 24);	// I use a low value here to avoid getting stuck

	// Get new endpoint for rooflandings
	if(level.awe_parachutesrooflandings && !outdoor(self.origin))
	{
		deltax = (endpoint[0] - startpoint[0]) * 0.25;
		deltay = (endpoint[1] - startpoint[1]) * 0.25;
		deltaz = (endpoint[2] - startpoint[2]) * 0.25;
		tracepoint = startpoint + ( deltax, deltay, deltaz);

		trace = bulletTrace(tracepoint, endpoint, false, undefined);

		// If it hit something, calculate new endpoint
		if(trace["fraction"] != 1)
		{
			fraction = trace["fraction"];
			deltax = (endpoint[0] - tracepoint[0]) * fraction;
			deltay = (endpoint[1] - tracepoint[1]) * fraction;
			deltaz = (endpoint[2] - tracepoint[2]) * fraction;

			endpoint = tracepoint + ( deltax, deltay, deltaz) + ( 0, 0, 72); // I use a high value here to avoid getting stuck
		}
	}

	// Calculate distance between start and end
	distance = distance(startpoint, endpoint);

	// Don't parachute distances below 350 units (3.5 seconds)
	if(distance < 350)
		return;

	// Now we are clear to parachute
	self.awe_isparachuting = 1;

	//create a model to attach everything to
	self.awe_anchor = spawn ("script_model",(0,0,0));
	self.awe_anchor.origin = self.origin;
	self.awe_anchor.angles = self.angles;
	
	self.awe_parachute = spawn_parachute();
	
	// Link player to self.awe_anchor
	self linkto (self.awe_anchor);

	self.awe_parachute linkto (self.awe_anchor,"",(24,-32,128),(0,-40,0));

	// Disable weapon & make player invulnerable
	if(level.awe_parachutesprotection)
	{
		self disableWeapon();
		self.awe_invulnerable = true;
	}

	// Play wind sound
	self.awe_anchor playLoopSound ("awe_Para_Wind");

	// Get a random falltime
	falltime = distance/100 + randomint(6);
	
	// Move self.awe_anchor
	self.awe_anchor.origin = startpoint;
	self.awe_anchor moveto (endpoint, falltime);

	// Wait fall time - 3 seconds	
	for(i=0;(i<(falltime - 3)*20) && isPlayer(self) && isAlive(self);i++)
	{
		self setClientCvar("cl_stance", "0");
		self.awe_anchor.angles = self.angles;
		wait 0.05;
	}
	// Play landing sound for the last 3 seconds
	if(isPlayer(self) && isAlive(self))
		self playSound("awe_Para_Land");

	for(i=0;(i<3*20) && isPlayer(self) && isAlive(self);i++)
	{
		self setClientCvar("cl_stance", "0");
		self.awe_anchor.angles = self.angles;
		wait 0.05;
	}

	self.awe_anchor stopLoopSound();
	
	// Release player if he's dead
	if(!isPlayer(self) || !isAlive(self))
		self unlink();

	if(isPlayer(self) && isAlive(self))
	{
		// Make sure self.awe_anchor is on it's endpoint	
		self.awe_anchor.origin = endpoint;
		
		// Enabled weapon
		if(level.awe_parachutesprotection)
			self enableWeapon();

		// Release player
		self unlink();

		// Let him fall
		wait 0.15;

		// Rock his world
		earthquake(0.4, 1.2, self.origin, 70);
	}

	if(level.awe_parachutesprotection)
		self.awe_invulnerable = undefined;

	self.awe_isparachuting = undefined;

	// Remove parachute
	self.awe_parachute delete();
	self.awe_anchor delete();

	return;
}

#using_animtree("animation_rig_parachute");
spawn_parachute()
{
	parachute = spawn ("script_model",(0,0,0));
	parachute.animname = "parachute";
	parachute setmodel ("xmodel/parachute_animrig");
	//parachute setmodel ("xmodel/parachute_flat_A");
	parachute.animtree = #animtree;
	parachute.landing_anim = %parachute_landing_roll;
	parachute.player_anim = %player_landing_roll;
	//parachute useAnimTree (parachute.animtree);
	return parachute;
}

spawnprotection()
{
	self endon("awe_spawned");
	self endon("awe_died");

	if(!isdefined(level.drawfriend))
		level.drawfriend = 0;

	count = 0;
	startposition = self.origin;
	self iprintln("Spawn protection activated!");

	// Set up HUD element
	if(level.awe_spawnprotectionhud == 1)
	{
		self.awe_spawnprotection = newClientHudElem(self);	
		self.awe_spawnprotection.x = 120;
		self.awe_spawnprotection.y = 408;
		self.awe_spawnprotection.alpha = 0.65;
		self.awe_spawnprotection.alignX = "center";
		self.awe_spawnprotection.alignY = "middle";
		self.awe_spawnprotection setShader(game["headicon_protect"],40,40);
	}

	if(level.awe_spawnprotectionhud == 2)
	{
		self.awe_spawnprotection = newClientHudElem(self);	
		self.awe_spawnprotection.x = 320;
		self.awe_spawnprotection.y = 240;
		self.awe_spawnprotection.alpha = 0.4;
		self.awe_spawnprotection.alignX = "center";
		self.awe_spawnprotection.alignY = "middle";
		self.awe_spawnprotection setShader(game["headicon_protect"],350,320);
	}

	while( isAlive(self) && self.sessionstate=="playing" && count < (level.awe_spawnprotection * 20) && !(self attackButtonPressed() && self getCurrentWeapon()!="none" && !(isdefined(self.awe_isparachuting) && level.awe_parachutesprotection) ) )
	{
		self.awe_invulnerable = true;

		// Setup headicon
		self.headicon = game["headicon_protect"];
		self.headiconteam = "none";

		if(level.awe_spawnprotectionrange && !isdefined(self.awe_isparachuting))
		{
			// Check moved range
			distance = distance(startposition, self.origin);
			if(distance > level.awe_spawnprotectionrange)
				count = level.awe_spawnprotection * 20;
		}

		// Don't count time while parachuting unless parachuter is unprotected
		if(!(isdefined(self.awe_isparachuting) && level.awe_parachutesprotection))
			count++;

		wait 0.05;
	}

	self.awe_invulnerable = undefined;
	self restoreHeadicon(game["headicon_protect"]);

	if( isAlive(self) && self.sessionstate=="playing" )
	{
		self iprintln("You are no longer protected!");

		// Fade HUD element
		self.awe_spawnprotection fadeOverTime (1); 
		self.awe_spawnprotection.alpha = 0;

		wait 1;
	}

	// Remove HUD element
	if(isdefined(self.awe_spawnprotection))
		self.awe_spawnprotection destroy();
}

restoreHeadicon(oldicon)
{
	// Restore headicon
	if(level.drawfriend && self.pers["team"]!="spectator" )
	{
		headicon = "headicon_" + self.pers["team"];
		self.headicon = game[headicon];
		self.headiconteam = self.pers["team"];

		if(isdefined(level.awe_classbased)) 	// Merciless v.6 classbased headicons
		{
			self.headicon = self.pers["hicon"];
		}
		else if(isdefined(self.carrying))
		{
			if(self.carrying)			// Demolition bombcarrier or CTF flag carrier
			{
				self.headiconteam = self.pers["team"];

				if(isdefined(game["status_bombstar"]))			// Demolition
					self.headicon = game["status_bombstar"];
				else if(isdefined(game["headicon_carrier"]))		// CTF
				{
					self.headicon = game["headicon_carrier"];
					if(getCvar("scr_ctf_showcarrier") == "1")
						self.headiconteam = "none";
				}
			}
		}
		else if(isdefined(self.objs_held))
		{
			if(self.objs_held)		// Retrieval object carrier
			{
				self.headicon = game["headicon_carrier"];
				if(getCvar("scr_re_showcarrier") == "0")
					self.headiconteam = game["re_attackers"];
				else
					self.headiconteam = "none";
			}
		}
	}
	else
	{
		self.headicon = "";
	}
	
	// Check if another function has saved the icon we marked with
	if(isdefined(self.oldheadicon))
		if(self.oldheadicon == oldicon)
			self.oldheadicon = self.headicon;
}

tracers()
{
	level endon("awe_boot");
	for(;;)
	{
		delay = level.awe_tracersdelaymin + randomint(level.awe_tracersdelaymax - level.awe_tracersdelaymin);
		wait delay;

		iSide = randomInt(4);
		switch (iSide)
		{
			case 0:
				ix = level.awe_vMin[0];
				iy = level.awe_vMin[1] + randomInt(level.awe_vMax[1] - level.awe_vMin[1]);
				break;

			case 1:
				ix = level.awe_vMax[0];
				iy = level.awe_vMin[1] + randomInt(level.awe_vMax[1] - level.awe_vMin[1]);
				break;
				
			case 2:
				ix = level.awe_vMin[0] + randomInt(level.awe_vMax[0] - level.awe_vMin[0]);
				iy = level.awe_vMin[1];
				break;
		
			case 3:
				ix = level.awe_vMin[0] + randomInt(level.awe_vMax[0] - level.awe_vMin[0]);
				iy = level.awe_vMax[1];
				break;
		}
			
		//set the height as the spawnpoint level - 100
		spawnpoints = getentarray("mp_deathmatch_spawn", "classname");
		if(!spawnpoints.size)
			spawnpoints = getentarray("mp_teamdeathmatch_spawn", "classname");
		if(!spawnpoints.size)
			spawnpoints = getentarray("mp_searchanddestroy_spawn_allied", "classname");
		if(!spawnpoints.size)
			spawnpoints = getentarray("mp_searchanddestroy_spawn_axis", "classname");
		if(!spawnpoints.size)
			spawnpoints = getentarray("mp_retrieval_spawn_allied", "classname");
		if(!spawnpoints.size)
			spawnpoints = getentarray("mp_retrieval_spawn_axis", "classname");
		iz = spawnpoints[0].origin[2] - 100;
			
		playfx(level._effect["awe_tracers"], (ix, iy, iz));
	}
}

skyflashes()
{
	level endon("awe_boot");


	for(;;)
	{
		// wait a random delay
		delay = level.awe_skyflashesdelaymin + randomint(level.awe_skyflashesdelaymax - level.awe_skyflashesdelaymin);
		wait delay;
			
		// spawn object that is used to play sound
		skyflash = spawn ( "script_model", ( 0, 0, 0) );

		//get a random position
		xwidth = level.awe_vMax[0] - level.awe_vMin[0] - 100;
		ywidth = level.awe_vMax[1] - level.awe_vMin[1] - 100;
		xpos = level.awe_vMin[0] + 50 + randomint(xwidth);
		ypos = level.awe_vMin[1] + 50 + randomint(ywidth);
		if(level.awe_bombers_altitude)
			zpos = level.awe_bombers_altitude - 50;
		else
			zpos = level.awe_vMax[2] - 50;	
		
		position = ( xpos, ypos, zpos);

		// get a random effect
		s = randomInt(level.awe_skyeffects.size);
		
		// play effect
		playfx(level.awe_skyeffects[s]["effect"], position);
		
		// play sound
		skyflash.origin = position;
		wait level.awe_skyeffects[s]["delay"];
		skyflash playsound("awe_skyflash");
		wait .05;
		skyflash delete();
	}
}

C47sounds(startpos, delay)
{
	level endon("awe_boot");
	for(;;)
	{
		wait delay;
		thread C47sound(startpos, delay);
	}
}

C47sound(startpos, delay)
{
	// start sound behind the effect
	startpos = startpos - (0,500,0);

	// spawn object that is used to play sound
	if(level.awe_debug)
		sndobject = spawn_model("xmodel/vehicle_plane_stuka", "stuka", startpos, ( 0, 90, 0) );
	else
		sndobject = spawn("script_model",startpos);
	wait 0.05;

	// Move the sound object a bit longer to get better fading of sound
	s = level.awe_vMax[1] - startpos[1] + 1000;
	v = 150;

	t = s / v;

	// play sound
	sndobject playloopsound("awe_planeloop");

	if(level.awe_debug)
	{
		iprintlnbold("distance: " + s);
		sndobject2 = spawn_model("xmodel/vehicle_plane_stuka", "stuka2", startpos + (0,s,0), ( 0, 90, 0) );
	}

	// move object
	sndobject moveto( startpos + (0,s,0) , t);
	wait t;
	sndobject stoploopsound();
	sndobject delete();
}

stukas()
{
	level endon("awe_boot");
	for(;;)
	{	
		wait level.awe_stukasdelay;
		stukas = level.awe_stukas + randomInt(3);
		offset = -2000 + randomInt(4000);
		angle = 90 * randomInt(4);
		for(i=0;i<stukas;i++)
			thread stuka( offset - (stukas * 500) + (i * 1000), angle);
	}
}

stuka(offset, angle)
{
	// Set height
	if(level.awe_bombers_altitude)
		iZ = level.awe_bombers_altitude;
	else
		iZ = level.awe_vMax[2];	

	iZstart 	= iZ + 1000 - randomInt(500);
	iZend 	= iZ + 1000 - randomInt(500);

	// Set X & Y depending on angle
	switch(angle)
	{
		case 0:
			iY 		= (int)(level.awe_vMax[1] + level.awe_vMin[1])/2 + offset;
			iYstart 	= iY - 200 + randomInt(400);
			iYend		= iY - 200 + randomInt(400);
			iXstart 	= level.awe_vMin[0] - 6000 - randomInt(1000);	
			iXend 	= level.awe_vMax[0] + 6000;
			break;

		case 90:
			iX 		= (int)(level.awe_vMax[0] + level.awe_vMin[0])/2 + offset;
			iXstart 	= iX - 200 + randomInt(400);
			iXend		= iX - 200 + randomInt(400);
			iYstart 	= level.awe_vMin[1] - 6000 - randomInt(1000);	
			iYend 	= level.awe_vMax[1] + 6000;
			break;

		case 180:
			iY 		= (int)(level.awe_vMax[1] + level.awe_vMin[1])/2 + offset;
			iYstart 	= iY - 200 + randomInt(400);
			iYend		= iY - 200 + randomInt(400);
			iXstart 	= level.awe_vMax[0] + 6000 + randomInt(1000);	
			iXend 	= level.awe_vMin[0] - 6000;
			break;

		case 270:
			iX 		= (int)(level.awe_vMax[0] + level.awe_vMin[0])/2 + offset;
			iXstart 	= iX - 200 + randomInt(400);
			iXend		= iX - 200 + randomInt(400);
			iYstart 	= level.awe_vMax[1] + 6000 + randomInt(1000);	
			iYend 	= level.awe_vMin[1] - 6000;
			break;
			break;
	}
	
	startpos 	= (iXstart, iYstart, iZstart);
	endpos 	= (iXend, iYend, iZend);


	s = (float)distance(startpos,endpos);
	v = (float)(2250 - 250 + randomInt(500));

	t = (float)(s / v);


	if(!(randomInt(100) < level.awe_stukascrash))
	{
		// spawn stuka
		stuka = spawn_model("xmodel/vehicle_plane_stuka", "stuka", startpos, ( 10, angle, 0) );
		wait 0.05;

		// play sound
		stuka playloopsound("awe_stukaloop");

		// move object
		stuka moveto( endpos , t);
		wait t/3;
		// 20% chance that it's going to roll after one third of the flight
		if(!randomInt(5))
		{
			if(randomInt(2))
				stuka rotateroll(360,4 + randomFloat(3),1,1);
			else
				stuka rotateroll(-360,4 + randomFloat(3),1,1);
		}
		wait 2*t/3;
		stuka stoploopsound();
		stuka delete();
	}
	else // This stuka will crash
	{
		startpos	= (startpos[0],startpos[1],iZ);
		endpos	= (endpos[0],endpos[1],iZ);
		// spawn stuka
		stuka = spawn_model("xmodel/vehicle_plane_stuka", "stuka", startpos, ( 10, angle, 0) );
		wait 0.05;

		// play sound
		stuka playloopsound("awe_stukaloop");
	
		fraction = 0.2 + randomfloat(0.4);

		deltax = (endpos[0]-startpos[0]) * fraction;
		deltay = (endpos[1]-startpos[1]) * fraction;
		deltaz = (endpos[2]-startpos[2]) * fraction;
		// move object
		stuka moveto( startpos + (deltax,deltay,deltaz) , t * fraction);
		wait t * fraction;
		stuka stoploopsound();
		stuka planeCrash(v);
	}
}

withinMap(origin)
{
	margin = 250;
	if(origin[0]<(level.awe_vMin[0]+margin)) return false;
	if(origin[1]<(level.awe_vMin[1]+margin)) return false;
	if(origin[2]<(level.awe_vMin[2]-margin)) return false;
	if(origin[0]>(level.awe_vMax[0]-margin)) return false;
	if(origin[1]>(level.awe_vMax[1]-margin)) return false;
	if(origin[2]>(level.awe_vMax[2]+margin)) return false;
	return true;
}

planeCrash(speed)
{
	level endon("awe_boot");

	self playloopsound("awe_stukahit");

	radius = 20;
	vVelocity = maps\mp\_utility::vectorScale(anglestoforward(self.angles), speed/20 );

	roll		= (float)0;
	deltaroll	= (float)(-5 + randomfloat(10))/(float)20;		// Roll/frame

	// Set gravity
	vGravity = (0,0,-0.75 + randomfloat(0.5));

	stopme = 0;
	ttl = level.awe_stukascrashstay;
	falloff = 0.05;

	bouncefx = level._effect["bombexplosion"];
	finalfx = bouncefx;

	playfx(bouncefx,self.origin);

	// Drop with gravity
	while(self.origin[2]>(level.awe_vMin[2] - 250))	// Exit if it missed the map
	{
		// Let gravity do, what gravity do best
		vVelocity +=vGravity;

		// Get destination origin
		neworigin = self.origin + vVelocity;

		if(withinMap(neworigin))	// Make sure it does not crash on invisible walls surrounding the map
		{
			// Check for impact, check for entities but not myself.
			trace=bulletTrace(self.origin,neworigin,true,self);
			if(trace["fraction"] != 1)	// Hit something
			{
				deltaroll = 0;
				roll = 0;
				self setModel("xmodel/vehicle_plane_stuka_d");
	
				// Place object at impact point - radius
				distance = distance(self.origin,trace["position"]);
				if(distance)
				{
					fraction = (distance - radius) / distance;
					delta = trace["position"] - self.origin;
					delta2 = maps\mp\_utility::vectorScale(delta,fraction);
					neworigin = self.origin + delta2;
				}
				else
					neworigin = self.origin;	

				// Play sound if defined
				if(isdefined(bouncesound)) self playSound(bouncesound);	
	
				// Test if we are hitting ground and if it's time to stop bouncing
				if(length(vVelocity) < 10) stopme++;
				if(stopme==1) break;	

				// Play effect if defined and it's a hard hit
				if(length(vVelocity) > 20)
				{
					playfx(bouncefx,neworigin);
				}

				// Decrease speed for each bounce.
				vSpeed = length(vVelocity) * falloff;	

				// Calculate new direction (Thanks to Hellspawn this is finally done correctly)
				vNormal = trace["normal"];
				vDir = maps\mp\_utility::vectorScale(vectorNormalize( vVelocity ),-1);
				vNewDir = ( maps\mp\_utility::vectorScale(maps\mp\_utility::vectorScale(vNormal,2),vectorDot( vDir, vNormal )) ) - vDir;	

				// Scale vector
				vVelocity = maps\mp\_utility::vectorScale(vNewDir, vSpeed);

				// Add a small random distortion
				vVelocity += (randomFloat(1)-0.5,randomFloat(1)-0.5,randomFloat(1)-0.5);
			}
		}
		self.origin = neworigin;

		angles = vectortoangles(vectornormalize(vVelocity));
		pitch = angles[0] + 10;

		// Rotate roll
		roll +=deltaroll;
		a2 = self.angles[2] + roll;
		while(a2<0) a2 += 360;
		while(a2>359) a2 -=360;
		self.angles = (pitch,self.angles[1],a2);
	
		// Wait one frame
		wait .05;
		ttl -= .05;
		if(ttl<=0) break;
	}
	self stoploopsound();

	if(self.origin[2]>(level.awe_vMin[2]-250))
	{
		// Set origin to impactpoint	
		self.origin = neworigin;

		playfx(finalfx,self.origin);
		if(!level.awe_stukascrashsafety)
			self scriptedRadiusDamage(self, undefined, "none", 800, 500, 10, false);
//		radiusDamage(self.origin, 800, 500, 10);
		if(level.awe_stukascrashquake)
			earthquake(0.8, 3, self.origin, 900); 

		wait 1 + randomfloat(2);

		playfx(bouncefx,self.origin);
		if(!level.awe_stukascrashsafety)
			self scriptedRadiusDamage(self, undefined, "none", 500, 300, 10, false);
//		radiusDamage(self.origin, 500, 300, 10);

		// Stay for the specified amount of time
		if(ttl>0) wait ttl;
	}
	// Vanish
	self delete();
}

PlayerDisconnect()
{
	self notify("awe_died");
	self notify("awe_spawned");

	self cleanupPlayer1();
	self cleanupPlayer2();

	if(level.awe_nocrosshair)
		self setClientCvar("cg_drawcrosshair", "1");

	dropTurret(undefined, undefined);
}
/*
antiCheat(victim, sHitLoc)
{
	if(!isdefined(self.pers["awe_cheatpoints"]))
		self.pers["awe_cheatpoints"] = 0;

	// Only check first shot on a victim
//	if(isdefined(self.awe_lastvictim) && self.awe_lastvictim == victim)
//		return;
//	self.awe_lastvictim = victim;

	// Do not check foot and lower leg hits
	switch(sHitLoc)
	{
		case "right_foot":
		case "left_foot":
		case "right_leg_lower":
		case "left_leg_lower":
			return;
			break;
		default:
			break;
	}

	// Get perfect angle
	temp = vectorToAngles(vectorNormalize(victim.origin - self.origin));
	perfectYaw = (float)temp[1];

	// Get perfect diff (low might mean cheating)
	temp = (float)((float)perfectYaw - (float)self.angles[1]);
	if(temp < 0)	temp = temp * -1;
	if(temp >= 180)	temp = 360 - temp;
	if(temp == 360)	temp = 0;
	if(temp < 0)	temp = temp * -1;
	perfectDiff = temp;

	// Get diff (high might mean cheating)
	temp = (float)((float)self.awe_oldyaw4 - (float)self.angles[1]);
	if(temp < 0)	temp = temp * -1;
	if(temp >= 180)	temp = 360 - temp;
	if(temp == 360)	temp = 0;
	if(temp < 0)	temp = temp * -1;
	diff = temp;

	self iprintln("pDiff:" + perfectDiff + " Diff:" + diff);

	if(pDiff<1 && diff>2)
	{
		self.pers["awe_cheatpoints"]++;
		self iprintlnbold("Cheatpoints:" + self.pers["awe_cheatpoints"]);
	}
}
*/
DoPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc)
{
/*
	if(isplayer(eInflictor))
		iprintln("eInflictor:" + eInflictor.name);
	if(isplayer(eAttacker))
		iprintln("eAttacker:" + eAttacker.name);
	iprintln("iDamage:" + iDamage + " iDFlags:" + iDFlags + " MOD:" + sMeansOfDeath + " Weapon:" + sWeapon + " sHitLoc:" + sHitLoc);
*/		

//	if(!isGrenade(sWeapon) && isPlayer(eAttacker) && (sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET") )	
//		eAttacker anticheat(self, sHitLoc);

	if(level.awe_bulletholes)
		if(sMeansOfDeath == "MOD_PISTOL_BULLET" || sMeansOfDeath == "MOD_RIFLE_BULLET")
//			eAttacker thread bullethole(sHitLoc);
			self thread bullethole(sHitLoc);

	if(isPlayer(eAttacker) && eAttacker != self && level.awe_showhit && !isdefined(level.awe_demolition))
		eAttacker thread showhit();

	if(isPlayer(eAttacker) && sMeansOfDeath != "MOD_FALLING")
	{
		if(sMeansOfDeath == "MOD_MELEE" || distance(eAttacker.origin , self.origin ) < 40 )
			eAttacker thread Splatter_View();
	}

	//PRM weapon drops on arm/hand hits and splatter view
	if(isAlive(self))
	{	
		switch(sHitLoc)
		{
			case "helmet":
			case "head":
				self thread Splatter_View();
				if( randomInt(100) < level.awe_pophelmet && !isdefined(self.awe_helmetpopped) )
					self thread popHelmet( vDir, iDamage );
				break;

			case "right_hand":
			case "left_hand":
			case "gun":
				if( !isdefined(level.awe_merciless) && (level.awe_droponarmhit || level.awe_droponhandhit) )
					self dropItem(self getcurrentweapon());
				break;
			
			case "right_arm_upper":
			case "right_arm_lower":
			case "left_arm_upper":
			case "left_arm_lower":
				if(!isdefined(level.awe_merciless) && level.awe_droponarmhit )
					self dropItem(self getcurrentweapon());
				break;
	
			case "right_foot":
			case "left_foot":
				if(level.awe_triponfoothit || level.awe_triponleghit)
					self thread spankme(1);
				break;

			case "right_leg_lower":
			case "left_leg_lower":
				if(level.awe_triponleghit)
					self thread spankme(1);
				break;
		}
	}

	if(isalive(self))
	{	
		if(!isdefined(level.awe_demolition) && !isdefined(level.awe_merciless) && !isdefined(level.awe_rsd) )
			self thread shockme(iDamage, sMeansOfDeath);
		if(level.awe_bleeding && !isdefined(level.awe_merciless))
			self thread DoBleedingPain(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
		self thread DoPainScreen(iDamage,sMeansofDeath);
	}	
}

//////////////////////////////////////////////////////////////////////////////////
// Bleed for a few seconds after a player gets hit...
//////////////////////////////////////////////////////////////////////////////////
DoBleedingPain(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc)
{
	self endon("awe_spawned");
	self endon("awe_died");

	self notify("awe_dobleedingpain");	// Kill any previous bleeding
	self endon("awe_dobleedingpain");

	bLoc = getHitLocTag(sHitLoc);

}

///////////////////////////////////////////////////////
// Draws a "pain" flash on the screen.
// The intensity and longevity of the flash is 
// dependant on both the weapon used & damage done.
//////////////////////////////////////////////////////
DoPainScreen(iDamage,sMeansOfDeath)
{
	self endon("awe_spawned");

	if(!level.awe_painscreen || isdefined(level.awe_merciless))
		return;
}

teamMateInRange(range)
{
	if(!range)
		return true;

	// Get all players and pick out the ones that are playing and are in the same team
	allplayers = getentarray("player", "classname");
	players = [];
	for(i = 0; i < allplayers.size; i++)
	{
		if(allplayers[i].sessionstate == "playing" && allplayers[i].pers["team"] == self.pers["team"])
			players[players.size] = allplayers[i];
	}

	// Get the players that are in range
	sortedplayers = sortByDist(players, self);

	// Need at least 2 players (myself + one team mate)
	if(sortedplayers.size<2)
		return false;

	// First player will be myself so check against second player
	distance = distance(self.origin, sortedplayers[1].origin);
	if( distance <= range )
		return true;
	else
		return false;
}

Splatter_View()
{
	self endon("awe_spawned");

	if (!level.awe_bloodyscreen || isdefined(level.awe_merciless))
		return;


}

showhit()
{
	self notify("awe_showhit");
	self endon("awe_showhit");
	self endon("awe_spawned");
	self endon("awe_died");
	
	if(isdefined(self.awe_hitblip))
		self.awe_hitblip destroy();

	self.awe_hitblip = newClientHudElem(self);
	self.awe_hitblip.alignX = "center";
	self.awe_hitblip.alignY = "middle";
	self.awe_hitblip.x = 320;
	self.awe_hitblip.y = 240;
	self.awe_hitblip.alpha = 0.5;
	self.awe_hitblip setShader("gfx/hud/hud@fire_ready.tga", 32, 32);
	self.awe_hitblip scaleOverTime(0.15, 64, 64);

	wait 0.15;

	if(isdefined(self.awe_hitblip))
		self.awe_hitblip destroy();
}

// Check if a position is indoor(under a roof) or outdoor(not under a roof)
outdoor(origin)
{
	if(!isdefined(origin))
		return false;

	trace = bulletTrace(origin+(0,0,level.awe_vMax[2]), origin, false, undefined);

	// If it didn't hit ANYTHING, it's outdoor
	if(trace["fraction"] == 1)
		return true;
	else
		return false;
}

bullethole(sHitLoc)
{
	self endon("awe_spawned");

	if(level.awe_bulletholes == 1 && sHitLoc != "head")
		return;

	if(!isPlayer(self))
		return;

	if(!isdefined(self.awe_bulletholes))
		self.awe_bulletholes = [];

	hole = self.awe_bulletholes.size;
	
	self.awe_bulletholes[hole] = newClientHudElem(self);
	self.awe_bulletholes[hole].alignX = "center";
	self.awe_bulletholes[hole].alignY = "middle";
	self.awe_bulletholes[hole].x = 48 + randomInt(544);
	self.awe_bulletholes[hole].y = 48 + randomInt(304);
	self.awe_bulletholes[hole].color = (1,1,1);
	self.awe_bulletholes[hole].alpha = 0.8 + randomFloat(0.2);
//	self.awe_bulletholes[hole].alpha = 1;

	xsize = 64 + randomInt(32);
	ysize = 64 + randomInt(32);

	if(randomInt(2))
//		self.awe_bulletholes[hole] setShader("gfx/impact/flesh_hit1.tga", xsize, ysize);
		self.awe_bulletholes[hole] setShader("gfx/impact/bullethit_glass.tga", xsize, ysize);
	else
//		self.awe_bulletholes[hole] setShader("gfx/impact/flesh_hit2.tga", xsize, ysize);
		self.awe_bulletholes[hole] setShader("gfx/impact/bullethit_glass2.tga", xsize, ysize);

	self playLocalSound("bullet_large_glass");
}

updateteamstatus()
{
	if(level.awe_showteamstatus == 1)
	{
		color = (1,1,0);
		deadcolor = (1,0,0);
		if(!isdefined(level.awe_axisicon))
		{
			level.awe_axisicon = newHudElem();	
			level.awe_axisicon.x = 0;
			level.awe_axisicon.y = 16;
			level.awe_axisicon.alignX = "left";
			level.awe_axisicon.alignY = "middle";
			level.awe_axisicon.alpha = 0.7;
			level.awe_axisicon setShader(game["radio_axis"],32,32);
		}
		if(!isdefined(level.awe_axisnumber))
		{
			level.awe_axisnumber = newHudElem();	
			level.awe_axisnumber.x = 32;
			level.awe_axisnumber.y = 12;
			level.awe_axisnumber.alignX = "left";
			level.awe_axisnumber.alignY = "middle";
			level.awe_axisnumber.alpha = 1;
			level.awe_axisnumber.font = "bigfixed";
			level.awe_axisnumber.color = color;
			level.awe_axisnumber setValue(0);
		}
		if(!isdefined(level.awe_deadaxisicon))
		{
			level.awe_deadaxisicon = newHudElem();	
			level.awe_deadaxisicon.x = 64;
			level.awe_deadaxisicon.y = 16;
			level.awe_deadaxisicon.alignX = "left";
			level.awe_deadaxisicon.alignY = "middle";
			level.awe_deadaxisicon.alpha = 0.7;
			level.awe_deadaxisicon setShader("gfx/hud/death_suicide.dds",29,29);
		}
		if(!isdefined(level.awe_deadaxisnumber))
		{
			level.awe_deadaxisnumber = newHudElem();	
			level.awe_deadaxisnumber.x = 96;
			level.awe_deadaxisnumber.y = 12;
			level.awe_deadaxisnumber.alignX = "left";
			level.awe_deadaxisnumber.alignY = "middle";
			level.awe_deadaxisnumber.alpha = 1;
			level.awe_deadaxisnumber.font = "bigfixed";
			level.awe_deadaxisnumber.color = deadcolor;
			level.awe_deadaxisnumber setValue(0);
		}
		if(!isdefined(level.awe_alliedicon))
		{
			level.awe_alliedicon = newHudElem();	
			level.awe_alliedicon.x = 0;
			level.awe_alliedicon.y = 48;
			level.awe_alliedicon.alignX = "left";
			level.awe_alliedicon.alignY = "middle";
			level.awe_alliedicon.alpha = 0.7;
			level.awe_alliedicon setShader(game["radio_allies"],32,32);
		}
		if(!isdefined(level.awe_alliednumber))
		{
			level.awe_alliednumber = newHudElem();	
			level.awe_alliednumber.x = 32;
			level.awe_alliednumber.y = 44;
			level.awe_alliednumber.alignX = "left";
			level.awe_alliednumber.alignY = "middle";
			level.awe_alliednumber.alpha = 1;
			level.awe_alliednumber.font = "bigfixed";
			level.awe_alliednumber.color = color;
			level.awe_alliednumber setValue(0);
		}
		if(!isdefined(level.awe_deadalliedicon))
		{
			level.awe_deadalliedicon = newHudElem();	
			level.awe_deadalliedicon.x = 64;
			level.awe_deadalliedicon.y = 48;
			level.awe_deadalliedicon.alignX = "left";
			level.awe_deadalliedicon.alignY = "middle";
			level.awe_deadalliedicon.alpha = 0.7;
			level.awe_deadalliedicon setShader("gfx/hud/death_suicide.dds",29,29);
		}
		if(!isdefined(level.awe_deadalliednumber))
		{
			level.awe_deadalliednumber = newHudElem();	
			level.awe_deadalliednumber.x = 96;
			level.awe_deadalliednumber.y = 44;
			level.awe_deadalliednumber.alignX = "left";
			level.awe_deadalliednumber.alignY = "middle";
			level.awe_deadalliednumber.alpha = 1;
			level.awe_deadalliednumber.font = "bigfixed";
			level.awe_deadalliednumber.color = deadcolor;
			level.awe_deadalliednumber setValue(0);
		}
	}
	else
	{
		color = (1,1,0);
		deadcolor = (1,0,0);
		if(!isdefined(level.awe_axisicon))
		{
			level.awe_axisicon = newHudElem();	
			level.awe_axisicon.x = 624;
			level.awe_axisicon.y = 20;
			level.awe_axisicon.alignX = "center";
			level.awe_axisicon.alignY = "middle";
			level.awe_axisicon.alpha = 0.7;
			level.awe_axisicon setShader(game["headicon_axis"],16,16);
		}
		if(!isdefined(level.awe_axisnumber))
		{
			level.awe_axisnumber = newHudElem();	
			level.awe_axisnumber.x = 624;
			level.awe_axisnumber.y = 36;
			level.awe_axisnumber.alignX = "center";
			level.awe_axisnumber.alignY = "middle";
			level.awe_axisnumber.alpha = 0.8;
			level.awe_axisnumber.fontscale = 1.0;
			level.awe_axisnumber.color = color;
			level.awe_axisnumber setValue(0);
		}
		if(!isdefined(level.awe_deadaxisicon))
		{
			level.awe_deadaxisicon = newHudElem();	
			level.awe_deadaxisicon.x = 592;
			level.awe_deadaxisicon.y = 52;
			level.awe_deadaxisicon.alignX = "center";
			level.awe_deadaxisicon.alignY = "middle";
			level.awe_deadaxisicon.alpha = 0.7;
			level.awe_deadaxisicon setShader("gfx/hud/death_suicide.dds",16,16);
		}
		if(!isdefined(level.awe_deadaxisnumber))
		{
			level.awe_deadaxisnumber = newHudElem();	
			level.awe_deadaxisnumber.x = 624;
			level.awe_deadaxisnumber.y = 52;
			level.awe_deadaxisnumber.alignX = "center";
			level.awe_deadaxisnumber.alignY = "middle";
			level.awe_deadaxisnumber.alpha = 0.8;
			level.awe_deadaxisnumber.fontscale = 1.0;
			level.awe_deadaxisnumber.color = deadcolor;
			level.awe_deadaxisnumber setValue(0);
		}
		if(!isdefined(level.awe_alliedicon))
		{
			level.awe_alliedicon = newHudElem();	
			level.awe_alliedicon.x = 608;
			level.awe_alliedicon.y = 20;
			level.awe_alliedicon.alignX = "center";
			level.awe_alliedicon.alignY = "middle";
			level.awe_alliedicon.alpha = 0.7;
			level.awe_alliedicon setShader(game["headicon_allies"],16,16);
		}
		if(!isdefined(level.awe_alliednumber))
		{
			level.awe_alliednumber = newHudElem();	
			level.awe_alliednumber.x = 608;
			level.awe_alliednumber.y = 36;
			level.awe_alliednumber.alignX = "center";
			level.awe_alliednumber.alignY = "middle";
			level.awe_alliednumber.alpha = 0.8;
			level.awe_alliednumber.fontscale = 1.0;
			level.awe_alliednumber.color = color;
			level.awe_alliednumber setValue(0);
		}
		if(!isdefined(level.awe_deadalliednumber))
		{
			level.awe_deadalliednumber = newHudElem();	
			level.awe_deadalliednumber.x = 608;
			level.awe_deadalliednumber.y = 52;
			level.awe_deadalliednumber.alignX = "center";
			level.awe_deadalliednumber.alignY = "middle";
			level.awe_deadalliednumber.alpha = 0.8;
			level.awe_deadalliednumber.fontscale = 1.0;
			level.awe_deadalliednumber.color = deadcolor;
			level.awe_deadalliednumber setValue(0);
		}
	}
	allplayers = getentarray("player", "classname");
	allies = [];
	axis = [];
	deadallies = [];
	deadaxis = [];
	for(i = 0; i < allplayers.size; i++)
	{
		if(allplayers[i].sessionstate == "playing" && allplayers[i].sessionteam == "allies")
			allies[allies.size] = allplayers[i];
		if(allplayers[i].sessionstate != "playing" && allplayers[i].sessionteam == "allies")
			deadallies[deadallies.size] = allplayers[i];
		if(allplayers[i].sessionstate == "playing" && allplayers[i].sessionteam == "axis")
			axis[axis.size] = allplayers[i];
		if(allplayers[i].sessionstate != "playing" && allplayers[i].sessionteam == "axis")
			deadaxis[deadaxis.size] = allplayers[i];
	}
	level.awe_axisnumber setValue(axis.size);
	level.awe_alliednumber setValue(allies.size);
	level.awe_deadaxisnumber setValue(deadaxis.size);
	level.awe_deadalliednumber setValue(deadallies.size);
}

overrideteams()
{
	if(isdefined(level.awe_classbased))
		return;

	// It it's the same map and gametype, use old values to avoid non precached models
	if( getcvar("mapname") == getcvar("awe_oldmap") && getcvar("g_gametype") == getcvar("awe_oldgt") )
	{
		game["allies"] = getcvar("awe_allies");
		game[game["allies"] + "_soldiertype"] 	= getcvar("awe_soldiertype");
		game[game["allies"] + "_soldiervariation"]= getcvar("awe_soldiervariation");
		if(game["allies"] == "american" && game[game["allies"] + "_soldiervariation"] == "winter")
		{
			game["german_soldiertype"] = "wehrmacht";
			game["german_soldiervariation"] = "winter";
		}
		return;
	}

	// Override allies team
	switch(level.awe_teamallies)
	{
		case "american":
		case "british":
		case "german":
		case "russian":
			game["allies"] = level.awe_teamallies;
			break;

		case "random":
			allies = [];
			oldteam = getcvar("awe_allies");
			if(oldteam != "american")	allies[allies.size] = "american";
			if(oldteam != "british")	allies[allies.size] = "british";
			if(oldteam != "russian")	allies[allies.size] = "russian";
			game["allies"] = allies[randomInt(allies.size)];
			break;

		default:
			break;
	}

	if(!isdefined(game[ game["allies"] + "_soldiertype" ]))
	{
		switch(game["allies"])
		{
			case "american":
				if(isdefined(level.awe_wintermap))
				{
					game["american_soldiertype"] = "airborne";
					game["american_soldiervariation"] = "winter";
					game["german_soldiertype"] = "wehrmacht";
					game["german_soldiervariation"] = "winter";
				}
				else	
				{
					game["american_soldiertype"] = "airborne";
					game["american_soldiervariation"] = "normal";
				}
				break;

			case "british":
				if(isdefined(level.awe_wintermap))
				{
					game["british_soldiertype"] = "commando";
					game["british_soldiervariation"] = "winter";
				}
				else
				{
					switch(randomInt(2))
					{
						case 0:
							game["british_soldiertype"] = "airborne";
							game["british_soldiervariation"] = "normal";
							break;
	
						default:
							game["british_soldiertype"] = "commando";
							game["british_soldiervariation"] = "normal";
							break;
					}
				}
				break;

			case "russian":
				if(isdefined(level.awe_wintermap))
				{
					switch(randomInt(2))
					{
						case 0:
							game["russian_soldiertype"] = "conscript";
							game["russian_soldiervariation"] = "winter";
							break;

						default:
							game["russian_soldiertype"] = "veteran";
							game["russian_soldiervariation"] = "winter";
							break;
					}
				}
				else
				{
					switch(randomInt(2))
					{
						case 0:
							game["russian_soldiertype"] = "conscript";
							game["russian_soldiervariation"] = "normal";
							break;


						default:
							game["russian_soldiertype"] = "veteran";
							game["russian_soldiervariation"] = "normal";
							break;

					}
				}
				break;
		}
	}

	// Save stuff for reinitializing in roundbased gametypes
	setcvar("awe_oldgt",	getcvar("g_gametype") );
	setcvar("awe_oldmap",	getcvar("mapname") );
	setcvar("awe_allies",			game["allies"] );
	setcvar("awe_soldiertype", 		game[game["allies"] + "_soldiertype"] );
	setcvar("awe_soldiervariation",	game[game["allies"] + "_soldiervariation"] );
}

showlogo()
{
	if(!level.awe_showlogo)
		return;

	if(isdefined(level.awe_logo))
		level.awe_logo destroy();

	level.awe_logo = newHudElem();	
	level.awe_logo.x = 630;
	level.awe_logo.y = 475;
	level.awe_logo.alignX = "right";
	level.awe_logo.alignY = "middle";
	level.awe_logo.sort = -3;
	level.awe_logo.alpha = 1;
	level.awe_logo.fontScale = 0.5;
	level.awe_logo.archived = true;
	level.awe_logo setText(level.awe_logotext);
}
overridefog()
{
	if(randomInt(100) < level.awe_cfog)
	{
		if(level.awe_cfogdistance2)
			thread fadeCullFog();
		else
			setCullFog(0, level.awe_cfogdistance, level.awe_cfogred, level.awe_cfoggreen, level.awe_cfogblue, 0);
	}
	else if(randomInt(100) < level.awe_efog)
	{
		if(level.awe_efogdensity2)
			thread fadeExpFog();
		else
			setExpFog(level.awe_efogdensity, level.awe_efogred, level.awe_efoggreen, level.awe_efogblue, 0);
	}
}

fadeCullFog()
{
	level endon("awe_boot");

	if(isdefined(level.awe_roundbased))
	{
		time = level.roundlength * 30;
		if(!time) time = 5 * 30;
	}
	else
	{
		time = level.timelimit * 30;
		if(!time) time = 20 * 30;
	}
	if(randomInt(2))
	{
		start = level.awe_cfogdistance;
		end = level.awe_cfogdistance2;
	}
	else
	{
		start = level.awe_cfogdistance2;
		end = level.awe_cfogdistance;
	}
	distance = start;
	delta = (end - start)/time;
	for(i=0;i<time;i++)
	{
		setCullFog(0, distance, level.awe_cfogred, level.awe_cfoggreen, level.awe_cfogblue, 0);
		distance = distance + delta;
		wait 1;
	}
	distance = end;
	delta = 0 - delta;
	for(i=0;i<time;i++)
	{
		setCullFog(0, distance, level.awe_cfogred, level.awe_cfoggreen, level.awe_cfogblue, 0);
		distance = distance + delta;
		wait 1;
	}
	distance = start;
	delta = 0 - delta;
	for(i=0;i<time;i++)
	{
		setCullFog(0, distance, level.awe_cfogred, level.awe_cfoggreen, level.awe_cfogblue, 0);
		distance = distance + delta;
		wait 1;
	}
	distance = end;
	delta = 0 - delta;
	for(i=0;i<time;i++)
	{
		setCullFog(0, distance, level.awe_cfogred, level.awe_cfoggreen, level.awe_cfogblue, 0);
		distance = distance + delta;
		wait 1;
	}
}

fadeExpFog()
{
	level endon("awe_boot");

	if(isdefined(level.awe_roundbased))
	{
		time = level.roundlength * 30;
		if(!time) time = 5 * 30;
	}
	else
	{
		time = level.timelimit * 30;
		if(!time) time = 20 * 30;
	}
	if(randomInt(2))
	{
		start = level.awe_efogdensity;
		end = level.awe_efogdensity2;
	}
	else
	{
		start = level.awe_efogdensity2;
		end = level.awe_efogdensity;
	}
	density = (float)start;
	delta = (float)(end - start)/(float)time;
	for(i=0;i<time;i++)
	{
		setExpFog(density, level.awe_efogred, level.awe_efoggreen, level.awe_efogblue, 0);
		density = (float)density + (float)delta;
		wait 1;
	}
	density = (float)end;
	delta = 0 - delta;
	for(i=0;i<time;i++)
	{
		setExpFog(density, level.awe_efogred, level.awe_efoggreen, level.awe_efogblue, 0);
		density = (float)density + (float)delta;
		wait 1;
	}
	density = (float)start;
	delta = 0 - delta;
	for(i=0;i<time;i++)
	{
		setExpFog(density, level.awe_efogred, level.awe_efoggreen, level.awe_efogblue, 0);
		density = (float)density + (float)delta;
		wait 1;
	}
	density = (float)end;
	delta = 0 - delta;
	for(i=0;i<time;i++)
	{
		setExpFog(density, level.awe_efogred, level.awe_efoggreen, level.awe_efogblue, 0);
		density = (float)density + (float)delta;
		wait 1;
	}
}

swapteams()
{
	// Swap team scores	
	axistempscore = game["axisscore"];
	game["axisscore"] = game["alliedscore"];
	setTeamScore("axis", game["alliedscore"]);
	game["alliedscore"] = axistempscore;
	setTeamScore("allies", game["alliedscore"]);
	
	// Swap all players
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{

		// Only swap axis and allies, not spectators
		if(players[i].pers["team"] != "allies" && players[i].pers["team"] != "axis")
			continue;

		if(players[i].pers["team"] == "axis")
		{
			newTeam = "allies";
			if(isdefined(players[i].pers["weapon"]))	players[i].pers["awe_axisweapon"]	= players[i].pers["weapon"];
			if(isdefined(players[i].pers["weapon1"]))	players[i].pers["awe_axisweapon1"]	= players[i].pers["weapon1"];
			if(isdefined(players[i].pers["weapon2"]))	players[i].pers["awe_axisweapon2"]	= players[i].pers["weapon2"];
			if(isdefined(players[i].pers["spawnweapon"])) players[i].pers["awe_axisspawnweapon"] = players[i].pers["spawnweapon"];
		}
		if(players[i].pers["team"] == "allies")
		{
			newTeam = "axis";
			if(isdefined(players[i].pers["weapon"]))	players[i].pers["awe_alliedweapon"]	= players[i].pers["weapon"];
			if(isdefined(players[i].pers["weapon1"]))	players[i].pers["awe_alliedweapon1"]	= players[i].pers["weapon1"];
			if(isdefined(players[i].pers["weapon2"]))	players[i].pers["awe_alliedweapon2"]	= players[i].pers["weapon2"];
			if(isdefined(players[i].pers["spawnweapon"])) players[i].pers["awe_alliedspawnweapon"] = players[i].pers["spawnweapon"];
		}

		players[i].pers["team"] = newTeam;
		players[i].pers["weapon"] = undefined;
		players[i].pers["weapon1"] = undefined;
		players[i].pers["weapon2"] = undefined;
		players[i].pers["spawnweapon"] = undefined;
		players[i].pers["savedmodel"] = undefined;

		// update spectator permissions immediately on change of team
		players[i] maps\mp\gametypes\_teams::SetSpectatePermissions();
	
		if(players[i].pers["team"] == "allies")
		{
			// Set old allied weapon if available
			if(isdefined(players[i].pers["awe_alliedweapon"]))	players[i].pers["weapon"]	= players[i].pers["awe_alliedweapon"];
			if(isdefined(players[i].pers["awe_alliedweapon1"]))	players[i].pers["weapon1"]	= players[i].pers["awe_alliedweapon1"];
			if(isdefined(players[i].pers["awe_alliedweapon2"]))	players[i].pers["weapon2"]	= players[i].pers["awe_alliedweapon2"];
			if(isdefined(players[i].pers["awe_alliedspawnweapon"])) players[i].pers["spawnweapon"] = players[i].pers["awe_alliedspawnweapon"];

		}
		else
		{
			// Set old axis weapon if available
			if(isdefined(players[i].pers["awe_axisweapon"]))	players[i].pers["weapon"]	= players[i].pers["awe_axisweapon"];
			if(isdefined(players[i].pers["awe_axisweapon1"]))	players[i].pers["weapon1"]	= players[i].pers["awe_axisweapon1"];
			if(isdefined(players[i].pers["awe_axisweapon2"]))	players[i].pers["weapon2"]	= players[i].pers["awe_axisweapon2"];
			if(isdefined(players[i].pers["awe_axisspawnweapon"])) players[i].pers["spawnweapon"] = players[i].pers["awe_axisspawnweapon"];
		}

	}

	
}

addBotClients()
{
	level endon("awe_boot");

	wait 5;
	
	while(!level.awe_bots) wait 1;
	
	for(i = 0; i < level.awe_bots; i++)
	{
		ent[i] = addtestclient();
		wait 0.5;

		if(isPlayer(ent[i]))
		{
			if(i & 1)
			{
				ent[i] notify("menuresponse", game["menu_team"], "axis");
				wait 0.5;
				ent[i] notify("menuresponse", game["menu_weapon_axis"], "kar98k_mp");
			}
			else
			{
				ent[i] notify("menuresponse", game["menu_team"], "allies");
				wait 0.5;
				if(game["allies"] == "russian")
					ent[i] notify("menuresponse", game["menu_weapon_allies"], "mosin_nagant_mp");
				else
					ent[i] notify("menuresponse", game["menu_weapon_allies"], "springfield_mp");
			}
		}
	}
}

warmupround()
{
	if(!isdefined(level.awe_roundbased))
		return;

	if(isdefined(level.awe_warmupmsg))
		level.awe_warmupmsg destroy();

	if(game["roundsplayed"] == 0 && game["matchstarted"] && level.awe_warmupround && !isdefined(game["awe_warmupdone"]) )
	{
		if(!isdefined(level.awe_warmupmsg))
		{
			level.awe_warmupmsg = newHudElem();
			level.awe_warmupmsg.archived = false;
			level.awe_warmupmsg.x = 320;
			level.awe_warmupmsg.y = 80;
			level.awe_warmupmsg.alignX = "center";
			level.awe_warmupmsg.alignY = "middle";
			level.awe_warmupmsg.fontScale = 2;
			level.awe_warmupmsg setText(&"^1Warmup Round!!");
		}
	}
}

resetScores()
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		player.pers["score"] = 0;
		player.pers["deaths"] = 0;
		player.pers["awe_teamkills"] = 0;
		player.pers["awe_teamdamage"] = 0;
		player.pers["awe_teamkiller"] = undefined;
	}

	game["alliedscore"] = 0;
	setTeamScore("allies", game["alliedscore"]);
	game["axisscore"] = 0;
	setTeamScore("axis", game["axisscore"]);
}

turretStuff()
{
	level endon("awe_boot");

	// Replace all turrets to make sure they got the correct targetname
	allent = getentarray();	// Get all entities

	numturrets=0;

	for(i=0;i<allent.size;i++)	// Loop through them
	{
		if(isdefined(allent[i]))		// Exist?
		{
			if(isdefined(allent[i].weaponinfo))		// Weapon?
			{
				name = "";
				model = "";
				switch(allent[i].weaponinfo)
				{
					case "mg42_bipod_stand_mp":
					case "mg42_bipod_duck_mp":
					case "mg42_bipod_prone_mp":
						name	= "misc_mg42";
						model	= "xmodel/mg42_bipod";
						break;

					case "PTRS41_Antitank_Rifle":
						name	= "misc_ptrs";
						model = "xmodel/weapon_antitankrifle"; 
						break;

					default:
						break;
				}
				if(name != "")
				{
					// Save info
					position = allent[i].origin;
					angles = allent[i].angles;
					w = allent[i].weaponinfo;

					// Delete old turret
					allent[i] delete();

					// Spawn a new one
					turret = spawnTurret (name, position, w);
 					turret setmodel (model);	
					turret.weaponinfo = w;
					turret.angles = angles;
					turret.origin = position;
					turret show();
					numturrets++;
				}
			}
		}
	}

//	iprintlnbold(numturrets + " turrets after converting.");

	wait 0.05;	// Allow changes to happen

	// Disable all MG42:s on the map	
	if(level.awe_mg42disable)
	{
		mgs=getEntArray("misc_mg42","classname");
		for (i=0;i<mgs.size;i++)
			if(isdefined(mgs[i]))
			{
				mgs[i] delete();				
				numturrets--;
			}
	}

	// Disable all PTRS41:s on the map	
	if(level.awe_ptrs41disable)
	{
		mgs=getEntArray("misc_ptrs","classname");
		for (i=0;i<mgs.size;i++)
			if(isdefined(mgs[i]))
			{
				mgs[i] delete();				
				numturrets--;
			}
	}	

//	iprintlnbold(numturrets + " turrets after deleting.");

	wait 0.05;	// Allow changes to happen

	// Spawn extra MG42s and/or PTRS41 at specific locations

	// Get first turret
	count = 0;
	x = cvardef("scr_awe_turret_x" + count, 0, -50000, 50000, "int");
	y = cvardef("scr_awe_turret_y" + count, 0, -50000, 50000, "int");
	z = cvardef("scr_awe_turret_z" + count, 0, -50000, 50000, "int");
	a = cvardef("scr_awe_turret_a" + count, 0, -50000, 50000, "int");
	w = cvardef("scr_awe_turret_w" + count, "", "", "", "string");

	// spawn turrets
	while(w != "" && numturrets < 32)
	{
		switch(w)
		{
			case "mg42_bipod_stand_mp":
			case "mg42_bipod_duck_mp":
			case "mg42_bipod_prone_mp":
				name	= "misc_mg42";
				model	= "xmodel/mg42_bipod";
				break;

			default:
				name	= "misc_ptrs";
				model = "xmodel/weapon_antitankrifle"; 
				break;
		}

		position = (x,y,z);
		turret = spawnTurret (name, position, w);
 		turret setmodel (model);
		turret.weaponinfo = w;
		turret.angles = (0,a,0);
		turret.origin = position + (0,0,-1);	//do this LAST. It'll move the MG into a usable position
		turret show();

		numturrets++;		
		count++;

		x = cvardef("scr_awe_turret_x" + count, 0, -50000, 50000, "int");
		y = cvardef("scr_awe_turret_y" + count, 0, -50000, 50000, "int");
		z = cvardef("scr_awe_turret_z" + count, 0, -50000, 50000, "int");
		a = cvardef("scr_awe_turret_a" + count, 0, -50000, 50000, "int");
		w = cvardef("scr_awe_turret_w" + count, "", "", "", "string");
	}

//	iprintlnbold(numturrets + " turrets after specific spawns.");

	// Spawn extra MG42s and/or PTRS41 and/or smoke grenades
	if(level.awe_mg42spawnextra || level.awe_ptrs41spawnextra || level.awe_smokegrenades)
	{
		spawnallied	= getentarray(level.awe_spawnalliedname, "classname");
		spawnaxis	= getentarray(level.awe_spawnaxisname, "classname");

		// Fall back to deatchmatch spawns, just in case. (Needed for LTS on non SD maps)
		if(!spawnallied.size)
			spawnallied	= getentarray("mp_deathmatch_spawn", "classname");
		if(!spawnaxis.size)
			spawnaxis	= getentarray("mp_deathmatch_spawn", "classname");

		oddeven=randomInt(2);
		for(i=0;i<level.awe_mg42spawnextra && numturrets<32;i++)
		{
			// Get a random spawn point
			if(oddeven)
			{
				spawn = spawnallied[randomInt(spawnallied.size)];
				oddeven=0;
			}
			else
			{
				spawn = spawnaxis[randomInt(spawnaxis.size)];
				oddeven=1;
			}

			position = spawn.origin - ( 15, 15, 0) + ( randomInt(31), randomInt(31), 0);
			trace=bulletTrace(position,position+(0,0,-1200),false,undefined);
			ground=trace["position"];
			turret = spawn("script_model", ground+(0,0,-10000));
			turret.targetname = "dropped_mg42";
			turret setmodel ( "xmodel/mg42_bipod"  );
			turret.angles = (0,randomInt(360),125);
			turret.origin = ground + (0,0,11);  //get the little feet into the terrain
			turret show();

			numturrets++;
		}
	
		oddeven=randomInt(2);
		for(i=0;i<level.awe_ptrs41spawnextra && numturrets<32;i++)
		{
			// Get a random spawn point
			if(oddeven)
			{
				spawn = spawnallied[randomInt(spawnallied.size)];
				oddeven=0;
			}
			else
			{
				spawn = spawnaxis[randomInt(spawnaxis.size)];
				oddeven=1;
			}

			position = spawn.origin - ( 15, 15, 0) + ( randomInt(31), randomInt(31), 0);
			trace=bulletTrace(position,position+(0,0,-1200),false,undefined);
			ground=trace["position"];
			turret = spawn("script_model", ground + (0,0,-10000));
			turret.targetname = "dropped_ptrs";
			turret setmodel ( "xmodel/weapon_antitankrifle"  );
			turret.angles = (0,randomInt(360),112);
			turret.origin = ground + (0,0,11);
			turret show();

			numturrets++;
		}
		oddeven=randomInt(2);
		for(i=0;i<level.awe_smokegrenades;i++)
		{
			// Get a random spawn point
			if(oddeven)
			{
				spawn = spawnallied[randomInt(spawnallied.size)];
				oddeven=0;
			}
			else
			{
				spawn = spawnaxis[randomInt(spawnaxis.size)];
				oddeven=1;
			}
			smokie = spawn("mpweapon_smokegrenade", spawn.origin - ( 10, 10, 0) + ( randomInt(21), randomInt(21), 10));
		}
	}	

//	iprintlnbold(numturrets + " turrets after spawnpoint spawns.");

	wait 0.05;	// Allow changes to happen

	// Build turret array
	level.awe_turrets = [];

	mgs=getEntArray("misc_mg42","classname");
	for (i=0;i<mgs.size;i++)
	{
		if(isdefined(mgs[i]))
		{
			level.awe_turrets[level.awe_turrets.size]["turret"] = mgs[i];
			level.awe_turrets[level.awe_turrets.size - 1]["type"] = "misc_mg42";
			level.awe_turrets[level.awe_turrets.size - 1]["original_position"] = mgs[i].origin;
			level.awe_turrets[level.awe_turrets.size - 1]["original_angles"]	= mgs[i].angles;
			level.awe_turrets[level.awe_turrets.size - 1]["original_weaponinfo"]=mgs[i].weaponinfo;
			level.awe_turrets[level.awe_turrets.size - 1]["dropped"] = undefined;
			level.awe_turrets[level.awe_turrets.size - 1]["carried"] = undefined;
		}
	}

	mgs=getEntArray("misc_ptrs","classname");
	for (i=0;i<mgs.size;i++)
	{
		if(isdefined(mgs[i]))
		{
			level.awe_turrets[level.awe_turrets.size]["turret"] = mgs[i];
			level.awe_turrets[level.awe_turrets.size - 1]["type"] = "misc_ptrs";
			level.awe_turrets[level.awe_turrets.size - 1]["original_position"] = mgs[i].origin;
			level.awe_turrets[level.awe_turrets.size - 1]["original_angles"]	= mgs[i].angles;
			level.awe_turrets[level.awe_turrets.size - 1]["original_weaponinfo"]=mgs[i].weaponinfo;
			level.awe_turrets[level.awe_turrets.size - 1]["dropped"] = undefined;
			level.awe_turrets[level.awe_turrets.size - 1]["carried"] = undefined;
		}
	}

	// Get dropped turrets
	mgs=getEntArray("dropped_mg42","targetname");
	for (i=0;i<mgs.size;i++)
	{
		if(isdefined(mgs[i]))
		{
			level.awe_turrets[level.awe_turrets.size]["turret"] = mgs[i];
			level.awe_turrets[level.awe_turrets.size - 1]["type"] = "misc_mg42";
			level.awe_turrets[level.awe_turrets.size - 1]["original_position"] = mgs[i].origin;
			level.awe_turrets[level.awe_turrets.size - 1]["original_angles"]	= mgs[i].angles;
			level.awe_turrets[level.awe_turrets.size - 1]["original_weaponinfo"]= undefined;
			level.awe_turrets[level.awe_turrets.size - 1]["dropped"] = true;
			level.awe_turrets[level.awe_turrets.size - 1]["carried"] = undefined;
		}
	}

	mgs=getEntArray("dropped_ptrs","targetname");
	for (i=0;i<mgs.size;i++)
	{
		if(isdefined(mgs[i]))
		{
			level.awe_turrets[level.awe_turrets.size]["turret"] = mgs[i];
			level.awe_turrets[level.awe_turrets.size - 1]["type"] = "misc_ptrs";
			level.awe_turrets[level.awe_turrets.size - 1]["original_position"] = mgs[i].origin;
			level.awe_turrets[level.awe_turrets.size - 1]["original_angles"]	= mgs[i].angles;
			level.awe_turrets[level.awe_turrets.size - 1]["original_weaponinfo"]=undefined;
			level.awe_turrets[level.awe_turrets.size - 1]["dropped"] = true;
			level.awe_turrets[level.awe_turrets.size - 1]["carried"] = undefined;
		}
	}
//	iprintlnbold( (level.awe_turrets.size) + " turrets in turretarray.");
}

isGrenade(weapon)
{
	switch(weapon)
	{
		case "fraggrenade_mp":
		case "mk1britishfrag_mp":
		case "rgd-33russianfrag_mp":
		case "stielhandgranate_mp":
//		case "smokegrenade_mp":
			return true;
			break;

		default:
			return false;
			break;
	}
}

cookgrenade()
{
	if(isdefined(self.awe_cooking)) return;
	self.awe_cooking = true;

	self endon("awe_spawned");
	self endon("awe_died");

	if(level.awe_cookablegrenades)		// Cookable grenades?
	{
		if(isdefined(self.awe_cookbar))
		{
			self.awe_cookbarbackground destroy();
			self.awe_cookbar destroy();
			self.awe_cookbartext destroy();
		}
			
		// Size of progressbar
		barsize = 288;
	
		// Time for progressbar	
		bartime = (float)level.awe_fusetime - 0.15;

		// Background
		self.awe_cookbarbackground = newClientHudElem(self);				
		self.awe_cookbarbackground.alignX = "center";
		self.awe_cookbarbackground.alignY = "middle";
		self.awe_cookbarbackground.x = 320;
		self.awe_cookbarbackground.y = 385;
		self.awe_cookbarbackground.alpha = 0.5;
//		self.awe_cookbarbackground setShader("black", (barsize + 4), 12);			
		self.awe_cookbarbackground.color = (0,0,0);
		self.awe_cookbarbackground setShader("white", (barsize + 4), 12);			

		// Progress bar
		self.awe_cookbar = newClientHudElem(self);				
		self.awe_cookbar.alignX = "left";
		self.awe_cookbar.alignY = "middle";
		self.awe_cookbar.x = (320 - (barsize / 2.0));
		self.awe_cookbar.y = 385;
//		self.awe_cookbar setShader("red", 0, 8);
		self.awe_cookbar.color = (0.9,0.1,0.1);
		self.awe_cookbar setShader("white", 0, 8);
		self.awe_cookbar scaleOverTime(bartime , barsize, 8);

		// Text
		self.awe_cookbartext = newClientHudElem(self);
		self.awe_cookbartext.alignX = "center";
		self.awe_cookbartext.alignY = "middle";
		self.awe_cookbartext.x = 320;
		self.awe_cookbartext.y = 384;
		self.awe_cookbartext.fontscale = 0.8;
		self.awe_cookbartext.color = (.5,.5,.5);
		self.awe_cookbartext settext (&"Cooking grenade");

		// Init counter for tick sound
		tickcounter=0;
		self playlocalsound("bomb_tick");

		// Cooktime is fusetime * 20 - 2 (Usually 79)
		cooktime = level.awe_fusetime * 20 - 2;

		// Cook
		for(i=0;i<cooktime;i++)
		{
			// Break if grenade is thrown
			if(!self attackButtonPressed() || !isGrenade( self getCurrentWeapon() ) )
				break;
			else
			{
				// Play bomb_tick every second
				tickcounter++;
				if(tickcounter >=20) {
					self playlocalsound("bomb_tick");
					tickcounter=0;
				}
				wait .05;
			}
			if(!isAlive(self) || self.sessionstate != "playing")
				break;
		}

		// Remove hud elements
		if(isdefined(self.awe_cookbarbackground))
			self.awe_cookbarbackground destroy();
		if(isdefined(self.awe_cookbar))
			self.awe_cookbar destroy();
		if(isdefined(self.awe_cookbartext))
			self.awe_cookbartext destroy();

		if(i>=cooktime)
		{
			// !!! OVERCOOKED !!!	

			sWeapon = self getWeaponSlotWeapon("grenade");
			// Remove grenade before it goes off.
			self setWeaponSlotWeapon("grenade", "none");
			wait 0.05;	

			// explode 
			if(self getCurrentWeapon() == "smokegrenade_mp")
				playfxontag(level._effect["smokeexplosion"], self, "Bip01 R Hand");
			else
				playfxontag(level._effect["bombexplosion"], self, "Bip01 R Hand");
			wait .05;
//			radiusDamage(self.origin, iRange, iMaxdamage, iMindamage);

			iRange = 350;
			iMaxdamage = 220;
			iMindamage = 15;
			self scriptedRadiusDamage(self, (0,0,32), sWeapon, iRange, iMaxdamage, iMindamage, false);

//			self suicide();
	
			self.awe_cooking = undefined;
			return;
		}
	}
	else // Normal grenade
		while(self attackButtonPressed() && isGrenade( self getCurrentWeapon() ) && isAlive(self) && self.sessionstate == "playing")
			wait .05;

	// Thrown a grenade?
	if(isGrenade(self getCurrentWeapon()) && !self attackButtonPressed() && level.awe_grenadewarning && isAlive(self) && self.sessionstate == "playing")
	{
		if( (randomInt(100) < level.awe_grenadewarning) && self teamMateInRange(level.awe_grenadewarningrange) )
		{
			// Yell "Grenade!"
			soundalias = level.awe_grenadevoices[ game[ self.pers["team"] ] ][randomInt(level.awe_grenadevoices[ game[ self.pers["team"] ] ].size)];
			self playsound(soundalias);
		}
	}
	self.awe_cooking = undefined;
}

//Thread to determine if a player can place grenades
checkTripwirePlacement()
{
	self notify("awe_checktripwireplacement");
	self endon("awe_checktripwireplacement");
	level endon("awe_boot");
	self endon("awe_spawned");
	self endon("awe_died");

	//stay here until player lets go of melee button
	//keeps mg from accidently being placed as soon as it is picked up
	while( isAlive( self ) && self.sessionstate=="playing" && self meleeButtonPressed() )
		wait( 0.1 );

	showTripwireMessage(self getWeaponSlotWeapon("grenade"), level.awe_tripwireplacemessage);

	while( isAlive( self ) && self.sessionstate=="playing" && !isdefined(self.awe_turretmessage) )
	{
//		sWeapon = self getWeaponSlotWeapon("grenade");
		sWeapon = self getCurrentWeapon();
		if(!isGrenade(sWeapon)) break;

		iAmmo	= self getWeaponSlotClipAmmo("grenade");
		if(iAmmo<2) break;

		stance = self getStance(true);
		if(stance!=2) break;

		// Get position
		position = self.origin + maps\mp\_utility::vectorScale(anglesToForward(self.angles),15);

		// Check that there is room.
		trace=bulletTrace(self.origin+(0,0,10),position+(0,0,10),false,undefined);
		if(trace["fraction"]!=1) break;
	
		// Find ground
		trace=bulletTrace(position+(0,0,10),position+(0,0,-10),false,undefined);
		if(trace["fraction"]==1) break;
		position=trace["position"];
		tracestart = position + (0,0,10);

		// Find position1
		traceend = tracestart + maps\mp\_utility::vectorScale(anglesToForward(self.angles + (0,90,0)),50);
		trace=bulletTrace(tracestart,traceend,false,undefined);
		if(trace["fraction"]!="1")
		{
			distance = distance(tracestart,trace["position"]);
			if(distance>5) distance = distance - 2;
			position1=tracestart + maps\mp\_utility::vectorScale(vectorNormalize(trace["position"]-tracestart),distance);
		}
		else
			position1 = trace["position"];

		// Find ground
		trace=bulletTrace(position1,position1+(0,0,-20),false,undefined);
		if(trace["fraction"]==1) break;
		vPos1=trace["position"] + (0,0,3);

		// Find position2
		traceend = tracestart + maps\mp\_utility::vectorScale(anglesToForward(self.angles + (0,-90,0)),50);
		trace=bulletTrace(tracestart,traceend,false,undefined);
		if(trace["fraction"]!="1")
		{
			distance = distance(tracestart,trace["position"]);
			if(distance>5) distance = distance - 2;
			position2=tracestart + maps\mp\_utility::vectorScale(vectorNormalize(trace["position"]-tracestart),distance);
		}
		else
			position2 = trace["position"];

		// Find ground
		trace=bulletTrace(position2,position2+(0,0,-20),false,undefined);
		if(trace["fraction"]==1) break;
		vPos2=trace["position"] + (0,0,3);

		if( isAlive( self ) && self.sessionstate == "playing" && self meleeButtonPressed() )
		{
			// Ok to plant, show progress bar
			origin = self.origin;
			angles = self.angles;

			if(level.awe_tripwireplanttime)
				planttime = level.awe_tripwireplanttime;
			else
				planttime = undefined;

			if(isdefined(planttime))
			{
				self disableWeapon();
				if(!isdefined(self.awe_plantbar))
				{
					barsize = 288;
					// Time for progressbar	
					bartime = (float)planttime;

					if(isdefined(self.awe_tripwiremessage))	self.awe_tripwiremessage destroy();
					if(isdefined(self.awe_tripwiremessage2))	self.awe_tripwiremessage2 destroy();

					// Background
					self.awe_plantbarbackground = newClientHudElem(self);				
					self.awe_plantbarbackground.alignX = "center";
					self.awe_plantbarbackground.alignY = "middle";
					self.awe_plantbarbackground.x = 320;
					self.awe_plantbarbackground.y = 405;
					self.awe_plantbarbackground.alpha = 0.5;
//					self.awe_plantbarbackground setShader("black", (barsize + 4), 12);			
					self.awe_plantbarbackground.color = (0,0,0);
					self.awe_plantbarbackground setShader("white", (barsize + 4), 12);			
					// Progress bar
					self.awe_plantbar = newClientHudElem(self);				
					self.awe_plantbar.alignX = "left";
					self.awe_plantbar.alignY = "middle";
					self.awe_plantbar.x = (320 - (barsize / 2.0));
					self.awe_plantbar.y = 405;
					self.awe_plantbar setShader("white", 0, 8);
					self.awe_plantbar scaleOverTime(bartime , barsize, 8);

					showTripwireMessage(self getWeaponSlotWeapon("grenade"), level.awe_turretplacingmessage);

					// Play plant sound
					self playsound("moody_plant");
				}

				for(i=0;i<planttime*20;i++)
				{
					if( !(self meleeButtonPressed() && origin == self.origin && isAlive(self) && self.sessionstate=="playing") )
						break;
					wait 0.05;
				}

				// Remove hud elements
				if(isdefined(self.awe_plantbarbackground)) self.awe_plantbarbackground destroy();
				if(isdefined(self.awe_plantbar))		 self.awe_plantbar destroy();
				if(isdefined(self.awe_tripwiremessage))	self.awe_tripwiremessage destroy();
				if(isdefined(self.awe_tripwiremessage2))	self.awe_tripwiremessage2 destroy();
		
				self enableWeapon();
				if(i<planttime*20)
					return false;
			}

			// Calc new center
			x = (vPos1[0] + vPos2[0])/2;
			y = (vPos1[1] + vPos2[1])/2;
			z = (vPos1[2] + vPos2[2])/2;
			vPos = (x,y,z);

			// Decrease grenade ammo
			iAmmo--;
			iAmmo--;
			if(iAmmo)
				self setWeaponSlotClipAmmo("grenade", iAmmo);
			else
			{
				self setWeaponSlotClipAmmo("grenade", iAmmo);
				self setWeaponSlotWeapon("grenade", "none");
				newWeapon = self getWeaponSlotWeapon("primary");
				if(newWeapon=="none") newWeapon = self getWeaponSlotWeapon("primaryb");
				if(newWeapon=="none") newWeapon = self getWeaponSlotWeapon("pistol");
				if(newWeapon!="none") self switchToWeapon(newWeapon);
			}
	
			// Spawn tripwire
			tripwire = spawn("script_origin",vPos);
			tripwire.angles = angles;
			tripwire thread monitorTripwire(self, sWeapon, vPos1, vPos2);
			break;
		}
		wait( 0.2 );
	}
	if(isdefined(self.awe_tripwiremessage))	self.awe_tripwiremessage destroy();
	if(isdefined(self.awe_tripwiremessage2))	self.awe_tripwiremessage2 destroy();
}

showTripwireMessage(sWeapon, which_message )
{
	if(isdefined(self.awe_tripwiremessage))	self.awe_tripwiremessage destroy();
	if(isdefined(self.awe_tripwiremessage2))	self.awe_tripwiremessage2 destroy();

	self.awe_tripwiremessage = newClientHudElem( self );
	self.awe_tripwiremessage.alignX = "center";
	self.awe_tripwiremessage.alignY = "middle";
	self.awe_tripwiremessage.x = 320;
	self.awe_tripwiremessage.y = 404;
	self.awe_tripwiremessage.alpha = 1;
	self.awe_tripwiremessage.fontScale = 0.80;
	if( 	(isdefined(level.awe_turretpickingmessage) && which_message == level.awe_turretpickingmessage) ||
		(isdefined(level.awe_turretplacingmessage) && which_message == level.awe_turretplacingmessage) )
		self.awe_tripwiremessage.color = (.5,.5,.5);
	self.awe_tripwiremessage setText( which_message );

	self.awe_tripwiremessage2 = newClientHudElem(self);
	self.awe_tripwiremessage2.alignX = "center";
	self.awe_tripwiremessage2.alignY = "top";
	self.awe_tripwiremessage2.x = 320;
	self.awe_tripwiremessage2.y = 415;
	self.awe_tripwiremessage2 setShader(getGrenadeHud(sWeapon),40,40);
}

getGrenadeHud(sWeapon)
{
	switch(sWeapon)
	{
		case "fraggrenade_mp":
			model = "gfx/hud/hud@death_us_grenade.dds";
			break;

		case "mk1britishfrag_mp":
			model = "gfx/hud/hud@death_british_grenade.dds";
			break;

		case "rgd-33russianfrag_mp":
			model = "gfx/hud/hud@death_russian_grenade.dds";
			break;	

		default:
			model = "gfx/hud/hud@death_steilhandgrenate.dds";
			break;
	}
	return model;
}

/*
print3dloop(vPos,sText,vColor,iAlpha,iScale)
{
	level endon("awe_boot");
	self endon("awe_print3dloop");
	for(;;)
	{
		print3d (vPos, sText, vColor, iAlpha, iScale);	// origin, text, RGB, alpha, scale
		wait 0.05;
	}
}
*/

/*
lineloop(vPos1, vPos2, vColor)
{
	level endon("awe_boot");
	self endon("awe_lineloop");
	for(;;)
	{
		line(vPos1, vPos2, vColor);
		wait 0.05;
	}
}
*/

tripwireWarning()
{
	if(isdefined(self.awe_tripwirewarning))
		return;
	self.awe_tripwirewarning = true;
	self iprintlnbold("^1WARNING! ^7Tripwire!");
	wait 5;
	self.awe_tripwirewarning = undefined;
}

monitorTripwire(owner, sWeapon, vPos1, vPos2)
{
	level endon("awe_boot");
	self endon("awe_monitortripwire");

	wait .05;

	// Save old team if teamplay
	if(isdefined(level.awe_teamplay))
		oldteam = owner.sessionteam;

	// Spawn nade one
	self.nade1 = spawn("script_model",vPos1);
	self.nade1 setModel(getGrenadeModel(sWeapon));
	self.nade1.angles = self.angles;

	// Spawn nade two
	self.nade2 = spawn("script_model",vPos2);
	self.nade2 setModel(getGrenadeModel(sWeapon));
	self.nade2.angles = self.angles;

	// Get detection spots
	vPos3 = self.origin + maps\mp\_utility::vectorScale(anglesToForward(self.angles),50);
	vPos4 = self.origin + maps\mp\_utility::vectorScale(anglesToForward(self.angles + (0,180,0)),50);

	// Get detection ranges
	range = distance(self.origin, vPos1) + 50;
	range2 = distance(vPos3,vPos1) + 2;

	if(isDefined(owner) && isAlive(owner) && owner.sessionstate == "playing")
		owner iprintlnbold("Tripwire activates in ^15 ^7seconds!");

	wait 5;

	// replace time with detection code
	for(;;)
	{
		players = getentarray("player", "classname");
		for(j=0;j<20;j++)
		{
			blow = undefined;
			for(i=0;i<players.size;i++)
			{
				// Check that player still exist
				if(isDefined(players[i]))
					player = players[i];
				else
					continue;

				// Player? Alive? Playing?
				if(!isPlayer(player) || !isAlive(player) || player.sessionstate != "playing")
					continue;
				
				// Within range?
				distance = distance(self.origin, player.origin);
				if(distance>=range)
					continue;

				// Check for defusal
				if(!isdefined(self.awe_checkdefusetripwire))
					player thread checkDefuseTripwire(self, sWeapon);

				// Warm if same team?
				if(isDefined(oldteam) && oldteam == player.sessionteam && !isDefined(player.awe_tripwirewarning))
				{
					// Stop check if tripwire is safe for teammates.
					if(level.awe_tripwire==3)
						continue;
					else
						player thread tripwireWarning();
				}

				// Within sphere one?
				distance = distance(vPos3, player.origin);
				if(distance>=range2)
					continue;

				// Within sphere two?
				distance = distance(vPos4, player.origin);
				if(distance>=range2)
					continue;

				// Time to blow
				blow = true;
				break;
			}

			if(isdefined(blow)) break;
			if(i!=19) wait .05;
		}
		if(isdefined(blow)) break;
		wait .05;
	}

	// Stoled from _minefields.gsc
	self.nade1 playsound("weap_fraggrenade_pin");
	wait(.05);
	self.nade2 playsound("weap_fraggrenade_pin");
	wait(.05);
	wait(randomFloat(.5));

	// Check that damage owner till exists
	if(isDefined(owner) && isPlayer(owner))
	{
		// I player has switched team and it's teamplay the tripwire is unowned.
		if(isdefined(oldteam) && oldteam == owner.sessionteam)
			eAttacker = owner;
		else if(!isdefined(oldteam))		//Not teamplay
			eAttacker = owner;
		else						//Player has switched team
			eAttacker = self;
	}
	else
		eAttacker = self;

	// Blow number one
	playfx(level._effect["bombexplosion"], self.nade1.origin);
	self.nade1 scriptedRadiusDamage(eAttacker, (0,0,0), sWeapon, 350, 220, 15, (level.awe_tripwire>1) );
	wait .05;
	self.nade1 delete();

	// A small, random, delay between the nades
	wait(randomFloat(.25));

	// Blow number two
	playfx(level._effect["bombexplosion"], self.nade2.origin);
	self.nade2 scriptedRadiusDamage(eAttacker, (0,0,0), sWeapon, 350, 220, 15, (level.awe_tripwire>1) );
	wait .05;
	self.nade2 delete();

	self delete();
}

checkDefuseTripwire(tripwire, sWeapon)
{
	level endon("awe_boot");
	self endon("awe_spawned");
	self endon("awe_died");

	// Make sure to only run one instance
	if(isdefined(self.awe_checkdefusetripwire))
		return;

	range = 20;

	// Check prone
	if(self getstance(true) != "2") return;
	// Check nades
	distance1 = distance(tripwire.nade1.origin, self.origin);
	distance2 = distance(tripwire.nade2.origin, self.origin);
	if(distance1>=range && distance2>=range) return;

	// Ok to defuse, kill checkTripwirePlacement and set up new hud message
	self notify("awe_checktripwireplacement");

	self.awe_checkdefusetripwire = true;

	// Remove hud elements
	if(isdefined(self.awe_plantbarbackground)) self.awe_plantbarbackground destroy();
	if(isdefined(self.awe_plantbar))		 self.awe_plantbar destroy();
	if(isdefined(self.awe_tripwiremessage))	self.awe_tripwiremessage destroy();
	if(isdefined(self.awe_tripwiremessage2))	self.awe_tripwiremessage2 destroy();

	// Set up new
	showTripwireMessage(sWeapon, level.awe_tripwirepickupmessage);

	// Loop
	for(;;)
	{
		if( isAlive( self ) && self.sessionstate == "playing" && self meleeButtonPressed() )
		{
			// Ok to plant, show progress bar
			origin = self.origin;
			angles = self.angles;

			if(level.awe_tripwirepicktime)
				planttime = level.awe_tripwirepicktime;
			else
				planttime = undefined;

			if(isdefined(planttime))
			{
				self disableWeapon();
				if(!isdefined(self.awe_plantbar))
				{
					barsize = 288;
					// Time for progressbar	
					bartime = (float)planttime;

					if(isdefined(self.awe_tripwiremessage))	self.awe_tripwiremessage destroy();
					if(isdefined(self.awe_tripwiremessage2))	self.awe_tripwiremessage2 destroy();

					// Background
					self.awe_plantbarbackground = newClientHudElem(self);				
					self.awe_plantbarbackground.alignX = "center";
					self.awe_plantbarbackground.alignY = "middle";
					self.awe_plantbarbackground.x = 320;
					self.awe_plantbarbackground.y = 405;
					self.awe_plantbarbackground.alpha = 0.5;
//					self.awe_plantbarbackground setShader("black", (barsize + 4), 12);			
					self.awe_plantbarbackground.color = (0,0,0);
					self.awe_plantbarbackground setShader("white", (barsize + 4), 12);			
					// Progress bar
					self.awe_plantbar = newClientHudElem(self);				
					self.awe_plantbar.alignX = "left";
					self.awe_plantbar.alignY = "middle";
					self.awe_plantbar.x = (320 - (barsize / 2.0));
					self.awe_plantbar.y = 405;
					self.awe_plantbar setShader("white", 0, 8);
					self.awe_plantbar scaleOverTime(bartime , barsize, 8);

					showTripwireMessage(sWeapon, level.awe_turretpickingmessage);

					// Play plant sound
					self playsound("moody_plant");
				}

				for(i=0;i<planttime*20;i++)
				{
					if( !(self meleeButtonPressed() && origin == self.origin && isAlive(self) && self.sessionstate=="playing") )
						break;
					wait 0.05;
				}

				// Remove hud elements
				if(isdefined(self.awe_plantbarbackground)) self.awe_plantbarbackground destroy();
				if(isdefined(self.awe_plantbar))		 self.awe_plantbar destroy();
				if(isdefined(self.awe_tripwiremessage))	self.awe_tripwiremessage destroy();
				if(isdefined(self.awe_tripwiremessage2))	self.awe_tripwiremessage2 destroy();
		
				self enableWeapon();
				if(i<planttime*20)
				{
					self.awe_checkdefusetripwire = undefined;
					return;
				}
			}
			// Remove tripwire
			tripwire notify("awe_monitortripwire");
			wait .05;
			if(isdefined(tripwire.nade1))
				tripwire.nade1 delete();
			if(isdefined(tripwire.nade2))
				tripwire.nade2 delete();
			if(isdefined(tripwire))
				tripwire delete();
			// Pick up grenades
			currentGrenade = self getWeaponSlotWeapon("grenade");
			if(currentGrenade == sWeapon)		// Same type, just increase ammo
			{
				iAmmo = self getWeaponSlotClipAmmo("grenade");
				self setWeaponSlotClipAmmo("grenade",iAmmo + 2);
			}
			else
			{
				// Drop current grenade if it exist and there is ammo
				if(isGrenade(currentGrenade) && self getWeaponSlotClipAmmo("grenade") )
					self dropItem(currentGrenade);
				// Pick defused grenades
				self setWeaponSlotWeapon("grenade",sWeapon);
				self setWeaponSlotClipAmmo("grenade",2);
			}
			break;
		}
		wait .05;

		// Check prone
		if(self getstance(true) != "2") break;
		// Check nades
		distance1 = distance(tripwire.nade1.origin, self.origin);
		distance2 = distance(tripwire.nade2.origin, self.origin);
		if(distance1>=range && distance2>=range) break;
	}

	// Clean up
	if(isdefined(self.awe_plantbarbackground)) self.awe_plantbarbackground destroy();
	if(isdefined(self.awe_plantbar))		 self.awe_plantbar destroy();
	if(isdefined(self.awe_tripwiremessage))	self.awe_tripwiremessage destroy();
	if(isdefined(self.awe_tripwiremessage2))	self.awe_tripwiremessage2 destroy();

	self.awe_checkdefusetripwire = undefined;
}

getGrenadeModel(sWeapon)
{
	switch(sWeapon)
	{
		case "fraggrenade_mp":
			model = "xmodel/weapon_MK2FragGrenade";
			break;

		case "mk1britishfrag_mp":
			model = "xmodel/weapon_british_handgrenade";
			break;

		case "rgd-33russianfrag_mp":
			model = "xmodel/weapon_russian_handgrenade";
			break;	

		default:
			model = "xmodel/weapon_nebelhandgrenate";
			break;
	}
	return model;
}

scriptedRadiusDamage(eAttacker, vOffset, sWeapon, iRange, iMaxDamage, iMinDamage, ignoreTK)
{
	if(!isdefined(vOffset))
		vOffset = (0,0,0);
	
	if(isdefined(sWeapon) && isGrenade(sWeapon))
	{
		sMeansOfDeath = "MOD_GRENADE_SPLASH";
		iDFlags = 1;
	}
	else
	{
		sMeansOfDeath = "MOD_EXPLOSIVE";
		iDFlags = 1;
	}

	// Loop through players
	players = getentarray("player", "classname");
	for(i=0;i<players.size;i++)
	{
		// Check that player is in range
		distance = distance((self.origin + vOffset), players[i].origin);
		if(distance>=iRange || players[i].sessionstate != "playing" || !isAlive(players[i]) )
			continue;

		if(players[i] != self)
		{
			percent = (iRange-distance)/iRange;
			iDamage = iMinDamage + (iMaxDamage - iMinDamage)*percent;

			if(isdefined(players[i].awe_spinemarker))
				traceorigin = players[i].awe_spinemarker.origin;
			else
				traceorigin = players[i].origin + (0,0,32);

			trace = bullettrace(self.origin + vOffset, traceorigin, true, self);
			if(isdefined(trace["entity"]) && trace["entity"] != players[i])
				iDamage = iDamage * .7;
			else if(!isdefined(trace["entity"]))
				iDamage = iDamage * .3;

			vDir = vectorNormalize(traceorigin - (self.origin + vOffset));
		}
		else
		{
			iDamage = iMaxDamage;
			vDir=(0,0,1);
		}
		if(ignoreTK && isPlayer(eAttacker) && isdefined(level.awe_teamplay) && isdefined(eAttacker.sessionteam) && isdefined(players[i].sessionteam) && eAttacker.sessionteam == players[i].sessionteam)
			players[i] thread [[level.callbackPlayerDamage]](self, self, iDamage, iDFlags, sMeansOfDeath, sWeapon, undefined, vDir, "none");
		else
			players[i] thread [[level.callbackPlayerDamage]](self, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, undefined, vDir, "none");
	}
}


pickupTurret()
{
	self endon("awe_spawned");
	self endon("awe_died");

	if(isdefined(self.awe_pickingturret)) return;
	self.awe_pickingturret = self.awe_touchingturret;


	// Time for progressbar		
	if(!isdefined(level.awe_turrets[self.awe_pickingturret]["dropped"]))
		picktime = level.awe_turretpicktime;
	else
		picktime = 0;
	

	// Show progress bar
	if(!isdefined(self.awe_pickbar) && picktime)
	{
		barsize = 288;
		pickingtime = 0;
		bartime = (float)picktime;

		if(isdefined(self.awe_turretmessage))	self.awe_turretmessage destroy();
		if(isdefined(self.awe_turretmessage2))	self.awe_turretmessage2 destroy();

		// Background
		self.awe_pickbarbackground = newClientHudElem(self);				
		self.awe_pickbarbackground.alignX = "center";
		self.awe_pickbarbackground.alignY = "middle";
		self.awe_pickbarbackground.x = 320;
		self.awe_pickbarbackground.y = 405;
		self.awe_pickbarbackground.alpha = 0.5;
//		self.awe_pickbarbackground setShader("black", (barsize + 4), 12);			
		self.awe_pickbarbackground.color = (0,0,0);
		self.awe_pickbarbackground setShader("white", (barsize + 4), 12);			

		// Progress bar
		self.awe_pickbar = newClientHudElem(self);				
		self.awe_pickbar.alignX = "left";
		self.awe_pickbar.alignY = "middle";
		self.awe_pickbar.x = (320 - (barsize / 2.0));
		self.awe_pickbar.y = 405;
		self.awe_pickbar setShader("white", 0, 8);
		self.awe_pickbar scaleOverTime(bartime , barsize, 8);
	
		self showTurretMessage(self.awe_pickingturret, level.awe_turretpickingmessage );

		// Play plant sound
		self playsound("moody_plant");

		for(i=0;i<picktime*20;i++)
		{
			if( !(	self meleeButtonPressed() && isAlive(self) && self.sessionstate=="playing" && 
					isdefined(self.awe_touchingturret) && self.awe_touchingturret == self.awe_pickingturret &&
					!isdefined(level.awe_turrets[self.awe_pickingturret]["carried"]) &&
					isdefined(level.awe_turrets[self.awe_pickingturret]["turret"])
				) )
				break;
			wait 0.05;
		}

		// Remove hud elements
		if(isdefined(self.awe_pickbarbackground))	self.awe_pickbarbackground destroy();
		if(isdefined(self.awe_pickbar))		self.awe_pickbar destroy();
		if(isdefined(self.awe_turretmessage))	self.awe_turretmessage destroy();
		if(isdefined(self.awe_turretmessage2))	self.awe_turretmessage2 destroy();

		self enableWeapon();
		if(i<picktime*20)
		{
			self.awe_pickingturret = undefined;
			return false;
		}
	}

	// Make sure turret is not carried(=just picked up) and that it still exist.
	if(!isdefined(level.awe_turrets[self.awe_pickingturret]["carried"]) && isdefined(level.awe_turrets[self.awe_pickingturret]["turret"]))
	{
		level.awe_turrets[self.awe_pickingturret]["carried"] = true;
		level.awe_turrets[self.awe_pickingturret]["turret"] delete();
		level.awe_turrets[self.awe_pickingturret]["dropped"] = undefined;
		self.awe_carryingturret = self.awe_pickingturret;
		self.awe_pickingturret = undefined;
		if(isdefined(self.awe_turretmessage))	self.awe_turretmessage destroy();
		if(isdefined(self.awe_turretmessage2))	self.awe_turretmessage2 destroy();
		self showTurretIndicator();
		self thread checkTurretPlacement();
	}

	self.awe_pickingturret = undefined;
}

whatscooking()
{
	self endon("awe_spawned");
	self endon("awe_died");

/*
	self.awe_oldyaw1 = self.angles[1];
	self.awe_oldyaw2 = self.awe_oldyaw1;
	self.awe_oldyaw3 = self.awe_oldyaw2;
	self.awe_oldyaw4 = self.awe_oldyaw3;
	self.awe_oldyaw5 = self.awe_oldyaw4;
	self.awe_oldyaw6 = self.awe_oldyaw5;
*/
	// Loop as long as the cooktimer has not reached zero	
	while (isAlive(self) && self.sessionstate == "playing")
	{
/*		// Save yaw angles for anticheating code
		self.awe_oldyaw6 = self.awe_oldyaw5;
		self.awe_oldyaw5 = self.awe_oldyaw4;
		self.awe_oldyaw4 = self.awe_oldyaw3;
		self.awe_oldyaw3 = self.awe_oldyaw2;
		self.awe_oldyaw2 = self.awe_oldyaw1;
		self.awe_oldyaw1 = self.angles[1];
*/
		// Wait
		wait .05;

		// get current weapon
		cw = self getCurrentWeapon();
		attackButton = self attackButtonPressed();

		// Is the current weapon a grenade and is it being cooked?
		if(!isdefined(nocook) && attackButton && isGrenade(cw) && !isdefined(self.awe_cooking))
			self thread cookgrenade();

		meleeButton = self meleeButtonPressed();

		if( level.awe_tripwire && isGrenade(cw) && self getStance(true)==2 && !isDefined(self.awe_turretmessage) && !isDefined(self.awe_tripwiremessage))
			self thread checkTripwirePlacement();

		if(isdefined(self.awe_touchingturret))
		{
			// Check for turrets to pick up
			// Make sure we have not placed a turret and is still holding meleebutton and that we are touching turret
			if(!isdefined(self.awe_carryingturret) && meleeButton && !isdefined(self.awe_placingturret) && !isdefined(self.pickingturret))
			{
				self thread pickupTurret();
				continue;
			}

			// Do not recheck if we are still touching the same turret
			// Check so it has not been picked up
			if( isdefined(level.awe_turrets[self.awe_touchingturret]["turret"]) && !isdefined(level.awe_turrets[self.awe_touchingturret]["carried"]) )
			{
				// Is it dropped?
				if( isdefined(level.awe_turrets[self.awe_touchingturret]["dropped"]) )
				{
					if( distance(self.origin,level.awe_turrets[self.awe_touchingturret]["turret"].origin) < 50) // Within range?
					{
						if(!isdefined(self.awe_turretmessage) && !isdefined(self.awe_carryingturret) && !isdefined(self.awe_pickingturret) && !isdefined(self.awe_placingturret))
							self showTurretMessage(self.awe_touchingturret,level.awe_turretpickupmessage);
						continue;
					}
				}
				else	// Non-dropped turret
				{
					if (self istouching(level.awe_turrets[self.awe_touchingturret]["turret"])) // Am I touching it?
					{
//						handpos = self.awe_headmarker.origin;
//						turretpos = level.awe_turrets[self.awe_touchingturret]["turret"].origin + (0,0,12);
//						line(handpos, turretpos, (0,1,0) );
//						turretdist = (int)distance(handpos, turretpos);
//						self iprintlnbold("turretdist: " + turretdist);

						if(!isdefined(self.awe_turretmessage) && !isdefined(self.awe_carryingturret) && !isdefined(self.awe_pickingturret) && !isdefined(self.awe_placingturret))
							self showTurretMessage(self.awe_touchingturret,level.awe_turretpickupmessage);
						continue;
					}
				}
			}
		}
	
		// Only clear nocook if attackButton is released. (To avoid incorrectly timed progress bar if moving away from a turret)
		if(!attackButton)
			nocook = undefined;

		// Check if we are touching any turrets
		self.awe_touchingturret = undefined;
		for (i=0;i<level.awe_turrets.size;i++)
		{
			// Is it carried by someone?
			if (isdefined(level.awe_turrets[i]["carried"])) continue;
			// Make sure it exist
			if (!isdefined(level.awe_turrets[i]["turret"])) continue;					

			// Is it dropped?
			if(isdefined(level.awe_turrets[i]["dropped"]))
			{
				if( !level.awe_turretmobile || isdefined(self.cannotcarryturret) )
					continue;

				if( distance(self.origin,level.awe_turrets[i]["turret"].origin) < 50) // Within range?
				{
					self.awe_touchingturret = i;
					if(!isdefined(self.awe_turretmessage) && !isdefined(self.awe_carryingturret) && !isdefined(self.awe_pickingturret) && !isdefined(self.awe_placingturret))
						self showTurretMessage(i,level.awe_turretpickupmessage);
				}
			}
			else
			{
				if (self istouching(level.awe_turrets[i]["turret"])) // Am I touching it?
				{
					// Make sure we cannot start cooking while touching a turret
					nocook = true;

					// Is this a turret type that we are allowed to pickup?
					if(!level.awe_turretmobile || isdefined(self.cannotcarryturret) )
						continue;

					// Only indicate touching of this if we are not allready touching a dropped turret
					if(!isdefined(self.awe_touchingturret))
						self.awe_touchingturret = i;

					if(!isdefined(self.awe_turretmessage) && !isdefined(self.awe_carryingturret) && !isdefined(self.awe_pickingturret) && !isdefined(self.awe_placingturret) )
					{
						self showTurretMessage(i,level.awe_turretpickupmessage);
						if(level.awe_debug)
						{
							self iprintlnbold("x:" + (int)(level.awe_turrets[i]["turret"].origin[0] + 0.5) + 
										" y:" + (int)(level.awe_turrets[i]["turret"].origin[1] + 0.5) +
										" z:" + (int)(level.awe_turrets[i]["turret"].origin[2] + 0.5) +
										" a:" + (int)(level.awe_turrets[i]["turret"].angles[1] + 0.5) +
										" w:" + level.awe_turrets[i]["turret"].weaponinfo);
						}
					}

					// If we got here, then we found a turret that we can pick up
					break;	// don't check any more turrets.
				}
			}
		}
		if(!isdefined(self.awe_touchingturret) && !isdefined(self.awe_carryingturret) && !isdefined(self.awe_pickingturret))
		{
			if(isdefined(self.awe_turretmessage))	self.awe_turretmessage destroy();
			if(isdefined(self.awe_turretmessage2))	self.awe_turretmessage2 destroy();
		}
	}
	if(isdefined(self.awe_turretmessage))	self.awe_turretmessage destroy();
	if(isdefined(self.awe_turretmessage2))	self.awe_turretmessage2 destroy();
}

//Method to show the turret message passed by parameter
showTurretMessage( turret, which_message )
{
	if(isdefined(self.awe_turretmessage))	self.awe_turretmessage destroy();
	if(isdefined(self.awe_turretmessage2))	self.awe_turretmessage2 destroy();

	self.awe_turretmessage = newClientHudElem( self );
	self.awe_turretmessage.alignX = "center";
	self.awe_turretmessage.alignY = "middle";
	self.awe_turretmessage.x = 320;
	self.awe_turretmessage.y = 404;
	self.awe_turretmessage.alpha = 1;
	self.awe_turretmessage.fontScale = 0.80;
	if( 	(isdefined(level.awe_turretpickingmessage) && which_message == level.awe_turretpickingmessage) ||
		(isdefined(level.awe_turretplacingmessage) && which_message == level.awe_turretplacingmessage) )
		self.awe_turretmessage.color = (.5,.5,.5);
	self.awe_turretmessage setText( which_message );

	self.awe_turretmessage2 = newClientHudElem(self);
	self.awe_turretmessage2.alignX = "center";
	self.awe_turretmessage2.alignY = "top";
	self.awe_turretmessage2.x = 320;
	self.awe_turretmessage2.y = 415;
	if(level.awe_turrets[turret]["type"]=="misc_mg42")
		self.awe_turretmessage2 setShader("gfx/hud/hud@death_mg42.tga",90,30);
	else
		self.awe_turretmessage2 setShader("gfx/hud/hud@death_antitank.tga",90,30);
}

showTurretIndicator()
{
	if (!isdefined(self.awe_turretindicator)) {
		self.awe_turretindicator = newClientHudElem(self);
		self.awe_turretindicator.alignX = "left";
		self.awe_turretindicator.alignY = "top";
		self.awe_turretindicator.x = 570;
		self.awe_turretindicator.y = 350;
		if(level.awe_turrets[self.awe_carryingturret]["type"]=="misc_mg42")
			self.awe_turretindicator setShader("gfx/hud/hud@death_mg42.tga",60,20);
		else
			self.awe_turretindicator setShader("gfx/hud/hud@death_antitank.tga",60,20);
	}
}

removeTurretIndicator()
{
	if (isdefined(self.awe_turretindicator)) self.awe_turretindicator destroy();
}

//Drops a turret at player's feet if player had one. Called when player bites the dust.
dropTurret(position, sMeansOfDeath)
{
	if ( !isdefined(self.awe_carryingturret) ) return;

	if(!isdefined(position))
		position = self.origin;

	t 	= self.awe_carryingturret;
	type	= level.awe_turrets[t]["type"];

	// Harry Potter was here...
	if(level.awe_turretrecover)
	{
		// Check if player died in a minefield
		minefields = getentarray( "minefield", "targetname" );
		if( minefields.size > 0 )
		{
			for( i = 0; i < minefields.size; i++ )
			{
				if( minefields[i] istouching( self ) )
				{
					touching = true;
					break;
				}
			}
		}
		
		// If player died in minefield or was killed by a trigger, replace turret
		if( isdefined(touching) || sMeansOfDeath == "MOD_TRIGGER_HURT" )
		{
			// If original position was a placed one, place a real turret
			if(isdefined(level.awe_turrets[t]["original_weaponinfo"]))
			{
				position	= level.awe_turrets[t]["original_position"];
				angles	= level.awe_turrets[t]["original_angles"];
				weaponinfo	= level.awe_turrets[t]["original_weaponinfo"];

				if(type == "misc_ptrs")
					model = "xmodel/weapon_antitankrifle";
				else
					model = "xmodel/mg42_bipod";

				if(level.awe_turretmobile==2)		//the -10000 z offset is to spawn the MG off the map.   
					level.awe_turrets[t]["turret"] = spawnTurret( type, position + (0,0,-10000), weaponinfo );
				else
					level.awe_turrets[t]["turret"] = spawnTurret( type, position, weaponinfo );
				level.awe_turrets[t]["turret"] setmodel( model );
				level.awe_turrets[t]["turret"].weaponinfo = weaponinfo;
				level.awe_turrets[t]["turret"].angles = angles;
				if(level.awe_turretmobile==2) wait 0.2;
				level.awe_turrets[t]["turret"].origin = position;//do this LAST. It'll move the MG into a usable position
				level.awe_turrets[t]["dropped"] = undefined;
				level.awe_turrets[t]["carried"] = undefined;

				self.awe_carryingturret=undefined;
				removeTurretIndicator();
				return;	// Don't go further
			}
			else		// If it was a dropped one, just get the position and continue
				position = level.awe_turrets[self.awe_carryingturret]["original_position"];
		}
	}

	trace=bulletTrace(position+(0,0,10),position+(0,0,-1200),false,undefined); 
	ground=trace["position"];

	if(level.awe_turrets[self.awe_carryingturret]["type"] == "misc_ptrs")
	{
		angles = (0,randomInt(360),112);
		model = "xmodel/weapon_antitankrifle";
		type = "dropped_ptrs";
	}
	else
	{
		angles = (0,randomInt(360),125);
		model = "xmodel/mg42_bipod";
		type = "dropped_mg42";
	}	

	ground += (0,0,11);

	level.awe_turrets[self.awe_carryingturret]["turret"] = spawn ("script_model", ground);
	level.awe_turrets[self.awe_carryingturret]["turret"] . targetname = type;
 	level.awe_turrets[self.awe_carryingturret]["turret"] setmodel ( model );
	level.awe_turrets[self.awe_carryingturret]["turret"] . angles = angles;
	level.awe_turrets[self.awe_carryingturret]["turret"] . origin = ground;
	level.awe_turrets[self.awe_carryingturret]["dropped"] = true;
	level.awe_turrets[self.awe_carryingturret]["carried"] = undefined;
 
	self.awe_carryingturret=undefined;
	removeTurretIndicator();
}

//Thread to determine if a player can place a carried turret
checkTurretPlacement()
{
	level endon("awe_boot");
	self endon("awe_spawned");
	self endon("awe_died");

	//stay here until player lets go of melee button
	//keeps mg from accidently being placed as soon as it is picked up
	while( isAlive( self ) && self meleeButtonPressed() )
		wait( 0.1 );

	while( isAlive( self ) && isDefined( self.awe_carryingturret )  && self.sessionstate=="playing")
	{
		//previous position and angles, in case player goes spec or changes team
		oldposition = self.origin;
		oldangles = self.angles;

		stance = getStance(true);
		pos = getTurretPlacement(stance);
		//check if player can put down carried mg
		if( isdefined(pos) )
		{
			self showTurretMessage(self.awe_carryingturret, level.awe_turretplacemessage );

			//wait for melee button, death, or player movement
			while( isAlive( self ) && !self meleeButtonPressed() && isdefined(pos) )
			{
				oldposition = self.origin;
				oldangles = self.angles;
				wait( 0.1 );
				stance = getStance(true);
				pos = getTurretPlacement(stance);
			}

			if(isdefined(self.awe_turretmessage))	self.awe_turretmessage destroy();
			if(isdefined(self.awe_turretmessage2))	self.awe_turretmessage2 destroy();

			if( isAlive( self ) && self.sessionstate == "playing" && self meleeButtonPressed() && isdefined(pos) )
				if(self placeTurret(pos,stance)) return;	// End thread if placing was a success
		}
		wait( 0.2 );
	}

	//execution gets here if player died or went spectator
	if( isdefined( self.awe_carryingturret ) && self.sessionstate!="playing" )
	{
		dropTurret(oldposition, undefined);
	}
}

//Method to determine the possible position to place a carried MG42
getTurretPlacement(stance)
{
	if(!isdefined(stance))
		stance=GetStance(true);

	if( stance == 0 )
		startheight = 66;//height from which to bullettrace downwards
	else if( stance == 1 )
		startheight = 42;
	else if( stance == 2 )
		startheight = 18;
	else
		return undefined;//jumping! Don't allow placement. This leads to abuse.

	type = level.awe_turrets[self.awe_carryingturret]["type"];

	// PTRS41 can only be mounted in prone.
	if(type == "misc_ptrs" && stance != 2)
		return undefined;

	//find the height of the ceiling
	trace = bulletTrace( self.origin, self.origin + ( 0, 0, 80 ), false, undefined );
	ceiling = trace[ "position" ];
	maxheight = ceiling[2] - self.origin[2];
	if( startheight > maxheight-1 )
		startheight = maxheight-1;//the -1 makes sure we start below the ceiling

	checkstart = self.origin;
	valid = false;

	if(type == "misc_ptrs")
		frontbarrellength=42;
	else
		frontbarrellength=16;		//estimates of the mg's size. Used to make sure mg doesn't stick through something
	rearbarrellength = 58;//actual gun is around 46, the extra inches make sure players don't stick through walls when using mg rotated
	gunheight = 12;

	gunforward = maps\mp\_utility::vectorScale( anglesToForward( self.angles ), frontbarrellength );
	gunbackward = maps\mp\_utility::vectorScale( anglesToForward( self.angles ), -1 * rearbarrellength );

	gunleftforward = ( -1 * gunforward[1], gunforward[0], 0 );//front part of gun when rotated 90 degrees left
	gunleftback = ( -1 * gunbackward[1], gunbackward[0], 0 );//back part of gun when rotated 90 degrees right

	pt1 = gunforward + ( 0, 0, gunheight );//front part point straight
	pt2 = gunbackward + ( 0, 0, gunheight );//back part pointed straight
	pt3 = maps\mp\_utility::vectorScale( gunforward + gunleftforward, 0.7 ) + ( 0, 0, gunheight );//front part 45 deg left
	pt4 = maps\mp\_utility::vectorScale( gunforward - gunleftforward, 0.7 ) + ( 0, 0, gunheight );//front part 45 deg right
	pt5 = maps\mp\_utility::vectorScale( gunbackward + gunleftback, 0.7 ) + ( 0, 0, gunheight );//back part pointed 45 right
	pt6 = maps\mp\_utility::vectorScale( gunbackward - gunleftback, 0.7 ) + ( 0, 0, gunheight );//back part pointed 45 left

	//first trace at 42 inches in front of player
	forward = maps\mp\_utility::vectorScale( anglesToForward( self.angles ), 42 );
	trace = bulletTrace( checkstart + forward + ( 0, 0, startheight ), checkstart + forward + ( 0, 0, -60 ), false, undefined );
	pos = trace["position"];
	height = pos[2] + gunheight - checkstart[2];

	if( stance==0 && height >= 42 && height < startheight )
		valid = true;
	else if( stance == 1 && height >= 30 && height < startheight )
		valid = true;
	else if( stance == 2 && height < startheight && height > 0 )
		valid = true;

	//check if the gun would have enough space in front of bipod, to prevent placement abuse
	if( valid )
	{
		trace = bulletTrace( pos + pt1, pos + pt2, false, undefined );
		if( trace["fraction"] < 1 )
			valid = false;
		trace = bulletTrace( pos + pt3, pos + pt5, false, undefined );
		if( trace["fraction"] < 1 )
			valid = false;
		trace = bulletTrace( pos + pt6, pos + pt4, false, undefined );
		if( trace["fraction"] < 1 )
			valid = false;
		trace = bulletTrace( pos + pt6, pos + pt5, false, undefined );
		if( trace["fraction"] < 1 )
			valid = false;
	}

	if( !valid )
	{
		forward = maps\mp\_utility::vectorScale( anglesToForward( self.angles ), 46 );

		//second trace at 46 inches in front of player
		trace = bulletTrace( checkstart + forward + ( 0, 0, startheight ), checkstart + forward + ( 0, 0, -60 ), false, undefined );
		pos=trace["position"];
   
		height = pos[2] + gunheight - checkstart[2];

		if( stance == 0 && height >= 42 && height < startheight )
			valid = true;
		else if( stance == 1 && height >= 30 && height < startheight )
			valid = true;
		else if( stance == 2 && height< startheight && height > 0 )
			valid = true;

		//check if the gun would have enough space in front of bipod, to prevent placement abuse
		if( valid )
		{
			trace = bulletTrace( pos + pt1, pos + pt2, false, undefined );
			if( trace["fraction"] < 1 )
				valid = false;
			trace = bulletTrace( pos + pt3, pos + pt5, false, undefined );
			if( trace["fraction"] < 1 )
				valid = false;
			trace = bulletTrace( pos + pt6, pos + pt4, false, undefined );
			if( trace["fraction"] < 1 )
				valid = false;
			trace = bulletTrace( pos + pt6, pos + pt5, false, undefined );
			if( trace["fraction"] < 1 )
				valid = false;
		}
	}
	if( !valid )
	{
		forward = maps\mp\_utility::vectorScale( anglesToForward( self.angles ), 50 );

		//third trace at 50 inches in front of player
		trace = bulletTrace( checkstart + forward + ( 0, 0, startheight ), checkstart + forward + ( 0, 0, -60 ), false, undefined );
		pos = trace["position"];

		height = pos[2] + gunheight - checkstart[2];

		if( stance == 0 && height >= 42 && height < startheight )
			valid = true;
		else if( stance == 1 && height >= 30 && height < startheight )
			valid = true;
		else if( stance == 2 && height < startheight && height > 0 )
			valid = true;

		//check if the gun would have enough space in front of bipod, to prevent placement abuse
		if( valid )
		{
			trace = bulletTrace( pos + pt1, pos + pt2, false, undefined );
			if( trace["fraction"] < 1 )
				valid = false;
			trace = bulletTrace( pos + pt3, pos + pt5, false, undefined );
			if( trace["fraction"] < 1 )
				valid = false;
			trace = bulletTrace( pos + pt6, pos + pt4, false, undefined );
			if( trace["fraction"] < 1 )
				valid = false;
			trace = bulletTrace( pos + pt6, pos + pt5, false, undefined );
			if( trace["fraction"] < 1 )
				valid = false;
		}
	}

	if( valid )
		return pos;

	return undefined;
}

//Method to determine a player's current stance
GetStance(checkjump)
{
	if( checkjump && !self isOnGround() ) 
		return 3;

	if(isdefined(self.awe_spinemarker))
	{
		distance = self.awe_spinemarker.origin[2] - self.origin[2];
		if(distance<18)
			return 2;
		else if(distance<39)
			return 1;
		else
			return 0;
	}
	else
	{
		trace = bulletTrace( self.origin, self.origin + ( 0, 0, 80 ), false, undefined );
		top = trace["position"] + ( 0, 0, -1);//find the ceiling, if it's lower than 80

		bottom = self.origin + ( 0, 0, -12 );
		forwardangle = maps\mp\_utility::vectorScale( anglesToForward( self.angles ), 12 );

		leftangle = ( -1 * forwardangle[1], forwardangle[0], 0 );//a lateral vector

		//now do traces at different sample points
		//there are 9 sample points, forming a 3x3 grid centered on player's origin
		//and oriented with the player's facing
		trace = bulletTrace( top + forwardangle,bottom + forwardangle, true, undefined );
		height1 = trace["position"][2] - self.origin[2];

		trace = bulletTrace( top - forwardangle, bottom - forwardangle, true, undefined );
		height2 = trace["position"][2] - self.origin[2];
	
		trace = bulletTrace( top + leftangle, bottom + leftangle, true, undefined );
		height3 = trace["position"][2] - self.origin[2];
	
		trace = bulletTrace( top - leftangle, bottom - leftangle, true, undefined );
		height4 = trace["position"][2] - self.origin[2];

		trace = bulletTrace( top + leftangle + forwardangle, bottom + leftangle + forwardangle, true, undefined );
		height5 = trace["position"][2] - self.origin[2];

		trace = bulletTrace( top - leftangle + forwardangle, bottom - leftangle + forwardangle, true, undefined );
		height6 = trace["position"][2] - self.origin[2];

		trace = bulletTrace( top + leftangle - forwardangle, bottom + leftangle - forwardangle, true, undefined );
		height7 = trace["position"][2] - self.origin[2];	

		trace = bulletTrace( top - leftangle - forwardangle, bottom - leftangle - forwardangle, true, undefined );
		height8 = trace["position"][2] - self.origin[2];

		trace = bulletTrace( top, bottom, true, undefined );
		height9 = trace["position"][2] - self.origin[2];	

		//find the maximum of the height samples
		heighta = getMax( height1, height2, height3, height4 );
		heightb = getMax( height5, height6, height7, height8 );
		maxheight = getMax( heighta, heightb, height9, 0 );

		//categorize stance based on height
		if( maxheight < 25 )
			stance = 2;
		else if( maxheight < 52 )
			stance = 1;
		else
			stance = 0;

		//self iprintln("Height: "+maxheight+" Stance: "+stance);
		return stance;
	}
}

//Method that returns the maximum of a, b, c, and d
getMax( a, b, c, d )
{
	if( a > b )
		ab = a;
	else
		ab = b;
	if( c > d )
		cd = c;
	else
		cd = d;
	if( ab > cd )
		m = ab;
	else
		m = cd;
	return m;
}

placeTurret(pos, stance)
{
	self endon("awe_spawned");
	self endon("awe_died");

	// If not carrying a turret, return and end thread
	if( !isDefined( self.awe_carryingturret ) )
		return true;

	if(!isdefined(stance)) stance = getStance(true);   

	type = level.awe_turrets[self.awe_carryingturret]["type"];

	// PTRS41 can only be mounted in prone.
	if(type == "misc_ptrs" && stance != 2)
		return false;

	if(!isdefined(pos)) pos = getTurretPlacement(stance);

	if( !isDefined( pos ) )
		return false;

	if( stance == 1 || stance == 0 )
	{
		//do a trace upward to see if we're in a porthole
		trace = bulletTrace( pos + ( 0, 0, 2 ), pos + ( 0, 0, 25 ), false, undefined );
		if( trace["fraction"] < 1 )
			pos = pos + ( 0, 0, -11 );
	}
	origin = self.origin;
	angles = self.angles;

	// Ok to plant, show progress bar
	if(level.awe_turretplanttime)
		planttime = level.awe_turretplanttime;
	else
		planttime = undefined;

	if(isdefined(planttime))
	{
		self disableWeapon();
		if(!isdefined(self.awe_plantbar))
		{
			barsize = 288;
			// Time for progressbar	
			bartime = (float)planttime;

			// Background
			self.awe_plantbarbackground = newClientHudElem(self);				
			self.awe_plantbarbackground.alignX = "center";
			self.awe_plantbarbackground.alignY = "middle";
			self.awe_plantbarbackground.x = 320;
			self.awe_plantbarbackground.y = 405;
			self.awe_plantbarbackground.alpha = 0.5;
//			self.awe_plantbarbackground setShader("black", (barsize + 4), 12);			
			self.awe_plantbarbackground.color = (0,0,0);
			self.awe_plantbarbackground setShader("white", (barsize + 4), 12);			
			// Progress bar
			self.awe_plantbar = newClientHudElem(self);				
			self.awe_plantbar.alignX = "left";
			self.awe_plantbar.alignY = "middle";
			self.awe_plantbar.x = (320 - (barsize / 2.0));
			self.awe_plantbar.y = 405;
			self.awe_plantbar setShader("white", 0, 8);
			self.awe_plantbar scaleOverTime(bartime , barsize, 8);

			self showTurretMessage(self.awe_carryingturret, level.awe_turretplacingmessage );

			// Play plant sound
			self playsound("moody_plant");
		}

		for(i=0;i<planttime*20;i++)
		{
			if( !(self meleeButtonPressed() && origin == self.origin && isAlive(self) && self.sessionstate=="playing") )
				break;
			wait 0.05;
		}

		// Remove hud elements
		if(isdefined(self.awe_plantbarbackground)) self.awe_plantbarbackground destroy();
		if(isdefined(self.awe_plantbar))		 self.awe_plantbar destroy();
		if(isdefined(self.awe_turretmessage))	 self.awe_turretmessage destroy();
		if(isdefined(self.awe_turretmessage2))	 self.awe_turretmessage2 destroy();

		self enableWeapon();
		if(i<planttime*20)
			return false;
	}

	self removeTurretIndicator();
	self.awe_placingturret = true;
	placeTurretAt( pos + ( 0, 0, -1 ), angles, stance );
	self.awe_carryingturret = undefined;
	if(isdefined(self.awe_turretmessage))	 self.awe_turretmessage destroy();
	if(isdefined(self.awe_turretmessage2))	 self.awe_turretmessage2 destroy();
	while(self meleeButtonPressed())
		wait(0.05);
	self.awe_placingturret = undefined;
	return true;	// return and end thread
}

placeTurretAt( position, angles, stance )
{
	type = level.awe_turrets[self.awe_carryingturret]["type"];

	if(type == "misc_ptrs")
		model = "xmodel/weapon_antitankrifle";
	else
		model = "xmodel/mg42_bipod";

	if( stance == 2 && type == "misc_ptrs")
		weaponinfo = "PTRS41_Antitank_Rifle_mp";
	else if( stance == 2 )
		weaponinfo = "mg42_bipod_prone_mp";
	else if( stance == 1 )
		weaponinfo = "mg42_bipod_duck_mp";
	else if( stance == 0 )
		weaponinfo = "mg42_bipod_stand_mp";
	
	if(level.awe_turretmobile == 2)		//the -10000 z offset is to spawn the MG off the map.   
		level.awe_turrets[self.awe_carryingturret]["turret"] = spawnTurret( type, position + ( 0, 0, -10000 ), weaponinfo );
	else
		level.awe_turrets[self.awe_carryingturret]["turret"] = spawnTurret( type, position, weaponinfo );
	level.awe_turrets[self.awe_carryingturret]["turret"] setmodel( model );
	level.awe_turrets[self.awe_carryingturret]["turret"].weaponinfo = weaponinfo;
	level.awe_turrets[self.awe_carryingturret]["turret"].angles = angles;
	if(level.awe_turretmobile == 2)
		wait .2;	// Give turret time to initialize
	level.awe_turrets[self.awe_carryingturret]["turret"].origin = position;//do this LAST. It'll move the MG into a usable position
	level.awe_turrets[self.awe_carryingturret]["dropped"] = undefined;
	level.awe_turrets[self.awe_carryingturret]["carried"] = undefined;
}
/*
testBounce()
{
	while(self meleebuttonPressed())
	{
		// Spawn object 150 inches in front of the player
		offset = maps\mp\_utility::vectorScale( anglesToForward( self.angles ), 150 ) + (0,0,300);
		model = spawn("script_model", self.origin + offset );

		random = randomInt(2);
		random = 0;
		if(isdefined(self.hatmodel) && random)
		{
			model setmodel( self.hatmodel);
			offset = (0,0,-6);
			radius = 6;
		}
		else
		{
			model setmodel( self.awe_headmodel);
			offset = (0,-2.5,-18);
			radius = 6;
		}

		model.angles = ( 0, self.angles[1], 0 );

		rotation = ( randomFloat(540), randomFloat(540), randomFloat(540));
//		p = getcvarfloat("rotp");	
//		r = getcvarfloat("rotr");	
//		y = getcvarfloat("roty");	
//		rotation = (p,r,y);

//		x = getcvar("offsetx");
//		y = getcvar("offsety");
//		z = getcvar("offsetz");
//		offset = (x,y,z);

		if(isdefined(self.hatmodel) && random)
		{
			model thread bounceObject( rotation, (0,0,0), offset, (-90,0,0), radius, 30, 0.8, "grenade_bounce_default", undefined );
		}
		else
		{
			model thread bounceObject( rotation, (-3 + randomFloat(6),-3 + randomFloat(6),0), offset, (-90,0,0), radius, 30, 0.8, "bodyfall_flesh_large", level.awe_popheadfx );
		}
		wait .2;
	}

}
*/

popHead( damageDir, damage)
{
	self.awe_headpopped = true;

	if(isdefined(level.awe_merciless))
		return;

	if(!isdefined(self.awe_helmetpopped))
		self popHelmet( damageDir, damage );

	if(!isdefined(self.awe_headmodel))
		return;

	self detach( self.awe_headmodel , "");
	playfxontag (level.awe_popheadfx,self,"Bip01 Head");

//	if(damage>100) damage = 100;

	switch(self getStance(false))
	{
		case 2:
			headoffset = (0,0,15);
			break;
		case 1:
			headoffset = (0,0,44);
			break;
		default:
			headoffset = (0,0,64);
			break;
	}
	
	rotation = (randomFloat(540), randomFloat(540), randomFloat(540));
	offset = (0,-1.5,-18);
	radius = 6;
	velocity = maps\mp\_utility::vectorScale(damageDir, (damage/20 + randomFloat(5)) ) + (0,0,(damage/20 + randomFloat(5)) );

	head = spawn("script_model", self.origin + headoffset );
	head setmodel( self.awe_headmodel );
	head.angles = self.angles;
	head thread bounceObject(rotation, velocity, offset, (-90,0,-90), radius, level.awe_popheadstay, 0.75, "bodyfall_flesh_large", level.awe_popheadfx);
}

popHelmet( damageDir, damage)
{
}

//
// bounceObject
//
// rotation		(pitch, yaw, roll) degrees/seconds
// velocity		start velocity
// offset		offset between the origin of the object and the desired rotation origin.
// angles		angles offset between anchor and object
// radius		radius between rotation origin and object surfce
// ttl		time to live
// falloff		velocity falloff for each bounce 0 = no bounce, 1 = bounce forever
// bouncesound	soundalias played at bounching
// bouncefx		effect to play on bounce
//
bounceObject(vRotation, vVelocity, vOffset, angles, radius, ttl, falloff, bouncesound, bouncefx )
{
	level endon("awe_boot");

	// Hide until everthing is setup
	self hide();

	// Setup default values
	if(!isdefined(vRotation))	vRotation = (0,0,0);
	pitch = (float)vRotation[0]/(float)20;	// Pitch/frame
	yaw	= (float)vRotation[1]/(float)20;	// Yaw/frame
	roll	= (float)vRotation[2]/(float)20;	// Roll/frame

	if(!isdefined(vVelocity))	vVelocity = (0,0,0);
	if(!isdefined(vOffset))		vOffset = (0,0,0);
	if(!isdefined(falloff))		falloff = 0.5;
	if(!isdefined(ttl))		ttl = 30;

	// Spawn anchor (the object that we will rotate)
	anchor = spawn("script_model", self.origin );
	anchor.angles = self.angles;

	// Link to anchor
	self linkto( anchor, "", vOffset, angles );
	self show();
	wait .05;	// Let it happen

	// Set gravity
	vGravity = (0,0,-2);

	stopme = 0;
	// Drop with gravity
	while(1)
	{
		// Let gravity do, what gravity do best
		vVelocity +=vGravity;

		// Get destination origin
		neworigin = anchor.origin + vVelocity;

		// Check for impact, check for entities but not myself.
		trace=bulletTrace(anchor.origin,neworigin,true,self); 
		if(trace["fraction"] != 1)	// Hit something
		{
			// Place object at impact point - radius
			distance = distance(anchor.origin,trace["position"]);
			if(distance)
			{
				fraction = (distance - radius) / distance;
				delta = trace["position"] - anchor.origin;
				delta2 = maps\mp\_utility::vectorScale(delta,fraction);
				neworigin = anchor.origin + delta2;
			}
			else
				neworigin = anchor.origin;


			// Play sound if defined
			if(isdefined(bouncesound)) anchor playSound(bouncesound);

			// Test if we are hitting ground and if it's time to stop bouncing
			if(vVelocity[2] <= 0 && vVelocity[2] > -10) stopme++;
			if(stopme==5) break;

			// Play effect if defined and it's a hard hit
			if(isdefined(bouncefx) && length(vVelocity) > 20) playfx(bouncefx,trace["position"]);

			// Decrease speed for each bounce.
			vSpeed = length(vVelocity) * falloff;

			// Calculate new direction (Thanks to Hellspawn this is finally done correctly)
			vNormal = trace["normal"];
			vDir = maps\mp\_utility::vectorScale(vectorNormalize( vVelocity ),-1);
			vNewDir = ( maps\mp\_utility::vectorScale(maps\mp\_utility::vectorScale(vNormal,2),vectorDot( vDir, vNormal )) ) - vDir;

			// Scale vector
			vVelocity = maps\mp\_utility::vectorScale(vNewDir, vSpeed);
	
			// Add a small random distortion
			vVelocity += (randomFloat(1)-0.5,randomFloat(1)-0.5,randomFloat(1)-0.5);
		}

		anchor.origin = neworigin;

		// Rotate pitch
		a0 = anchor.angles[0] + pitch;
		while(a0<0) a0 += 360;
		while(a0>359) a0 -=360;

		// Rotate yaw
		a1 = anchor.angles[1] + yaw;
		while(a1<0) a1 += 360;
		while(a1>359) a1 -=360;

		// Rotate roll
		a2 = anchor.angles[2] + roll;
		while(a2<0) a2 += 360;
		while(a2>359) a2 -=360;
		anchor.angles = (a0,a1,a2);
		
		// Wait one frame
		wait .05;
		ttl -= .05;
		if(ttl<=0) break;
	}

	// Set origin to impactpoint	
	anchor.origin = neworigin;

	// Unlink and remove the anchor
	self unlink();
	anchor delete();

	// Stay for the specified amount of time
	if(ttl>0) wait ttl;

	// Vanish
	self delete();
}

letItRain()
{
	level endon("awe_boot");

	if(isdefined(level.awe_raining)) return;
	level.awe_raining = true;
		
	while(getcvar("let_it_all_pour_down")=="1")
	{
		allplayers = getentarray("player", "classname");
		for(i = 0; i < allplayers.size; i++)
		{
			player = allplayers[i];
			if( isDefined(player) && isAlive(player) && player.sessionstate == "playing" )
			{
				offset = (-500 + randomInt(1000),-500 + randomInt(1000),700 + randomInt(100) );

				if(isdefined(level.awe_merciless))
				{
					if(isdefined(player.headshotModel))
						player.awe_headmodel = player.headshotModel;
					else if(isdefined(player.head_damage3))
						player.awe_headmodel = player.head_damage3;
					else if(isdefined(player.head_damage2))
						player.awe_headmodel = player.head_damage2;
					else if(isdefined(player.head_damage1))
						player.awe_headmodel = player.head_damage1;
					else if(isdefined(player.headmodel))
						player.awe_headmodel = player.headmodel;
				}

				if(level.awe_pophead && isdefined(player.awe_headmodel))
				{
					model = spawn("script_model", player.origin + offset );
					model.angles = ( 0, player.angles[1], 0 );
					rotation = ( randomFloat(540), randomFloat(540), randomFloat(540));
					model setmodel( player.awe_headmodel);
					offset = (0,-2.5,-18);
					radius = 6;
					model thread bounceObject( rotation, (0,0,0), offset, (-90,0,0), radius, 15, 0.7, "bodyfall_flesh_large", level.awe_popheadfx );
				}
				else if(isdefined(player.hatmodel))
				{
					model = spawn("script_model", player.origin + offset );
					model.angles = ( 0, player.angles[1], 0 );
					rotation = ( randomFloat(540), randomFloat(540), randomFloat(540));
					model setmodel( player.hatmodel);
					offset = (0,0,-6);
					radius = 6;
					model thread bounceObject( rotation, (0,0,0), offset, (-90,0,0), radius, 15, 0.7, "grenade_bounce_default", undefined );
				}
				else
				{
					wait .05;
					continue;
				}
			}
			wait .2;
		}
		wait .05;
	}
	level.awe_raining = undefined;
}

getHitLocTag(hitloc)
{
	switch(hitloc)
		{
		case "right_hand":
			return "Bip01 R Hand";
			break;

		case "left_hand":
			return "Bip01 L Hand";
			break;
	
		case "right_arm_upper":	
			return "Bip01 R UpperArm";
			break;

		case "right_arm_lower":	
			return "Bip01 R Forearm";
			break;

		case "left_arm_upper":
			return "Bip01 L UpperArm";
			break;

		case "left_arm_lower":
			return "Bip01 L Forearm";
			break;

		case "head":
			return "Bip01 Head";
			break;

		case "neck":
			return "Bip01 Neck";
			break;
	
		
		case "right_foot":
			return "Bip01 R Foot";
			break;

		case "left_foot":
			return "Bip01 L Foot";
			break;

		case "right_leg_lower":
			return "TAG_SHIN_RIGHT";
			break;

		case "left_leg_lower":
			return "TAG_SHIN_left";
			break;

		case "right_leg_upper":
			return "Bip01 R Thigh";
			break;
					
		case "left_leg_upper":
			return "Bip01 L Thigh";
			break;
		case "torso_upper":
			return "TAG_BREASTPOCKET_LEFT";
			break;	
		
		case "torso_lower":
			return "TAG_BELT_FRONT";
			break;

		default:
			return "Bip01 Pelvis";
			break;	
	}
}
