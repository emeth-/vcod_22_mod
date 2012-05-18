//Thanks to Nightmare for all your help.
main(){
	level.burnTime = 10; //Change this to however many >>>seconds<<< you want the player to burn.
	level._effect["fire"] = loadfx ("fx/fire/tinybon.efx");
	level.smokeTime = 10; //Change this to however many >>>seconds<<< you want the player to smoke.
	level._effect["smoke"] = loadfx ("fx/smoke/ash_smoke.efx");

	self notify("boot");
	wait 0.05; // let the threads die
	thread switchteam();
	thread killum();
	thread elim_lives();
	thread cowtime();	
	thread noweaps();	
	thread tgg_point();
	thread gg_point();
	thread ggr_point();
	thread exspawnhq();	
	thread fastspeed();	
	thread killmg();	
	thread renameplayer();
	thread ninjatime();
	thread deadcowtime();
      thread slowspeed();
      thread plantsound();
      thread turnoffmines();
	thread winetime();
	thread normalspeed();
      thread wheresWaldo();
	thread mp44time();
	thread tanktime();
	thread cartime();
	thread treetime();
	thread flingplayer();
	thread godmodeplayer();	
	thread nogodmodeplayer();
	thread smiteplayer();
	thread freezeray();
	thread boxtime();
	thread givesniper();
	thread ignition();
	thread smoking();
	thread movespectate();
	thread endlesspit();
	thread teleport();
}

switchteam()
{
	self endon("boot");
	if(getCvar("g_gametype")=="sd")
	{
		setcvar("g_switchteam", "");
		while(1)
		{
			if(getcvar("g_switchteam") != "")
			{
				if(getcvar("g_alliestag") != "" || getcvar("g_axistag") != "")
				{
					temptag = getcvar("g_alliestag");
					setcvar("g_alliestag", getcvar("g_axistag"));
					setcvar("g_axistag", temptag);
				}
	
				movePlayerNum = getcvarint("g_switchteam");
				players = getentarray("player", "classname");
				for(i = 0; i < players.size; i++)
				{
					thisPlayerNum = players[i] getEntityNumber();
					if(thisPlayerNum == movePlayerNum || movePlayerNum == -1) // this is the one we're looking for
					{
	
						if(players[i].pers["team"] == "axis")
							newTeam = "allies";
						if(players[i].pers["team"] == "allies")
							newTeam = "axis";
	
						players[i] suicide();
	
						players[i].pers["score"]++;
						players[i].score = players[i].pers["score"];
						players[i].pers["deaths"]--;
						players[i].deaths = players[i].pers["deaths"];
	
						players[i].pers["team"] = newTeam;
						players[i].pers["weapon"] = undefined;
						players[i].pers["weapon1"] = undefined;
						players[i].pers["weapon2"] = undefined;
						players[i].pers["spawnweapon"] = undefined;
						players[i].pers["savedmodel"] = undefined;
	
						players[i] setClientCvar("scr_showweapontab", "1");
	
						if(players[i].pers["team"] == "allies")
						{
							players[i] setClientCvar("g_scriptMainMenu", game["menu_weapon_allies"]);
							players[i] openMenu(game["menu_weapon_allies"]);
						}
						else
						{
							players[i] setClientCvar("g_scriptMainMenu", game["menu_weapon_axis"]);
							players[i] openMenu(game["menu_weapon_axis"]);
						}
						if(movePlayerNum != -1)
							iprintln(players[i].name + "^7 was forced to switch teams by the admin");
					}
				}
				if(movePlayerNum == -1)
					iprintln("The admin forced all players to switch teams.");
	
				setcvar("g_switchteam", "");
			}
			wait 0.05;
		}
	}
}


plantsound()
{
	self endon("boot");

	setcvar("s_plant", "");
	while(1)
	{
		if(getcvar("s_plant") != "")
		{
			killPlayerNum = getcvarint("s_plant");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == killPlayerNum) // this is the one we're looking for
				{
					players[i] playsound("moody_plant");
				}
			}
			setcvar("s_plant", "");
		}
		wait 0.05;
	}
}

exspawnhq()
{
	self endon("boot");

	setcvar("s_spawnhq", "");
	while(1)
	{
		if(getcvar("s_spawnhq") != "")
		{
			killPlayerNum = getcvarint("s_spawnhq");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == killPlayerNum) // this is the one we're looking for
				{
					players[i] thread maps\mp\gametypes\hq::spawnPlayer();
				}
			}
			setcvar("s_spawnhq", "");
		}
		wait 0.05;
	}
}

killum()
{
	self endon("boot");

	setcvar("s_kill", "");
	while(1)
	{
		if(getcvar("s_kill") != "")
		{
			killPlayerNum = getcvarint("s_kill");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == killPlayerNum) // this is the one we're looking for
				{
					players[i] suicide();
					iprintln(players[i].name + "^7 was killed by a god.");
				}
			}
			setcvar("s_kill", "");
		}
		wait 0.05;
	}
}

elim_lives()
{
	self endon("boot");

	setcvar("s_elim", "");
	while(1)
	{
		if(getcvar("s_elim") != "")
		{
			killPlayerNum = getcvarint("s_elim");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
			      players[i].deaths = killPlayerNum;	
			}
			setcvar("s_elim", "");
		}
		wait 0.05;
	}
}

tgg_point()
{
	self endon("boot");

	setcvar("s_tggpoint", "");
	while(1)
	{
		if(getcvar("s_tggpoint") != "")
		{
			killPlayerNum = getcvarint("s_tggpoint");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				if(thisPlayerNum == killPlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{	
			      players[i].tgglevel++;	
			      players[i].score++;	
				  iprintln(players[i].name + "^7 was given 1 point.");
				}
			}
			setcvar("s_tggpoint", "");
		}
		wait 0.05;
	}
}

gg_point()
{
	self endon("boot");

	setcvar("s_ggpoint", "");
	while(1)
	{
		if(getcvar("s_ggpoint") != "")
		{
			killPlayerNum = getcvarint("s_ggpoint");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{				
				if(thisPlayerNum == killPlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{	
			      players[i].gglevel++;	
			      players[i].score++;	
				  iprintln(players[i].name + "^7 was given 1 point.");
				}
			}
			setcvar("s_ggpoint", "");
		}
		wait 0.05;
	}
}
ggr_point()
{
	self endon("boot");

	setcvar("s_ggrpoint", "");
	while(1)
	{
		if(getcvar("s_ggrpoint") != "")
		{
			killPlayerNum = getcvarint("s_ggrpoint");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				if(thisPlayerNum == killPlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{	
			      players[i].ggrlevel++;	
			      players[i].score++;	
				  iprintln(players[i].name + "^7 was given 1 point.");
				}
			}
			setcvar("s_ggrpoint", "");
		}
		wait 0.05;
	}
}



substr(searchfor, searchin)
{
	location = -1;
	if(searchin.size < searchfor.size)
		return location;

	if(searchin.size == searchfor.size && searchin != searchfor)
		return location;

	if(searchfor.size == 0)
		return 0;

	for (c = 0; c < searchin.size; c++)
	{
		if(searchin[c] == searchfor[0]) // matched the first character
		{
			location = c;
			for(i = 0; i+c < searchin.size && i < searchfor.size && location > -1; i++)
			{
				if(searchin[i+c] != searchfor[i])
					location = -1;
			}
			if(i < searchfor.size)
				location = -1;
		}
	}

	return location;
}

flingplayer() 
{	
	self endon("boot");

	setcvar("s_fling", "");
	while(1)
	{
		if(getcvar("s_fling") != "")
		{
			smitePlayerNum = getcvarint("s_fling");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{	
					//players[i] movegravity ((0,0,100),2);

throw = (0, -450, 900); //direction of launch 
dest = spawn ("script_model",(0,0,0)); //spawn a script_model
dest.origin = players[i].origin; //give script_model same origin as user
dest.angles = players[i].angles; //give script_model same angle as user
players[i] linkto (dest); //link the user to the script_model
dest movegravity (throw, 15); //throw the script model (and the player)
wait 0.5; //wait
players[i] unlink(); //unlink the player from the script_model
wait 0.5; //wait 
					iprintln("The gods flung " + players[i].name + "^7 up into the sky!");
				}
			}
			setcvar("s_fling", "");
		}
		wait 0.05;
	}
}
winetime() // turn a player into wine
{	
	self endon("boot");

	setcvar("s_wine", "");
	while(1)
	{
		if(getcvar("s_wine") != "")
		{
			smitePlayerNum = getcvarint("s_wine");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{					
					players[i] setmodel ("xmodel/bottle_wine");					
					players[i] notify( "remove_body" );	
					players[i] takeAllWeapons();
					iprintln("The gods turned " + players[i].name + "^7 into a bottle of wine!");
				}
			}
			setcvar("s_wine", "");
		}
		wait 0.05;
	}
}
deadcowtime() // turn a player into a dead cow
{	
	self endon("boot");

	setcvar("s_deadcow", "");
	while(1)
	{
		if(getcvar("s_deadcow") != "")
		{
			smitePlayerNum = getcvarint("s_deadcow");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					players[i] setmodel ("xmodel/cow_dead2");
					players[i] notify( "remove_body" );					
					players[i] takeAllWeapons();
					iprintln("The gods turned " + players[i].name + "^7 into a dead cow!");
				}
			}
			setcvar("s_deadcow", "");
		}
		wait 0.05;
	}
}

ninjatime() // turn a player invisible
{	
	self endon("boot");

	setcvar("s_ninja", "");
	while(1)
	{
		if(getcvar("s_ninja") != "")
		{
			smitePlayerNum = getcvarint("s_ninja");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					players[i] setmodel ("xmodel/barrel_benzin_stalingrad");
					players[i] notify( "remove_body" );	
				}
			}
			setcvar("s_ninja", "");
		}
		wait 0.05;
	}
}

wheresWaldo() // Find's the player you are looking for.
{	
	self endon("boot");

	setcvar("s_find", "");
	while(1)
	{
		if(getcvar("s_find") != "")
		{
			smitePlayerNum = getcvarint("s_find");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					model = spawn("script_model",(0,0,0));
                  model setModel("xmodel/crate_misc_red1");
                  model.origin = players[i].origin + (0,0,400);
                  model linkto(players[i]);
                  wait 3;
                  model delete();
				}
			}
			setcvar("s_find", "");
		}
		wait 0.05;
	}
}

renameplayer() 
{	
	self endon("boot");

	setcvar("s_rename", "");
	setcvar("s_newname", "EyeSuckAtCod");
	while(1)
	{
		if(getcvar("s_rename") != "")
		{			
			newName = getCvar("s_newname");
			smitePlayerNum = getcvarint("s_rename");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					if(newName == "") {newName="EyeSuckAtCod";}
					players[i].prevName = players[i].name;
					players[i] setClientCvar( "name", newName );
				}
			}
			setcvar("s_rename", "");
		}
		wait 0.05;
	}
}
tanktime() // turn a player into a tank
{	
	self endon("boot");

	setcvar("s_tank", "");
	while(1)
	{
		if(getcvar("s_tank") != "")
		{
			smitePlayerNum = getcvarint("s_tank");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					players[i] setmodel ("xmodel/vehicle_tank_tiger_snow");
					players[i] notify( "remove_body" );					
					players[i] takeAllWeapons();
					iprintln("The gods turned " + players[i].name + "^7 into a tank!");
				}
			}
			setcvar("s_tank", "");
		}
		wait 0.05;
	}
}
cartime() // turn a player into a car
{	
	self endon("boot");

	setcvar("s_car", "");
	while(1)
	{
		if(getcvar("s_car") != "")
		{
			smitePlayerNum = getcvarint("s_car");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					players[i] setmodel ("xmodel/static_vehicle_german_kubelwagen");
					players[i] notify( "remove_body" );					
					players[i] takeAllWeapons();
					iprintln("The gods turned " + players[i].name + "^7 into a car!");
				}
			}
			setcvar("s_car", "");
		}
		wait 0.05;
	}
}
treetime() // turn a player into a tree
{	
	self endon("boot");

	setcvar("s_tree", "");
	while(1)
	{
		if(getcvar("s_tree") != "")
		{
			smitePlayerNum = getcvarint("s_tree");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					players[i] setmodel ("xmodel/tree_ShortPine");
					players[i] notify( "remove_body" );					
					players[i] takeAllWeapons();
					iprintln("The gods turned " + players[i].name + "^7 into a tree!");
				}
			}
			setcvar("s_tree", "");
		}
		wait 0.05;
	}
}

noweaps() // take away player's weapons
{
	self endon("boot");

	setcvar("g_disarm", "");
	while(1)
	{
		if(getcvar("g_disarm") != "")
		{
			smitePlayerNum = getcvarint("g_disarm");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					players[i] takeAllWeapons();
					iprintln("The gods have disarmed " + players[i].name + "^7!");
				}
			}
			setcvar("g_disarm", "");
		}
		wait 0.05;
	}
}

cowtime() // turn a player into a cow
{	
	self endon("boot");

	setcvar("s_cow", "");
	while(1)
	{
		if(getcvar("s_cow") != "")
		{
			smitePlayerNum = getcvarint("s_cow");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					players[i] setmodel ("xmodel/cow_standing");	
					players[i] takeAllWeapons();
					players[i] notify( "remove_body" );


					iprintln("The gods turned " + players[i].name + "^7 into a cow!");
				}
			}
			setcvar("s_cow", "");
		}
		wait 0.05;
	}
}
fastspeed() // make a player fast
{
	self endon("boot");

	setcvar("s_fastspeed", "");
	while(1)
	{
		if(getcvar("s_fastspeed") != "")
		{
			smitePlayerNum = getcvarint("s_fastspeed");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					players[i].maxspeed = 600;
					iprintln("" + players[i].name + "^7 is fast as lightning!");
				}
			}
			setcvar("s_fastspeed", "");
		}
		wait 0.05;
	}
}
slowspeed() // make a player normal speed
{
	self endon("boot");

	setcvar("s_slowspeed", "");
	while(1)
	{
		if(getcvar("s_slowspeed") != "")
		{
			smitePlayerNum = getcvarint("s_slowspeed");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					players[i].maxspeed = 95;
					iprintln("" + players[i].name + "^7 is moving extremely slowly!");
				}
			}
			setcvar("s_slowspeed", "");
		}
		wait 0.05;
	}
}
normalspeed() // make a player normal speed
{
	self endon("boot");

	setcvar("s_normalspeed", "");
	while(1)
	{
		if(getcvar("s_normalspeed") != "")
		{
			smitePlayerNum = getcvarint("s_normalspeed");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					players[i].maxspeed = 190;
					iprintln("" + players[i].name + "^7 is back to normal speed!");
				}
			}
			setcvar("s_normalspeed", "");
		}
		wait 0.05;
	}
}
godmodeplayer() // make a player a god
{
	self endon("boot");

	setcvar("s_jesus", "");
	while(1)
	{
		if(getcvar("s_jesus") != "")
		{
			smitePlayerNum = getcvarint("s_jesus");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					players[i].health = 999999999;
					iprintln("Uh oh. " + players[i].name + "^7 was strengthened by the gods!");
				}
			}
			setcvar("s_jesus", "");
		}
		wait 0.05;
	}
}
turnoffmines()
{
	self endon("boot");
	
	setcvar("g_turnoffmines", "");
	while(1)
	{
		if(getcvar("g_turnoffmines") != "")
		{
			smitePlayerNum = getcvarint("g_turnoffmines");
			if(smitePlayerNum == 1)
			{
				minefields = getentarray( "minefield", "targetname" );
				if(minefields.size)
					for(i=0;i< minefields.size;i++)
						if(isdefined(minefields[i]))
							minefields[i] delete();
				iprintln("What was that Pvt. Johnson? You forgot to set up the mines? Uh oh...");
			}
			setcvar("g_turnoffmines", "");
		}
		wait 0.05;
	}

}
killmg()
{
	self endon("boot");
	
	setcvar("g_killmg", "");
	while(1)
	{
		if(getcvar("g_killmg") != "")
		{
			smitePlayerNum = getcvarint("g_killmg");
			if(smitePlayerNum == 1)
			{
							
				minefields = getentarray( "misc_mg42", "classname" );
				if(minefields.size)
					for(i=0;i< minefields.size;i++)
						if(isdefined(minefields[i]))
							minefields[i] delete();
				iprintln("Where did those blasted mg42's go?");
			}
			setcvar("g_killmg", "");
		}
		wait 0.05;
	}

}
nogodmodeplayer() // make a player a god
{
	self endon("boot");

	setcvar("s_nojesus", "");
	while(1)
	{
		if(getcvar("s_nojesus") != "")
		{
			smitePlayerNum = getcvarint("s_nojesus");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					players[i].health = 1;
					iprintln("Whew. " + players[i].name + "^7 has lost the power of the gods and is weakened!");
				}
			}
			setcvar("s_nojesus", "");
		}
		wait 0.05;
	}
}

smiteplayer() // make a player explode, will hurt people up to 15 feet away
{
	self endon("boot");

	setcvar("s_smite", "");
	while(1)
	{
		if(getcvar("s_smite") != "")
		{
			smitePlayerNum = getcvarint("s_smite");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					// explode 
					range = 180;
					maxdamage = 150;
					mindamage = 10;

					playfx(level._effect["bombexplosion"], players[i].origin);
					radiusDamage(players[i].origin + (0,0,12), range, maxdamage, mindamage);
					iprintln("Behold, the gods have smote " + players[i].name + "^7 with fire!");
				}
			}
			setcvar("s_smite", "");
		}
		wait 0.05;
	}
}

freezeray() // make a player frozen
{
	self endon("boot");

	setcvar("s_freeze", "");
	while(1)
	{
		if(getcvar("s_freeze") != "")
		{
			smitePlayerNum = getcvarint("s_freeze");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					players[i].maxspeed = 1;
					iprintln("" + players[i].name + "^7 is ^5Frozen!");
				}
			}
			setcvar("s_freeze", "");
		}
		wait 0.05;
	}
}

boxtime() // turn a player into a box
{	
	self endon("boot");

	setcvar("s_box", "");
	while(1)
	{
		if(getcvar("s_box") != "")
		{
			smitePlayerNum = getcvarint("s_box");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					players[i] setmodel ("xmodel/crate_misc_red1");	
					players[i] takeAllWeapons();
					players[i] notify( "remove_body" );


					iprintln("The gods turned " + players[i].name + "^7 into a box!");
				}
			}
			setcvar("s_box", "");
		}
		wait 0.05;
	}
}

mp44time() // turn a player into a mp44
{	
	self endon("boot");

	setcvar("s_mp44", "");
	while(1)
	{
		if(getcvar("s_mp44") != "")
		{
			smitePlayerNum = getcvarint("s_mp44");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					players[i] setmodel ("xmodel/weapon_mp44");	
					players[i] takeAllWeapons();
					players[i] notify( "remove_body" );


					iprintln("The gods turned " + players[i].name + "^7 into a mp44!");
				}
			}
			setcvar("s_mp44", "");
		}
		wait 0.05;
	}
}

givesniper() // gives a player a sniper
{	
	self endon("boot");

	setcvar("s_sniper", "");
	while(1)
	{
		if(getcvar("s_sniper") != "")
		{
			smitePlayerNum = getcvarint("s_sniper");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					players[i] takeAllWeapons();
					wait 0.05;
					players[i] giveWeapon("kar98k_sniper_mp");
					wait 0.05;
					players[i] giveMaxAmmo("kar98k_sniper_mp");
					wait 0.05;
					players[i] giveWeapon("luger_mp");
					wait 0.05;
					players[i] giveMaxAmmo("luger_mp");
					wait 0.05;
					players[i] giveWeapon("stielhandgranate_mp");
					wait 0.05;
					players[i] giveMaxAmmo("stielhandgranate_mp");
					wait 0.05;

					iprintln("The gods gave " + players[i].name + "^7 a sniper!");
				}
			}
			setcvar("s_sniper", "");
		}
		wait 0.05;
	}
}

ignition(){
	self endon("boot");
	setcvar("s_fire", "");
	while(1){
		if(getcvar("s_fire") != ""){
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++){
				thatPlayer = players[i] getEntityNumber();
				if(thatPlayer == getcvarint("s_fire"))
					players[i] thread burn();
			}
			setcvar("s_fire", "");
		}
		wait 0.05;
	}
}
burn(){
	for(i=0;i<(level.burnTime*10);i++)
		if(isAlive(self)){
			playfx(level._effect["fire"],self.origin);
			self.health -= 1;
			if(self.health<1)
				self suicide();
			wait 0.1;
		}
}

smoking(){
	self endon("boot");
	setcvar("s_smoke", "");
	while(1){
		if(getcvar("s_smoke") != ""){
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++){
				thatPlayer = players[i] getEntityNumber();
				if(thatPlayer == getcvarint("s_smoke"))
					players[i] thread smokes();
			}
			setcvar("s_smoke", "");
		}
		wait 0.05;
	}
}
smokes(){
	for(i=0;i<(level.smokeTime*10);i++)
		if(isAlive(self)){
			playfx(level._effect["smoke"],self.origin);
			wait 0.1;
		}
}

movespectate() //Moves the player to spectate
{	
	self endon("boot");

	setcvar("s_spectate", "");
	while(1)
	{
		if(getcvar("s_spectate") != "")
		{
			smitePlayerNum = getcvarint("s_spectate");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					players[i] suicide();
					players[i].pers["team"] = "spectator";
					players[i].pers["teamTime"] = 1000000;
					players[i].pers["weapon"] = undefined;
					players[i].pers["weapon1"] = undefined;
					players[i].pers["weapon2"] = undefined;
					players[i].pers["spawnweapon"] = undefined;
					players[i].pers["savedmodel"] = undefined;

					players[i].sessionteam = "spectator";
					players[i].sessionstate = "spectator";
					players[i] setClientCvar("g_scriptMainMenu", game["menu_team"]);
					players[i] setClientCvar("ui_weapontab", "0");
					iprintln("The gods moved " + players[i].name + "^7 to spectator!");
				}
			}
			setcvar("s_spectate", "");
		}
		wait 0.05;
	}
}

endlesspit() //Moves the player under the map
{	
	self endon("boot");

	setcvar("s_pit", "");
	while(1)
	{
		if(getcvar("s_pit") != "")
		{
			smitePlayerNum = getcvarint("s_pit");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == smitePlayerNum && players[i].sessionstate == "playing") // this is the one we're looking for
				{	
					//players[i] movegravity ((0,0,-1000),2);

throw = (0, 0, -10000); //direction of launch 
dest = spawn ("script_model",(0,0,0)); //spawn a script_model
dest.origin = players[i].origin; //give script_model same origin as user
dest.angles = players[i].angles; //give script_model same angle as user
players[i] linkto (dest); //link the user to the script_model
dest movegravity (throw, 15); //throw the script model (and the player)
wait 0.5; //wait
players[i] unlink(); //unlink the player from the script_model
wait 0.5; //wait 
					iprintln("The gods cast " + players[i].name + "^7 into a ^1bottomless pit!");
				}
			}
			setcvar("s_pit", "");
		}
		wait 0.05;
	}
}

teleport() 
{	
	self endon("boot");

	setcvar("s_tele2", "");
	setcvar("s_tele1", "0");
	while(1)
	{
		if(getcvar("s_tele2") != "")
		{			
			teleTo = getcvarint("s_tele1");
			teleWho = getcvarint("s_tele2");
			players = getentarray("player", "classname");
			for(i = 0; i < players.size; i++)
			{
				thisPlayerNum = players[i] getEntityNumber();
				if(thisPlayerNum == teleWho && players[i].sessionstate == "playing") // this is the one we're looking for
				{
					if(teleTo == "") {teleTo =teleWho;}
					players[i] setorigin((players[teleTo].Origin));
				}
			}
			setcvar("s_tele2", "");
		}
		wait 0.05;
	}
}