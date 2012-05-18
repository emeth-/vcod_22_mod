BHSetup()
{
	precacheString(&"BH_HUD_TARGET");
	precacheString(&"BH_HUD2_TARGET");
	precacheString(&"None");
	precacheString(&"Your Target: ");
}

BHAssignTarget()
{
	players = getentarray("player", "classname");
	totplayersaround = 0;
	for(i = 0; i < players.size; i++)
	{
		if(players[i].sessionstate == "playing")
		{
			totplayersaround = totplayersaround + 1;
		}
	}
	if(totplayersaround > 1)
	{
		i = randomInt(players.size);
		target = players[i];
		if(target != self && target.sessionstate == "playing" && self.sessionstate == "playing")
		{
			self.BHTarget = target;
			target.BHHitman = self;
		}
		else
			thread BHAssignTarget();	
	}
	else
	{
		self.BHTarget = self;
	}
}

BHManageHUD()
{
/*
	self.bh_hud_target = newClientHudElem(self);
	self.bh_hud_target.archived = false;
	self.bh_hud_target.x = 459.5;
	self.bh_hud_target.y = 402;
	self.bh_hud_target.alignX = "left";
	self.bh_hud_target.alignY = "top";
	self.bh_hud_target.sort = 1;
	self.bh_hud_target.fontScale = .8;
	self.bh_hud_target.label = &"Your Target: ";
	
	self.bh_hud2_target = newClientHudElem(self);
	self.bh_hud2_target.archived = false;
	self.bh_hud2_target.x = 519.5;
	self.bh_hud2_target.y = 402;
	self.bh_hud2_target.alignX = "left";
	self.bh_hud2_target.alignY = "top";
	self.bh_hud2_target.sort = 1;
	self.bh_hud2_target.fontScale = .8;
	self.bh_hud2_target.label = &"BH_HUD2_TARGET";
	self.bh_hud2_target setText(self.BHTarget.name);
	iprintln("bhtarget:" + self.BHTarget.name);

	while(self.sessionstate == "playing")
	{
		self waittill("bh_update_hud");
		self.bh_hud2_target setText(self.BHTarget.name);
	}

	self.bh_hud_target destroy();
	self.bh_hud2_target destroy();
	*/
		while(self.sessionstate == "playing")
		{
			self waittill("bh_update_hud");
			if(isDefined(self.BHTarget.name)) 
			{
				self iprintln("^7Your Target: " + self.BHTarget.name);
				self iprintlnbold("^7Your Target: " + self.BHTarget.name);
			}
		}
}
