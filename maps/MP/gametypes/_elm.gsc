// Zeke Victor
// xXezekielXx
// E-mail, MSN: ezekielvictor@hotmail.com
// AIM: zekecoasterfreak

// tab size = 4

ELMSetup()
{
	// precache
	precacheString(&"Lives Left:   ");

}


ELMManageHUD()
{

	self.elm_hud_powerups = newClientHudElem(self);
	self.elm_hud_powerups.archived = false;
	self.elm_hud_powerups.x = 559.5;
	self.elm_hud_powerups.y = 402;
	self.elm_hud_powerups.alignX = "left";
	self.elm_hud_powerups.alignY = "top";
	self.elm_hud_powerups.sort = 1;
	self.elm_hud_powerups.fontScale = .8;
	self.elm_hud_powerups.label = &"Lives Left:   ";
	self.elm_hud_powerups setValue(self.deaths);

	

	while(self.sessionstate == "playing")
	{
		self waittill("elm_update_hud");
		self.elm_hud_powerups setValue(self.deaths);
	}

	self.elm_hud_powerups destroy();

}



