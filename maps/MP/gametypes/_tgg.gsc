TGGSetup()
{
	// precache
	precacheString(&"Your Level:  ");

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
}

TGGGiveGun()
{
	self iprintlnbold(self.name + " ^7is on level "+self.tgglevel+"!");
	if(self.tgglevel==1)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("colt_mp");
		wait 0.05;
		self giveMaxAmmo("colt_mp");
		wait 0.05;
		self switchtoweapon("colt_mp");
		
		
	}
	else if(self.tgglevel==2)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("luger_mp");
		wait 0.05;
		self giveMaxAmmo("luger_mp");
		wait 0.05;
		self switchtoweapon("luger_mp");
	}
	else if(self.tgglevel==3)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("m1carbine_mp");
		wait 0.05;
		self giveMaxAmmo("m1carbine_mp");
		wait 0.05;
		self switchtoweapon("m1carbine_mp");
	}
	else if(self.tgglevel==4)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("m1garand_mp");
		wait 0.05;
		self giveMaxAmmo("m1garand_mp");
		wait 0.05;
		self switchtoweapon("m1garand_mp");
	}
	else if(self.tgglevel==5)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("sten_mp");
		wait 0.05;
		self giveMaxAmmo("sten_mp");
		wait 0.05;
		self switchtoweapon("sten_mp");
	}
	else if(self.tgglevel==6)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("mp40_mp");
		wait 0.05;
		self giveMaxAmmo("mp40_mp");
		wait 0.05;
		self switchtoweapon("mp40_mp");
	}
	else if(self.tgglevel==7)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("thompson_mp");
		wait 0.05;
		self giveMaxAmmo("thompson_mp");
		wait 0.05;
		self switchtoweapon("thompson_mp");
	}
	else if(self.tgglevel==8)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("ppsh_mp");
		wait 0.05;
		self giveMaxAmmo("ppsh_mp");
		wait 0.05;
		self switchtoweapon("ppsh_mp");
	}
	else if(self.tgglevel==9)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("bren_mp");
		wait 0.05;
		self giveMaxAmmo("bren_mp");
		wait 0.05;
		self switchtoweapon("bren_mp");
	}
	else if(self.tgglevel==10)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("bar_mp");
		wait 0.05;
		self giveMaxAmmo("bar_mp");
		wait 0.05;
		self switchtoweapon("bar_mp");
	}
	else if(self.tgglevel==11)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("mp44_mp");
		wait 0.05;
		self giveMaxAmmo("mp44_mp");
		wait 0.05;
		self switchtoweapon("mp44_mp");
	}
	else if(self.tgglevel==12)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("enfield_mp");
		wait 0.05;
		self giveMaxAmmo("enfield_mp");
		wait 0.05;
		self switchtoweapon("enfield_mp");
	}
	else if(self.tgglevel==13)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("kar98k_mp");
		wait 0.05;
		self giveMaxAmmo("kar98k_mp");
		wait 0.05;
		self switchtoweapon("kar98k_mp");
	}
	else if(self.tgglevel==14)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("mosin_nagant_mp");
		wait 0.05;
		self giveMaxAmmo("mosin_nagant_mp");
		wait 0.05;
		self switchtoweapon("mosin_nagant_mp");
	}
	else if(self.tgglevel==15)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("fg42_mp");
		wait 0.05;
		self giveMaxAmmo("fg42_mp");
		wait 0.05;
		self switchtoweapon("fg42_mp");
	}
	else if(self.tgglevel==16)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("kar98k_sniper_mp");
		wait 0.05;
		self giveMaxAmmo("kar98k_sniper_mp");
		wait 0.05;
		self switchtoweapon("kar98k_sniper_mp");
	}
	else if(self.tgglevel==17)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("mosin_nagant_sniper_mp");
		wait 0.05;
		self giveMaxAmmo("mosin_nagant_sniper_mp");
		wait 0.05;
		self switchtoweapon("mosin_nagant_sniper_mp");
	}
	else if(self.tgglevel==18)
	{
		self takeAllWeapons();
		wait 0.05;
		self giveWeapon("springfield_mp");
		wait 0.05;
		self giveMaxAmmo("springfield_mp");
		wait 0.05;
		self switchtoweapon("springfield_mp");
	}
	else if(self.tgglevel==19)
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
	else if(self.tgglevel==20)
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
	else if(self.tgglevel>=21)
	{
		self takeAllWeapons();
	   wait 0.05;
	   self GiveWeapon("sbluger_mp",0);
	   wait 0.05;
	   self switchtoweapon("sbluger_mp");
		maps\mp\gametypes\gg::checkScores();
	}
	self notify("tgg_update_hud");
}



