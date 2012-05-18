
ggrSetup()
{
	// precache
	precacheString(&"Your Level:  ");
	precacheString(&"You start with a pistol. Kill people, and gain a level, upgrading your gun.");
	

	precacheItem("m1carbine_mp");
	precacheItem("m1carbine_mp");
	precacheItem("sbluger_mp");
	precacheItem("colt_mp");
	precacheItem("m1garand_mp");
	precacheItem("sten_mp");
	precacheItem("thompson_mp");
	precacheItem("ppsh_mp");
	precacheItem("bren_mp");
	precacheItem("bar_mp");
	precacheItem("enfield_mp");
	precacheItem("mosin_nagant_mp");
	precacheItem("fg42_mp");
	precacheItem("mosin_nagant_sniper_mp");
	precacheItem("springfield_mp");
	precacheItem("panzerfaust_mp");
	precacheItem("fraggrenade_mp");
	precachemodel("xmodel/vehicle_tank_tiger_snow");	
	precachemodel("xmodel/cow_standing");			
	precachemodel("xmodel/barrel_benzin_stalingrad");
	precachemodel("xmodel/weapon_mp44");
	precachemodel("xmodel/crate_misc_red1");
	precachemodel("xmodel/bottle_wine");
	precachemodel("xmodel/cow_dead2");
	precachemodel("xmodel/tree_ShortPine");
	precachemodel("xmodel/weapon_kar98k_sniper_mp");
}

ggrGiveGun()
{
	self iprintlnbold(self.name + " ^7is on level "+self.ggrlevel+"!");
	if(self.ggrlevel==1)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("colt_mp");
		wait 0.05;
		self giveMaxAmmo("colt_mp");
		wait 0.05;
		self switchtoweapon("colt_mp");
	}
	else if(self.ggrlevel==2)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("luger_mp");
		wait 0.05;
		self giveMaxAmmo("luger_mp");
		wait 0.05;
		self switchtoweapon("luger_mp");
	}
	else if(self.ggrlevel==3)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("m1carbine_mp");
		wait 0.05;
		self giveMaxAmmo("m1carbine_mp");
		wait 0.05;
		self switchtoweapon("m1carbine_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==4)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("m1garand_mp");
		wait 0.05;
		self giveMaxAmmo("m1garand_mp");
		wait 0.05;
		self switchtoweapon("m1garand_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==5)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("enfield_mp");
		wait 0.05;
		self giveMaxAmmo("enfield_mp");
		wait 0.05;
		self switchtoweapon("enfield_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==6)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("kar98k_mp");
		wait 0.05;
		self giveMaxAmmo("kar98k_mp");
		wait 0.05;
		self switchtoweapon("kar98k_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==7)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("mosin_nagant_mp");
		wait 0.05;
		self giveMaxAmmo("mosin_nagant_mp");
		wait 0.05;
		self switchtoweapon("mosin_nagant_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==8)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("sten_mp");
		wait 0.05;
		self giveMaxAmmo("sten_mp");
		wait 0.05;
		self switchtoweapon("sten_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==9)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("mp40_mp");
		wait 0.05;
		self giveMaxAmmo("mp40_mp");
		wait 0.05;
		self switchtoweapon("mp40_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==10)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("thompson_mp");
		wait 0.05;
		self giveMaxAmmo("thompson_mp");
		wait 0.05;
		self switchtoweapon("thompson_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==11)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("ppsh_mp");
		wait 0.05;
		self giveMaxAmmo("ppsh_mp");
		wait 0.05;
		self switchtoweapon("ppsh_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==12)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("bren_mp");
		wait 0.05;
		self giveMaxAmmo("bren_mp");
		wait 0.05;
		self switchtoweapon("bren_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==13)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("bar_mp");
		wait 0.05;
		self giveMaxAmmo("bar_mp");
		wait 0.05;
		self switchtoweapon("bar_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==14)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("mp44_mp");
		wait 0.05;
		self giveMaxAmmo("mp44_mp");
		wait 0.05;
		self switchtoweapon("mp44_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==15)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("fg42_mp");
		wait 0.05;
		self giveMaxAmmo("fg42_mp");
		wait 0.05;
		self switchtoweapon("fg42_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==16)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("kar98k_sniper_mp");
		wait 0.05;
		self giveMaxAmmo("kar98k_sniper_mp");
		wait 0.05;
		self switchtoweapon("kar98k_sniper_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==17)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("mosin_nagant_sniper_mp");
		wait 0.05;
		self giveMaxAmmo("mosin_nagant_sniper_mp");
		wait 0.05;
		self switchtoweapon("mosin_nagant_sniper_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==18)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("springfield_mp");
		wait 0.05;
		self giveMaxAmmo("springfield_mp");
		wait 0.05;
		self switchtoweapon("springfield_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==19)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("panzerfaust_mp");
		wait 0.05;
		self giveMaxAmmo("panzerfaust_mp");
		wait 0.05;
		self switchtoweapon("panzerfaust_mp");
	   self GiveWeapon("sbluger_mp",0);
	   wait 0.05;
	}
	else if(self.ggrlevel==20)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("fraggrenade_mp");
		wait 0.05;
		self giveMaxAmmo("fraggrenade_mp");
		wait 0.05;
		self switchtoweapon("fraggrenade_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	   wait 0.05;
	}
		if(self.ggrlevel==21)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("colt_mp");
		wait 0.05;
		self giveMaxAmmo("colt_mp");
		wait 0.05;
		self switchtoweapon("colt_mp");
	}
	else if(self.ggrlevel==22)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("luger_mp");
		wait 0.05;
		self giveMaxAmmo("luger_mp");
		wait 0.05;
		self switchtoweapon("luger_mp");
	}
	else if(self.ggrlevel==23)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("m1carbine_mp");
		wait 0.05;
		self giveMaxAmmo("m1carbine_mp");
		wait 0.05;
		self switchtoweapon("m1carbine_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==24)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("m1garand_mp");
		wait 0.05;
		self giveMaxAmmo("m1garand_mp");
		wait 0.05;
		self switchtoweapon("m1garand_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==25)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("enfield_mp");
		wait 0.05;
		self giveMaxAmmo("enfield_mp");
		wait 0.05;
		self switchtoweapon("enfield_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==26)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("kar98k_mp");
		wait 0.05;
		self giveMaxAmmo("kar98k_mp");
		wait 0.05;
		self switchtoweapon("kar98k_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==27)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("mosin_nagant_mp");
		wait 0.05;
		self giveMaxAmmo("mosin_nagant_mp");
		wait 0.05;
		self switchtoweapon("mosin_nagant_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==28)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("sten_mp");
		wait 0.05;
		self giveMaxAmmo("sten_mp");
		wait 0.05;
		self switchtoweapon("sten_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==29)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("mp40_mp");
		wait 0.05;
		self giveMaxAmmo("mp40_mp");
		wait 0.05;
		self switchtoweapon("mp40_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==30)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("thompson_mp");
		wait 0.05;
		self giveMaxAmmo("thompson_mp");
		wait 0.05;
		self switchtoweapon("thompson_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==31)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("ppsh_mp");
		wait 0.05;
		self giveMaxAmmo("ppsh_mp");
		wait 0.05;
		self switchtoweapon("ppsh_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==32)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("bren_mp");
		wait 0.05;
		self giveMaxAmmo("bren_mp");
		wait 0.05;
		self switchtoweapon("bren_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==33)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("bar_mp");
		wait 0.05;
		self giveMaxAmmo("bar_mp");
		wait 0.05;
		self switchtoweapon("bar_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==34)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("mp44_mp");
		wait 0.05;
		self giveMaxAmmo("mp44_mp");
		wait 0.05;
		self switchtoweapon("mp44_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==35)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("fg42_mp");
		wait 0.05;
		self giveMaxAmmo("fg42_mp");
		wait 0.05;
		self switchtoweapon("fg42_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==36)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("kar98k_sniper_mp");
		wait 0.05;
		self giveMaxAmmo("kar98k_sniper_mp");
		wait 0.05;
		self switchtoweapon("kar98k_sniper_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==37)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("mosin_nagant_sniper_mp");
		wait 0.05;
		self giveMaxAmmo("mosin_nagant_sniper_mp");
		wait 0.05;
		self switchtoweapon("mosin_nagant_sniper_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==38)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("springfield_mp");
		wait 0.05;
		self giveMaxAmmo("springfield_mp");
		wait 0.05;
		self switchtoweapon("springfield_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	}
	else if(self.ggrlevel==39)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("panzerfaust_mp");
		wait 0.05;
		self giveMaxAmmo("panzerfaust_mp");
		wait 0.05;
		self switchtoweapon("panzerfaust_mp");
	   self GiveWeapon("sbluger_mp",0);
	   wait 0.05;
	}
	else if(self.ggrlevel==40)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("fraggrenade_mp");
		wait 0.05;
		self giveMaxAmmo("fraggrenade_mp");
		wait 0.05;
		self switchtoweapon("fraggrenade_mp");
		wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	   wait 0.05;
	}
	else if(self.ggrlevel>=41)
	{
		self takeAllWeapons();
	   wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	   wait 0.05;
	   self switchtoweapon("sbluger_mp");
		maps\mp\gametypes\ggr::checkScores();
	}
	self notify("ggr_update_hud");
}



