main()
{

	spawnpoints = getSpawnPoints("allies");
	if(!spawnpoints.size)
	{
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}
	for(i = 0; i < spawnpoints.size; i++)
		spawnpoints[i] placeSpawnpoint();

	spawnpoints = getSpawnPoints("axis");
	if(!spawnpoints.size)
	{
		maps\mp\gametypes\_callbacksetup::AbortLevel();
		return;
	}
	for(i = 0; i < spawnpoints.size; i++)
		spawnpoints[i] placeSpawnpoint();

	spawnpointname = "mp_teamdeathmatch_spawn";
	spawnpoints = getentarray(spawnpointname, "classname");
	for(i = 0; i < spawnpoints.size; i++)
		spawnpoints[i] placeSpawnpoint();

	level.callbackStartGameType = ::Callback_StartGameType;
	level.callbackPlayerConnect = ::Callback_PlayerConnect;
	level.callbackPlayerDisconnect = ::Callback_PlayerDisconnect;
	level.callbackPlayerDamage = ::Callback_PlayerDamage;
	level.callbackPlayerKilled = ::Callback_PlayerKilled;

	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	
	allowed[0] = "tdm";
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	// Time limit per map
	level.timelimit = cvardef("scr_ctf_timelimit", 30, 0, 1440, "float");
//	setCvar("ui_ctf_timelimit", level.timelimit);
//	makeCvarServerInfo("ui_ctf_timelimit", "30");

/*
	//////////////////////////////////////////////////////////////////////	
	// Initialize Merciless	
	//////////////////////////////////////////////////////////////////////
		maps\mp\gametypes\_mcUtility::Initialize();
	/////////////////////////////////////////////////////////////////////
*/
	// Score limit per map
	level.scorelimit = cvardef("scr_ctf_scorelimit", 5, 1, 999, "int");
//	setCvar("ui_ctf_scorelimit", level.scorelimit);
//	makeCvarServerInfo("ui_ctf_scorelimit", "5");

	// Score on dropped
	level.scoreondropped = cvardef("scr_ctf_scoreondropped", 1, 0, 1, "int");
//	setCvar("ui_ctf_scoreondropped", level.scoreondropped);
//	makeCvarServerInfo("ui_ctf_scoreondropped", "0");

	if(getCvar("scr_forcerespawn") == "")		// Force respawning
		setCvar("scr_forcerespawn", "0");
	
	if(getCvar("scr_teambalance") == "")		// Auto Team Balancing
		setCvar("scr_teambalance", "0");
	level.teambalance = getCvarInt("scr_teambalance");
	level.teambalancetimer = 0;
	
	killcam = getCvar("scr_killcam");
	if(killcam == "")				// Kill cam
		killcam = "1";
	setCvar("scr_killcam", killcam, true);
	level.killcam = getCvarInt("scr_killcam");
	
	if(getCvar("scr_drawfriend") == "")		// Draws a team icon over teammates
		setCvar("scr_drawfriend", "0");
	level.drawfriend = getCvarInt("scr_drawfriend");

	if(!isDefined(game["state"]))
		game["state"] = "playing";

	level.mapended = false;
	level.healthqueue = [];
	level.healthqueuecurrent = 0;
	
	level.team["allies"] = 0;
	level.team["axis"] = 0;
	
	if(level.killcam >= 1)
		setarchive(true);
}

Callback_StartGameType()
{

////////////// Added by AWE ///////////
	maps\mp\gametypes\_awe::Callback_StartGameType();
///////////////////////////////////////

	// defaults if not defined in level script
	if(!isDefined(game["allies"]))
		game["allies"] = "american";
	if(!isDefined(game["axis"]))
		game["axis"] = "german";

/*
	////////////////////////////////////////////////////////////////////////////////////
	//Setup Merciless
	//
	///////////////////////////////////////////////////////////////////////////////////	
	maps\mp\gametypes\_mcUtility::setup();
	maps\mp\gametypes\_mcUtility::LoadMenu();
	///////////////////////////////////////////////////////////////////////////////////
*/

	if(!isDefined(game["layoutimage"]))
		game["layoutimage"] = "default";
	layoutname = "levelshots/layouts/hud@layout_" + game["layoutimage"];
	precacheShader(layoutname);
	setCvar("scr_layoutimage", layoutname);
	makeCvarServerInfo("scr_layoutimage", "");

	// server cvar overrides
	if(getCvar("scr_allies") != "")
		game["allies"] = getCvar("scr_allies");	
	if(getCvar("scr_axis") != "")
		game["axis"] = getCvar("scr_axis");
	
//	game["menu_serverinfo"] = "serverinfo_" + getCvar("g_gametype");
	game["menu_team"] = "team_" + game["allies"] + game["axis"];
	game["menu_weapon_allies"] = "weapon_" + game["allies"];
	game["menu_weapon_axis"] = "weapon_" + game["axis"];
	game["menu_viewmap"] = "viewmap";
	game["menu_callvote"] = "callvote";
	game["menu_quickcommands"] = "quickcommands";
	game["menu_quickstatements"] = "quickstatements";
	game["menu_quickresponses"] = "quickresponses";

	precacheString(&"MPSCRIPT_PRESS_ACTIVATE_TO_RESPAWN");
	precacheString(&"MPSCRIPT_KILLCAM");

//	precacheMenu(game["menu_serverinfo"]);	
	precacheMenu(game["menu_team"]);
	precacheMenu(game["menu_weapon_allies"]);
	precacheMenu(game["menu_weapon_axis"]);
	precacheMenu(game["menu_viewmap"]);
	precacheMenu(game["menu_callvote"]);
	precacheMenu(game["menu_quickcommands"]);
	precacheMenu(game["menu_quickstatements"]);
	precacheMenu(game["menu_quickresponses"]);

	precacheShader("black");
	precacheShader("hudScoreboard_mp");
	precacheShader("gfx/hud/hud@mpflag_spectator.tga");
	precacheStatusIcon("gfx/hud/hud@status_dead.tga");
	precacheStatusIcon("gfx/hud/hud@status_connecting.tga");
	precacheItem("item_health");


	precacheShader("gfx/hud/hud@objectivegoal.dds");
	precacheShader("gfx/hud/hud@objectivegoal_up.dds");
	precacheShader("gfx/hud/hud@objectivegoal_down.dds");

	game["headicon_carrier"] = "gfx/hud/headicon@re_objcarrier.tga";
	precacheHeadIcon(game["headicon_carrier"]);
	precacheStatusIcon(game["headicon_carrier"]);
	precacheShader(game["headicon_carrier"]);


	maps\mp\gametypes\_teams::modeltype();
	maps\mp\gametypes\_teams::precache();
	maps\mp\gametypes\_tgg::TGGSetup();
	maps\mp\gametypes\_teams::scoreboard();
	maps\mp\gametypes\_teams::initGlobalCvars();
	maps\mp\gametypes\_teams::initWeaponCvars();
	maps\mp\gametypes\_teams::restrictPlacedWeapons();
	thread maps\mp\gametypes\_teams::updateGlobalCvars();
	thread maps\mp\gametypes\_teams::updateWeaponCvars();

	setClientNameMode("auto_change");
	
	thread startGame();
	// Start Ravirs admin tools
	thread maps\mp\gametypes\_user_Ravir_admin::main();
	thread updateGametypeCvars();
	
		minefields = getentarray( "misc_mg42", "classname" );
	if(minefields.size)
		for(i=0;i< minefields.size;i++)
			if(isdefined(minefields[i]))
				minefields[i] delete();
}

Callback_PlayerConnect()
{
	self.statusicon = "gfx/hud/hud@status_connecting.tga";
	self waittill("begin");
	self.statusicon = "";
	self.pers["teamTime"] = 1000000;
	
	iprintln(&"MPSCRIPT_CONNECTED", self);

	lpselfnum = self getEntityNumber();
	lpGuid = self getGuid();
	logPrint("J;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");

	if(game["state"] == "intermission")
	{
		spawnIntermission();
		return;
	}
	
	level endon("intermission");

	if(isDefined(self.pers["team"]) && self.pers["team"] != "spectator")
	{
		self setClientCvar("ui_weapontab", "1");

		if(self.pers["team"] == "allies")
		{
			self.sessionteam = "allies";
			self setClientCvar("g_scriptMainMenu", game["menu_weapon_allies"]);
		}
		else
		{
			self.sessionteam = "axis";
			self setClientCvar("g_scriptMainMenu", game["menu_weapon_axis"]);
		}
			
		if(isDefined(self.pers["weapon"]))
			spawnPlayer();
		else
		{
			spawnSpectator();

			if(self.pers["team"] == "allies")
				self openMenu(game["menu_weapon_allies"]);
			else
				self openMenu(game["menu_weapon_axis"]);
		}
	}
	else
	{
		self setClientCvar("g_scriptMainMenu", game["menu_team"]);
		self setClientCvar("ui_weapontab", "0");
		
//		if(!isDefined(self.pers["skipserverinfo"]))
//			self openMenu(game["menu_serverinfo"]);

		if(!isdefined(self.pers["team"]))
			self openMenu(game["menu_team"]);

		self.pers["team"] = "spectator";
		self.sessionteam = "spectator";

		spawnSpectator();
	}
	
	self.tgglevel = 1;	
	self.score = 1;

	for(;;)
	{
		self waittill("menuresponse", menu, response);
		
/*		if(menu == game["menu_serverinfo"] && response == "close")
		{
			self.pers["skipserverinfo"] = true;
			self openMenu(game["menu_team"]);
		}
*/
		if(response == "open" || response == "close")
			continue;

		if(menu == game["menu_team"])
		{
			switch(response)
			{
			case "allies":
			case "axis":
			case "autoassign":
				if(response == "autoassign")
				{
					numonteam["allies"] = 0;
					numonteam["axis"] = 0;

					players = getentarray("player", "classname");
					for(i = 0; i < players.size; i++)
					{
						player = players[i];
					
						if(!isDefined(player.pers["team"]) || player.pers["team"] == "spectator" || player == self)
							continue;
			
						numonteam[player.pers["team"]]++;
					}
					
					// if teams are equal return the team with the lowest score
					if(numonteam["allies"] == numonteam["axis"])
					{
						if(getTeamScore("allies") == getTeamScore("axis"))
						{
							teams[0] = "allies";
							teams[1] = "axis";
							response = teams[randomInt(2)];
						}
						else if(getTeamScore("allies") < getTeamScore("axis"))
							response = "allies";
						else
							response = "axis";
					}
					else if(numonteam["allies"] < numonteam["axis"])
						response = "allies";
					else
						response = "axis";
					skipbalancecheck = true;
				}
				
				if(response == self.pers["team"] && (self.sessionstate == "playing" || self.sessionstate == "dead"))
				{
					if(self.pers["team"] == "allies")
					{
						self setClientCvar("g_scriptMainMenu", game["menu_weapon_allies"]);
						self openMenu(game["menu_weapon_allies"]);
					}
					else
					{
						self setClientCvar("g_scriptMainMenu", game["menu_weapon_axis"]);
						self openMenu(game["menu_weapon_axis"]);
					}				
					break;
				}
				
				//Check if the teams will become unbalanced when the player goes to this team...
				//------------------------------------------------------------------------------
				if ( (level.teambalance > 0) && (!isdefined (skipbalancecheck)) )
				{
					//Get a count of all players on Axis and Allies
					players = maps\mp\gametypes\_teams::CountPlayers();
					
					if (self.sessionteam != "spectator")
					{
						if (((players[response] + 1) - (players[self.pers["team"]] - 1)) > level.teambalance)
						{
							if (response == "allies")
							{
								if (game["allies"] == "american")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED",&"PATCH_1_3_AMERICAN");
								else if (game["allies"] == "british")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED",&"PATCH_1_3_BRITISH");
								else if (game["allies"] == "russian")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED",&"PATCH_1_3_RUSSIAN");
							}
							else
								self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED",&"PATCH_1_3_GERMAN");
							break;
						}
					}
					else
					{
						if (response == "allies")
							otherteam = "axis";
						else
							otherteam = "allies";
						if (((players[response] + 1) - players[otherteam]) > level.teambalance)
						{
							if (response == "allies")
							{
								if (game["allies"] == "american")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED2",&"PATCH_1_3_AMERICAN");
								else if (game["allies"] == "british")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED2",&"PATCH_1_3_BRITISH");
								else if (game["allies"] == "russian")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_ALLIED2",&"PATCH_1_3_RUSSIAN");
							}
							else
							{
								if (game["allies"] == "american")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_AXIS",&"PATCH_1_3_AMERICAN");
								else if (game["allies"] == "british")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_AXIS",&"PATCH_1_3_BRITISH");
								else if (game["allies"] == "russian")
									self iprintlnbold(&"PATCH_1_3_CANTJOINTEAM_AXIS",&"PATCH_1_3_RUSSIAN");
							}
							break;
						}
					}
				}
				skipbalancecheck = undefined;
				//------------------------------------------------------------------------------
				
				if(response != self.pers["team"] && self.sessionstate == "playing")
					self suicide();

				self notify("end_respawn");

				self.pers["team"] = response;
				self.pers["teamTime"] = (gettime() / 1000);
				self.pers["weapon"] = undefined;
				self.pers["savedmodel"] = undefined;

				self setClientCvar("ui_weapontab", "1");

				if(self.pers["team"] == "allies")
				{
					self setClientCvar("g_scriptMainMenu", game["menu_weapon_allies"]);
					self openMenu(game["menu_weapon_allies"]);
				}
				else
				{
					self setClientCvar("g_scriptMainMenu", game["menu_weapon_axis"]);
					self openMenu(game["menu_weapon_axis"]);
				}
				break;

			case "spectator":
				if(self.pers["team"] != "spectator")
				{
					self.pers["team"] = "spectator";
					self.pers["teamTime"] = 1000000;
					self.pers["weapon"] = undefined;
					self.pers["savedmodel"] = undefined;
					
					self.sessionteam = "spectator";
					self setClientCvar("g_scriptMainMenu", game["menu_team"]);
					self setClientCvar("ui_weapontab", "0");
					spawnSpectator();
				}
				break;

			case "weapon":
				if(self.pers["team"] == "allies")
					self openMenu(game["menu_weapon_allies"]);
				else if(self.pers["team"] == "axis")
					self openMenu(game["menu_weapon_axis"]);
				break;
				
			case "viewmap":
				self openMenu(game["menu_viewmap"]);
				break;

			case "callvote":
				self openMenu(game["menu_callvote"]);
				break;
			}
		}		
		else if(menu == game["menu_weapon_allies"] || menu == game["menu_weapon_axis"])
		{
			if(response == "team")
			{
				self openMenu(game["menu_team"]);
				continue;
			}
			else if(response == "viewmap")
			{
				self openMenu(game["menu_viewmap"]);
				continue;
			}
			else if(response == "callvote")
			{
				self openMenu(game["menu_callvote"]);
				continue;
			}
			
			if(!isDefined(self.pers["team"]) || (self.pers["team"] != "allies" && self.pers["team"] != "axis"))
				continue;

			weapon = self maps\mp\gametypes\_teams::restrict(response);

			if(weapon == "restricted")
			{
				self openMenu(menu);
				continue;
			}
			
			if(isDefined(self.pers["weapon"]) && self.pers["weapon"] == weapon)
				continue;
			
			if(!isDefined(self.pers["weapon"]))
			{
				self.pers["weapon"] = weapon;
				spawnPlayer();
				self thread printJoinedTeam(self.pers["team"]);
			}
			else
			{
				self.pers["weapon"] = weapon;

				weaponname = maps\mp\gametypes\_teams::getWeaponName(self.pers["weapon"]);
				
				if(maps\mp\gametypes\_teams::useAn(self.pers["weapon"]))
					self iprintln(&"MPSCRIPT_YOU_WILL_RESPAWN_WITH_AN", weaponname);
				else
					self iprintln(&"MPSCRIPT_YOU_WILL_RESPAWN_WITH_A", weaponname);
			}
			if (isdefined (self.autobalance_notify))
				self.autobalance_notify destroy();
		}
		else if(menu == game["menu_viewmap"])
		{
			switch(response)
			{
			case "team":
				self openMenu(game["menu_team"]);
				break;
				
			case "weapon":
				if(self.pers["team"] == "allies")
					self openMenu(game["menu_weapon_allies"]);
				else if(self.pers["team"] == "axis")
					self openMenu(game["menu_weapon_axis"]);
				break;

			case "callvote":
				self openMenu(game["menu_callvote"]);
				break;
			}
		}
		else if(menu == game["menu_callvote"])
		{
			switch(response)
			{
			case "team":
				self openMenu(game["menu_team"]);
				break;
				
			case "weapon":
				if(self.pers["team"] == "allies")
					self openMenu(game["menu_weapon_allies"]);
				else if(self.pers["team"] == "axis")
					self openMenu(game["menu_weapon_axis"]);
				break;

			case "viewmap":
				self openMenu(game["menu_viewmap"]);
				break;
			}
		}
		else if(menu == game["menu_quickcommands"])
			maps\mp\gametypes\_teams::quickcommands(response);
		else if(menu == game["menu_quickstatements"])
			maps\mp\gametypes\_teams::quickstatements(response);
		else if(menu == game["menu_quickresponses"])
			maps\mp\gametypes\_teams::quickresponses(response);
/* MC
		else if(menu == game["menu_quickplayeroptions"])
			maps\mp\gametypes\_teams::quickplayeroptions(response);
*/
	}
}

Callback_PlayerDisconnect()
{

///// Added by AWE ////////
	self maps\mp\gametypes\_awe::PlayerDisconnect();
///////////////////////////
	iprintln(&"MPSCRIPT_DISCONNECTED", self);
	
	lpselfnum = self getEntityNumber();
	lpGuid = self getGuid();
	logPrint("Q;" + lpGuid + ";" + lpselfnum + ";" + self.name + "\n");
}

Callback_PlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc)
{
	if(self.sessionteam == "spectator")
		return;

///// Added by AWE ////////
	if(isdefined(self.awe_invulnerable))
		return;
///////////////////////////

	// Don't do knockback if the damage direction was not specified
	if(!isDefined(vDir))
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	// check for completely getting out of the damage
	if(!(iDFlags & level.iDFLAGS_NO_PROTECTION))
	{
		if(isPlayer(eAttacker) && (self != eAttacker) && (self.pers["team"] == eAttacker.pers["team"]))
		{
			if(level.friendlyfire == "0")
			{
				return;
			}
			else if(level.friendlyfire == "1" && !isdefined(eAttacker.pers["awe_teamkiller"]))
			{
				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;
	
/*
				////////////////////////////////////////////////////////////////////
				// player death sound.
				//
				/////////////////////////////////////////////////////////////////////
				if ((self.health - iDamage) <= 0 )
					maps\mp\gametypes\_mcUtility::_doSounds("death",sMeansofDeath);
				/////////////////////////////////////////////////////////////////////
*/

				eAttacker maps\mp\gametypes\_awe::teamdamage(self, iDamage);
				self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);

/*
				////////////////////////////////////////////////////////////////////
				//
				//Do Player Damage (Set model, pop helmet,bleeding pain..)
				//
				/////////////////////////////////////////////////////////////////////
				maps\mp\gametypes\_mcUtility::DoPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
				/////////////////////////////////////////////////////////////////////
*/

////////////// Added by AWE //////////////////
				self maps\mp\gametypes\_awe::DoPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
//////////////////////////////////////////////

			}
			else if(level.friendlyfire == "2" || isdefined(eAttacker.pers["awe_teamkiller"]))
			{
				eAttacker.friendlydamage = true;
		
				iDamage = iDamage * .5;
		
				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;
/*
				////////////////////////////////////////////////////////////////////
				//
				// Friendly Fire - Don't shoot!
				//
				/////////////////////////////////////////////////////////////////////
				self maps\mp\gametypes\_mcUtility::DontShoot();
				/////////////////////////////////////////////////////////////////////
*/
				eAttacker finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
				eAttacker.friendlydamage = undefined;
				
				friendly = true;
			}
			else if(level.friendlyfire == "3")
			{
				eAttacker.friendlydamage = true;
		
				iDamage = iDamage * .5;
		
				// Make sure at least one point of damage is done
				if(iDamage < 1)
					iDamage = 1;
/*
				////////////////////////////////////////////////////////////////////
				//
				// Friendly Fire - Don't shoot!
				//
				/////////////////////////////////////////////////////////////////////
				self maps\mp\gametypes\_mcUtility::DontShoot();
				/////////////////////////////////////////////////////////////////////
*/
				self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
				eAttacker finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
				eAttacker.friendlydamage = undefined;
				
				friendly = true;
			}
		}
		else
		{
			// Make sure at least one point of damage is done
			if(iDamage < 1)
				iDamage = 1;
/*
			////////////////////////////////////////////////////////////////////
			// player death sound.
			//
			/////////////////////////////////////////////////////////////////////
			if ((self.health - iDamage) <= 0 )
				maps\mp\gametypes\_mcUtility::_doSounds("death",sMeansofDeath);
			/////////////////////////////////////////////////////////////////////
*/
			self finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
/*
			////////////////////////////////////////////////////////////////////
			//
			//Do Player Damage (Set model, pop helmet,bleeding pain..)
			//
			/////////////////////////////////////////////////////////////////////
			maps\mp\gametypes\_mcUtility::DoPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
			/////////////////////////////////////////////////////////////////////
*/
////////////// Added by AWE //////////////////
			self maps\mp\gametypes\_awe::DoPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc);
//////////////////////////////////////////////

		}
	}

	// Do debug print if it's enabled
	if(getCvarInt("g_debugDamage"))
	{
		println("client:" + self getEntityNumber() + " health:" + self.health +
			" damage:" + iDamage + " hitLoc:" + sHitLoc);
	}

	if(self.sessionstate != "dead")
	{
		lpselfnum = self getEntityNumber();
		lpselfname = self.name;
		lpselfteam = self.pers["team"];
		lpselfGuid = self getGuid();
		lpattackerteam = "";

		if(isPlayer(eAttacker))
		{
			lpattacknum = eAttacker getEntityNumber();
			lpattackGuid = eAttacker getGuid();
			lpattackname = eAttacker.name;
			lpattackerteam = eAttacker.pers["team"];
		}
		else
		{
			lpattacknum = -1;
			lpattackGuid = "";
			lpattackname = "";
			lpattackerteam = "world";
		}

		if(isDefined(friendly)) 
		{  
			lpattacknum = lpselfnum;
			lpattackname = lpselfname;
			lpattackGuid = lpselfGuid;
		}
		
		logPrint("D;" + lpselfGuid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackGuid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n");
	}
}

Callback_PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc)
{
/*
	//////////////////////////////////////////////////////////////////////////////////
	// Notify Death thread
	//////////////////////////////////////////////////////////////////////////////////
	self notify ("TimeToDie",attacker);
	wait(0);
	//////////////////////////////////////////////////////////////////////////////////
*/
	self endon("spawned");
	

	if(self.sessionteam == "spectator")
		return;

/////////// Added by AWE ///////////
	self thread maps\mp\gametypes\_awe::PlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc);
////////////////////////////////////

	// If the player was killed by a head shot, let players know it was a head shot kill
	if(sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE")
		sMeansOfDeath = "MOD_HEAD_SHOT";
		
	// send out an obituary message to all clients about the kill
	obituary(self, attacker, sWeapon, sMeansOfDeath);
	
	self.sessionstate = "dead";
	self.statusicon = "gfx/hud/hud@status_dead.tga";
	self.headicon = "";
	if (!isdefined (self.autobalance))
		self.deaths++;

	lpselfnum = self getEntityNumber();
	lpselfname = self.name;
	lpselfguid = self getGuid();
	lpselfteam = self.pers["team"];
	lpattackerteam = "";

	attackerNum = -1;
	if(isPlayer(attacker))
	{
		if(attacker == self) // killed himself
		{
			doKillcam = false;
			if(attacker.tgglevel > 1)
			{
				attacker.tgglevel -=1;
				attacker.score -= 1;
			}
			
			if(isDefined(attacker.friendlydamage))
				clientAnnouncement(attacker, &"MPSCRIPT_FRIENDLY_FIRE_WILL_NOT"); 
		}
		else
		{
			attackerNum = attacker getEntityNumber();
			doKillcam = true;

			if(self.pers["team"] != attacker.pers["team"]) 
			{
				attacker.score++;
				attacker.tgglevel++;
				if(attacker.tgglevel>=22)
				{
					teamscore = getTeamScore(attacker.pers["team"]);
					teamscore++;
					setTeamScore(attacker.pers["team"], teamscore);
					attacker.score=1;
					attacker.tgglevel=1;
					iprintln(attacker.name + "^7 just earned his team 1 point!");
					checkScoreLimit();
				}
				attacker maps\mp\gametypes\_tgg::tggGiveGun();
			}
			else
			{
				if(attacker.tgglevel > 1)
				{
					attacker.score--;
					attacker.tgglevel--;
					attacker iprintlnbold("^7 You just lost one point for teamkilling!");
					attacker maps\mp\gametypes\_tgg::tggGiveGun();
				}
				else
				{
					attacker takeAllWeapons();
				attacker iprintlnbold("^7 Bad Monkey!");
				}
			}
		}

		lpattacknum = attacker getEntityNumber();
		lpattackguid = attacker getGuid();
		lpattackname = attacker.name;
		lpattackerteam = attacker.pers["team"];
	}
	else // If you weren't killed by a player, you were in the wrong place at the wrong time
	{
		doKillcam = false;
		
		self.score--;

		lpattacknum = -1;
		lpattackname = "";
		lpattackguid = "";
		lpattackerteam = "world";
	}

	logPrint("K;" + lpselfguid + ";" + lpselfnum + ";" + lpselfteam + ";" + lpselfname + ";" + lpattackguid + ";" + lpattacknum + ";" + lpattackerteam + ";" + lpattackname + ";" + sWeapon + ";" + iDamage + ";" + sMeansOfDeath + ";" + sHitLoc + "\n");

	// Stop thread if map ended on this death
	if(level.mapended)
		return;

////////////// REMOVE FOR MC ///////////
	// Make the player drop his weapon
	
	// Make the player drop health
	self.autobalance = undefined;

	body = self cloneplayer();
	delay = 2;	// Delay the player becoming a spectator till after he's done dying
	wait delay;	// ?? Also required for Callback_PlayerKilled to complete before respawn/killcam can execute
////////////////////////////////////////

	if((getCvarInt("scr_killcam") <= 0) || (getCvarInt("scr_forcerespawn") > 0))
		doKillcam = false;
	
	if(doKillcam)
		self thread killcam(attackerNum, delay);
	else
		self thread respawn();
}

spawnPlayer()
{
	self notify("spawned");
	self notify("end_respawn");
	
	resettimeout();

	self.sessionteam = self.pers["team"];
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.friendlydamage = undefined;
	
	spawnpointname = "mp_teamdeathmatch_spawn";
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam(spawnpoints);
	if(!isDefined(spawnpoint))
	{
		// Bloody <beep>, there is no <beep>-ing teamdeathmatchspawn...
		spawnpointname = "RE or SD";
		spawnpoints = getSpawnPoints(self.pers["team"]);
		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);
	}

	if(isDefined(spawnpoint))
		self spawn(spawnpoint.origin, spawnpoint.angles);
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");

	self.statusicon = "";
	self.maxhealth = 100;
	self.health = self.maxhealth;

	
///////////// REMOVE FOR MC //////////
	if(!isDefined(self.pers["savedmodel"]))
//////////////////////////////////////
		maps\mp\gametypes\_teams::model();
///////////// REMOVE FOR MC //////////
	else
		maps\mp\_utility::loadModel(self.pers["savedmodel"]);
//////////////////////////////////////

	maps\mp\gametypes\_teams::givePistol();
	maps\mp\gametypes\_teams::giveGrenades(self.pers["weapon"]);
	
	self giveWeapon(self.pers["weapon"]);
	self giveMaxAmmo(self.pers["weapon"]);
	self setSpawnWeapon(self.pers["weapon"]);
	
	self maps\mp\gametypes\_tgg::TGGGiveGun();
/*
	//////////////////////////////////////////////////////////////////////////////////
	// start deaththread sounds if enabled
	//////////////////////////////////////////////////////////////////////////////////
	self thread maps\mp\gametypes\_mcUtility::WaitForDeath();
	//////////////////////////////////////////////////////////////////////////////////
*/
	alliesObj = "Kill axis. With each kill, you gain a level. Get to level 22 to earn your team a point. First team to 5 points wins.";
	axisObj = "Kill allies. With each kill, you gain a level. Get to level 22 to earn your team a point. First team to 5 points wins.";

	if(self.pers["team"] == "allies")
		self setClientCvar("cg_objectiveText", alliesObj);
	else if(self.pers["team"] == "axis")
		self setClientCvar("cg_objectiveText", axisObj);

	if(level.drawfriend)
	{
		if(self.pers["team"] == "allies")
		{
			self.headicon = game["headicon_allies"];
			self.headiconteam = "allies";
		}
		else
		{
			self.headicon = game["headicon_axis"];
			self.headiconteam = "axis";
		}
	}


//////////// Added  by AWE ////////
	self maps\mp\gametypes\_awe::spawnPlayer();
///////////////////////////////////

}

spawnSpectator(origin, angles)
{
	self notify("spawned");
	self notify("end_respawn");

	resettimeout();

	self.sessionstate = "spectator";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.friendlydamage = undefined;

	if(self.pers["team"] == "spectator")
		self.statusicon = "";
	
	if(isDefined(origin) && isDefined(angles))
		self spawn(origin, angles);
	else
	{
         	spawnpointname = "mp_teamdeathmatch_intermission";
		spawnpoints = getentarray(spawnpointname, "classname");

		if(!spawnpoints.size)
		{
	         	spawnpointname = "mp_searchanddestroy_intermission";
			spawnpoints = getentarray(spawnpointname, "classname");
		}

		spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);
	
		if(isDefined(spawnpoint))
			self spawn(spawnpoint.origin, spawnpoint.angles);
		else
			maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
	}
	
	Obj = "Kill the opposing team. With each kill, you gain a level. Earn a point for your team when you reach level 22. First team to 5 points wins!";
	self setClientCvar("cg_objectiveText", Obj);
}

spawnIntermission()
{
	self notify("spawned");
	self notify("end_respawn");

	resettimeout();

	self.sessionstate = "intermission";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.friendlydamage = undefined;

     	spawnpointname = "mp_teamdeathmatch_intermission";
	spawnpoints = getentarray(spawnpointname, "classname");

	if(!spawnpoints.size)
	{
         	spawnpointname = "mp_searchanddestroy_intermission";
		spawnpoints = getentarray(spawnpointname, "classname");
	}

	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);
	
	if(isDefined(spawnpoint))
		self spawn(spawnpoint.origin, spawnpoint.angles);
	else
		maps\mp\_utility::error("NO " + spawnpointname + " SPAWNPOINTS IN MAP");
}

respawn()
{
	if(!isDefined(self.pers["weapon"]))
		return;
	
	self endon("end_respawn");
	
	if(getCvarInt("scr_forcerespawn") > 0)
	{
		self thread waitForceRespawnTime();
		self thread waitRespawnButton();
		self waittill("respawn");
	}
	else
	{
		self thread waitRespawnButton();
		self waittill("respawn");
	}
	
	self thread spawnPlayer();
}

waitForceRespawnTime()
{
	self endon("end_respawn");
	self endon("respawn");
	
	wait getCvarInt("scr_forcerespawn");
	self notify("respawn");
}

waitRespawnButton()
{
	self endon("end_respawn");
	self endon("respawn");
	
	wait 0; // Required or the "respawn" notify could happen before it's waittill has begun

	self.respawntext = newClientHudElem(self);
	self.respawntext.alignX = "center";
	self.respawntext.alignY = "middle";
	self.respawntext.x = 320;
	self.respawntext.y = 70;
	self.respawntext.archived = false;
	self.respawntext setText(&"MPSCRIPT_PRESS_ACTIVATE_TO_RESPAWN");

	thread removeRespawnText();
	thread waitRemoveRespawnText("end_respawn");
	thread waitRemoveRespawnText("respawn");

	while(self useButtonPressed() != true)
		wait .05;
	
	self notify("remove_respawntext");

	self notify("respawn");	
}

removeRespawnText()
{
	self waittill("remove_respawntext");

	if(isDefined(self.respawntext))
		self.respawntext destroy();
}

waitRemoveRespawnText(message)
{
	self endon("remove_respawntext");

	self waittill(message);
	self notify("remove_respawntext");
}

killcam(attackerNum, delay)
{
	self endon("spawned");

//	previousorigin = self.origin;
//	previousangles = self.angles;
	
	// killcam
	if(attackerNum < 0)
		return;

	self.sessionstate = "spectator";
	self.spectatorclient = attackerNum;
	self.archivetime = delay + 7;

	// wait till the next server frame to allow code a chance to update archivetime if it needs trimming
	wait 0.05;

	if(self.archivetime <= delay)
	{
		self.spectatorclient = -1;
		self.archivetime = 0;
		self.sessionstate = "dead";
	
		self thread respawn();
		return;
	}

	if(!isDefined(self.kc_topbar))
	{
		self.kc_topbar = newClientHudElem(self);
		self.kc_topbar.archived = false;
		self.kc_topbar.x = 0;
		self.kc_topbar.y = 0;
		self.kc_topbar.alpha = 0.5;
		self.kc_topbar setShader("black", 640, 112);
	}

	if(!isDefined(self.kc_bottombar))
	{
		self.kc_bottombar = newClientHudElem(self);
		self.kc_bottombar.archived = false;
		self.kc_bottombar.x = 0;
		self.kc_bottombar.y = 368;
		self.kc_bottombar.alpha = 0.5;
		self.kc_bottombar setShader("black", 640, 112);
	}

	if(!isDefined(self.kc_title))
	{
		self.kc_title = newClientHudElem(self);
		self.kc_title.archived = false;
		self.kc_title.x = 320;
		self.kc_title.y = 40;
		self.kc_title.alignX = "center";
		self.kc_title.alignY = "middle";
		self.kc_title.sort = 1; // force to draw after the bars
		self.kc_title.fontScale = 3.5;
	}
	self.kc_title setText(&"MPSCRIPT_KILLCAM");

	if(!isDefined(self.kc_skiptext))
	{
		self.kc_skiptext = newClientHudElem(self);
		self.kc_skiptext.archived = false;
		self.kc_skiptext.x = 320;
		self.kc_skiptext.y = 70;
		self.kc_skiptext.alignX = "center";
		self.kc_skiptext.alignY = "middle";
		self.kc_skiptext.sort = 1; // force to draw after the bars
	}
	self.kc_skiptext setText(&"MPSCRIPT_PRESS_ACTIVATE_TO_RESPAWN");

	if(!isDefined(self.kc_timer))
	{
		self.kc_timer = newClientHudElem(self);
		self.kc_timer.archived = false;
		self.kc_timer.x = 320;
		self.kc_timer.y = 428;
		self.kc_timer.alignX = "center";
		self.kc_timer.alignY = "middle";
		self.kc_timer.fontScale = 3.5;
		self.kc_timer.sort = 1;
	}
	self.kc_timer setTenthsTimer(self.archivetime - delay);

	self thread spawnedKillcamCleanup();
	self thread waitSkipKillcamButton();
	self thread waitKillcamTime();
	self waittill("end_killcam");

	self removeKillcamElements();

	self.spectatorclient = -1;
	self.archivetime = 0;
	self.sessionstate = "dead";

	//self thread spawnSpectator(previousorigin + (0, 0, 60), previousangles);
	self thread respawn();
}

waitKillcamTime()
{
	self endon("end_killcam");
	
	wait(self.archivetime - 0.05);
	self notify("end_killcam");
}

waitSkipKillcamButton()
{
	self endon("end_killcam");
	
	while(self useButtonPressed())
		wait .05;

	while(!(self useButtonPressed()))
		wait .05;
	
	self notify("end_killcam");	
}

removeKillcamElements()
{
	if(isDefined(self.kc_topbar))
		self.kc_topbar destroy();
	if(isDefined(self.kc_bottombar))
		self.kc_bottombar destroy();
	if(isDefined(self.kc_title))
		self.kc_title destroy();
	if(isDefined(self.kc_skiptext))
		self.kc_skiptext destroy();
	if(isDefined(self.kc_timer))
		self.kc_timer destroy();
}

spawnedKillcamCleanup()
{
	self endon("end_killcam");

	self waittill("spawned");
	self removeKillcamElements();
}

startGame()
{
	level.starttime = getTime();
	
	if(level.timelimit > 0)
	{
		level.clock = newHudElem();
		level.clock.x = 320;
		level.clock.y = 460;
		level.clock.alignX = "center";
		level.clock.alignY = "middle";
		level.clock.font = "bigfixed";
		level.clock setTimer(level.timelimit * 60);
	}
	
	for(;;)
	{
		checkTimeLimit();
		wait 1;
	}
}

endMap()
{
	game["state"] = "intermission";
	level notify("intermission");
	
	alliedscore = getTeamScore("allies");
	axisscore = getTeamScore("axis");
	
	if(alliedscore == axisscore)
	{
		winningteam = "tie";
		losingteam = "tie";
		text = "MPSCRIPT_THE_GAME_IS_A_TIE";
	}
	else if(alliedscore > axisscore)
	{
		winningteam = "allies";
		losingteam = "axis";
		text = &"MPSCRIPT_ALLIES_WIN";
	}
	else
	{
		winningteam = "axis";
		losingteam = "allies";
		text = &"MPSCRIPT_AXIS_WIN";
	}
	
	if((winningteam == "allies") || (winningteam == "axis"))
	{
		winners = "";
		losers = "";
	}
	
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		player = players[i];
		if((winningteam == "allies") || (winningteam == "axis"))
		{
			lpGuid = player getGuid();
			if((isDefined(player.pers["team"])) && (player.pers["team"] == winningteam))
					winners = (winners + ";" + lpGuid + ";" + player.name);
			else if((isDefined(player.pers["team"])) && (player.pers["team"] == losingteam))
					losers = (losers + ";" + lpGuid + ";" + player.name);
		}
		player closeMenu();
		player setClientCvar("g_scriptMainMenu", "main");
		player setClientCvar("cg_objectiveText", text);
		player spawnIntermission();
	}
	
	if((winningteam == "allies") || (winningteam == "axis"))
	{
		logPrint("W;" + winningteam + winners + "\n");
		logPrint("L;" + losingteam + losers + "\n");
	}
	
	wait 10;
	exitLevel(false);
}

checkTimeLimit()
{
	if(level.timelimit <= 0)
		return;
	
	timepassed = (getTime() - level.starttime) / 1000;
	timepassed = timepassed / 60.0;
	
	if(timepassed < level.timelimit)
		return;
	
	if(level.mapended)
		return;
	level.mapended = true;

	iprintln(&"MPSCRIPT_TIME_LIMIT_REACHED");
	level thread endMap();
}

checkScoreLimit()
{
	if(level.scorelimit <= 0)
		return;
	
	if(getTeamScore("allies") < level.scorelimit && getTeamScore("axis") < level.scorelimit)
		return;

	if(level.mapended)
		return;
	level.mapended = true;

	iprintln(&"MPSCRIPT_SCORE_LIMIT_REACHED");
	level thread endMap();
}

updateGametypeCvars()
{
	for(;;)
	{
		timelimit = cvardef("scr_ctf_timelimit", 30, 0, 1440, "float");
		if(level.timelimit != timelimit)
		{
			level.timelimit = timelimit;
//			setCvar("ui_ctf_timelimit", level.timelimit);
			level.starttime = getTime();
			
			if(level.timelimit > 0)
			{
				if(!isDefined(level.clock))
				{
					level.clock = newHudElem();
					level.clock.x = 320;
					level.clock.y = 440;
					level.clock.alignX = "center";
					level.clock.alignY = "middle";
					level.clock.font = "bigfixed";
				}
				level.clock setTimer(level.timelimit * 60);
			}
			else
			{
				if(isDefined(level.clock))
					level.clock destroy();
			}
			
			checkTimeLimit();
		}

		// Score limit per map
		scorelimit = cvardef("scr_ctf_scorelimit", 5, 1, 999, "int");
		if(level.scorelimit != scorelimit)
		{
			level.scorelimit = scorelimit;
//			setCvar("ui_ctf_scorelimit", level.scorelimit);
		}
		checkScoreLimit();


		// Score on dropped
		scoreondropped = cvardef("scr_ctf_scoreondropped", 1, 0, 1, "int");
		if(level.scoreondropped != scoreondropped)
		{
			level.scoreondropped = scoreondropped;
//			setCvar("ui_ctf_scoreondropped", level.scoreondropped);
		}	

		drawfriend = getCvarFloat("scr_drawfriend");
		if(level.drawfriend != drawfriend)
		{
			level.drawfriend = drawfriend;
			
			if(level.drawfriend)
			{
				// for all living players, show the appropriate headicon
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					player = players[i];
					
					if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
					{
						if(player.pers["team"] == "allies")
						{
							player.headicon = game["headicon_allies"];
							player.headiconteam = "allies";
						}
						else
						{
							player.headicon = game["headicon_axis"];
							player.headiconteam = "axis";
						}
					}
				}
			}
			else
			{
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					player = players[i];
					
					if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
						player.headicon = "";
				}
			}
		}

		killcam = getCvarInt("scr_killcam");
		if (level.killcam != killcam)
		{
			level.killcam = getCvarInt("scr_killcam");
			if(level.killcam >= 1)
				setarchive(true);
			else
				setarchive(false);
		}
		
		teambalance = getCvarInt("scr_teambalance");
		if (level.teambalance != teambalance)
		{
			level.teambalance = getCvarInt("scr_teambalance");
			if (level.teambalance > 0)
			{
				level thread maps\mp\gametypes\_teams::TeamBalance_Check();
				level.teambalancetimer = 0;
			}
		}
		
		if (level.teambalance > 0)
		{
			level.teambalancetimer++;
			if (level.teambalancetimer >= 60)
			{
				level thread maps\mp\gametypes\_teams::TeamBalance_Check();
				level.teambalancetimer = 0;
			}
		}
		
		wait 1;
	}
}

printJoinedTeam(team)
{
	if(team == "allies")
		iprintln(&"MPSCRIPT_JOINED_ALLIES", self);
	else if(team == "axis")
		iprintln(&"MPSCRIPT_JOINED_AXIS", self);
}

dropHealth()
{
	if(isDefined(level.healthqueue[level.healthqueuecurrent]))
		level.healthqueue[level.healthqueuecurrent] delete();
	
	level.healthqueue[level.healthqueuecurrent] = spawn("item_health", self.origin + (0, 0, 1));
	level.healthqueue[level.healthqueuecurrent].angles = (0, randomint(360), 0);

	level.healthqueuecurrent++;
	
	if(level.healthqueuecurrent >= 16)
		level.healthqueuecurrent = 0;
}

getSpawnPoints(team)
{
	if(team == "allies")
		spawnpointname = "mp_teamdeathmatch_spawn_allied";
	else
		spawnpointname = "mp_teamdeathmatch_spawn_axis";

	spawnpoints = getentarray(spawnpointname, "classname");

	// Get SD spawn points if RE does not exist
	if(!spawnpoints.size)
	{
		if(team == "allies")
			spawnpointname = "mp_searchanddestroy_spawn_allied";
		else
			spawnpointname = "mp_searchanddestroy_spawn_axis";
		spawnpoints = getentarray(spawnpointname, "classname");
	}

	return spawnpoints;
}

findGround(position)
{
	trace=bulletTrace(position+(0,0,10),position+(0,0,-1200),false,undefined);
	ground=trace["position"];
	return ground;
}







announce(what)
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if(players[i] == self)
			players[i] iprintlnbold("You " + what);
		else if(isPlayer(players[i]))
			players[i] iprintln(self.name + " " + what);
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

playsound_onplayers(sound)
{
	players = getentarray("player", "classname");
	for(i = 0; i < players.size; i++)
	{
		if((isDefined(players[i].pers["team"])) && (players[i].pers["team"] != "spectator"))
			players[i] playLocalSound(sound);
	}
}

alivePlayers(team)
{
	allplayers = getentarray("player", "classname");
	alive = [];
	for(i = 0; i < allplayers.size; i++)
	{
		if(allplayers[i].sessionstate == "playing" && allplayers[i].sessionteam == team)
			alive[alive.size] = allplayers[i];
	}
	return alive.size;
}