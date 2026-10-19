class FuckYouSBARINFO: BaseStatusBar
{
	InventoryBarState diparms; HUDFont mHUDFont; HUDFont mIndexFont; HUDFont mAmountFont; HUDFont consfont; int vOff; int off; int slotStatus[6];
	//off and vOff are to make sure the HUD elemets are positioned properly on the HUD
	
	override void Init()
	{//Hopefully the Shotgunnery mod doesn't mind letting me borrow some of this...
	Super.Init(); SetSize(32, 320, 200); Font fnt = "HUDFONT_DOOM"; 
	mHUDFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft, 1, 1);
	fnt = "INDEXFONT_DOOM"; 
	mIndexFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft);
	mAmountFont = HUDFont.Create("INDEXFONT"); consfont = HUDFont.Create("Confont"); 
	diparms = InventoryBarState.Create(null, Font.CR_RED, 1.0, "BARPART5", 
				"THINGYPICK", (0, 0), "SHIFT2", "SHIFT1", (0, 0));}
	
	override void Draw(int state, double TicFrac)
	{Super.Draw(state, TicFrac);
		if(state == HUD_StatusBar) {BeginHUD(); BarCrap();}
		else if(state == HUD_Fullscreen) {BeginHUD(); FullscreenCrap();}}
	
	//Multiple conditionals to handle adonn's extra armor pickups
	int ArmorColor(double s) 
	{int result = Font.CR_Green; 
		if(s > 0.35 && s < 0.49) {result = Font.CR_Yellow;}
		else if(s > 0.49 && s < 0.7) {result = Font.CR_Blue;}
		else if(s > 0.7) {result = Font.CR_DarkRed;}
		return result;}
	
	int ColorHandler(int amount, int max)
	{static const double thresholds[] = {1.0, 0.75, 0.5, 0.25, 0.1};
		static const int colors[] = {Font.CR_Blue, Font.CR_GREEN, 
		Font.CR_YELLOW, Font.CR_ORANGE, Font.CR_RED};
		for(int i; i < thresholds.size(); i++) {
		if(amount >= max * thresholds[i]) {return colors[i];} }
		return Font.CR_BLACK;}
	
	void DrawHUDBoxes(bool bar)
	{
		//boxflags[] and so on is so that I don't have to be more verbose than required >:(
		bool canBox = Cvar.GetCVar('fragbox', CPlayer).GetBool(),
			boxFix = Cvar.GetCVar('barfix', CPlayer).GetBool();
		string part = boxfix? "BALTY":"BARPART4"; static const int boxflags[] =
			{DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT_BOTTOM, DI_SCREEN_LEFT_TOP|DI_ITEM_LEFT_TOP,
			DI_SCREEN_RIGHT_BOTTOM|DI_ITEM_RIGHT_BOTTOM, DI_SCREEN_RIGHT_TOP|DI_ITEM_RIGHT_TOP}; 
		if(bar) {DrawImage("BARBASE", (0, 0), DI_SCREEN_CENTER_BOTTOM|DI_ITEM_BOTTOM);} voff = bar? -32: 32;
		off = bar? boxflags[0]: boxflags[1]; DrawImage("BARPART1", (0, 0), off);
		if(canBox){DrawImage("BARPART3", (0, vOff), off);}
		off = bar? boxflags[2]: boxflags[3]; DrawImage("BARPART2", (0, 0), off);
		DrawImage(part, (0, vOff), off);
	}
	
	//christ what a fucking rat's nest of code why the hell do I keep compressing lines like this
	void RenderTextDammit(bool bar)
	{
		int sr = DI_TEXT_ALIGN_RIGHT; int sl = DI_TEXT_ALIGN_LEFT;
		static const int texflags[] = 
		{DI_SCREEN_LEFT_BOTTOM, DI_SCREEN_LEFT_TOP, DI_SCREEN_RIGHT_BOTTOM, DI_SCREEN_RIGHT_TOP}; 
		int orm; let armpoint = BasicArmor(CPlayer.mo.FindInventory('BasicArmor', true));
		if(armpoint){orm = armpoint.amount;}
		int helf = CPlayer.health; int helfMax = CPlayer.mo.GetMaxHealth(true); 
		static const string types[] = {"NewClip", "NewShell", "NewRocketAmmo",
		"NewCell", "NewFuel", "BFGCell", "DiabloFuel"};
		int hammo[7], hammoMax[7], hammoA, hammoB; Ammo pointerA, pointerB;
		[pointerA, pointerB, hammoA, hammoB] = GetCurrentAmmo(); 
		bool clp = pointerA != pointerB; for(uint i; i < 7; i++)
		{[hammo[i], hammoMax[i]] = GetAmount(types[i]);} vOff = bar? -28: 4; 
		off = bar? texflags[0]: texflags[1]; 
		if(pointerA) {DrawString(mHudFont, ""..hammoA, (44, vOff), off|sr, 
			ColorHandler(hammoA, pointerA.MaxAmount));}
		if(pointerB && clp) {DrawString(consfont, ""..hammoB, (0, vOff - 4), off|sl, 
		ColorHandler(hammoB, pointerB.MaxAmount), 1.0, -1, 4, (0.5, 0.5));}
		DrawString(mHudFont, String.Format("%d\cj%%", helf), (104, vOff), 
			off|sr, ColorHandler(helf, helfMax));
		off = bar? texflags[2]: texflags[3]; if(armpoint)
		{DrawString(mHudFont, String.Format("%d\cj%%", orm), (-72, vOff), 
			off|sr, ArmorColor(armpoint.savepercent));}
		int vt = vOff - 3; for(uint i; i < 5; i++)
		{DrawString(mIndexFont, ""..hammo[i], (-30, vt), off|sr);
		DrawString(mIndexFont, ""..hammoMax[i], (-5, vt), off|sr); vt += 6;}
		vt = bar? -41: 32; int vt2 = bar? -8: 8; if(cellsystem)
		{DrawString(consfont, String.Format("BFG: %d/%d", hammo[5],
					hammoMax[5]), (-130, vt), off|sl);
		DrawString(consfont, String.Format("FIRE: %d/%d", hammo[6],
					hammoMax[6]), (-130, (vt + vt2)), off|sl);}
	}
	
	void DumpDaKeys(bool bar)
	{
		bool canBox = Cvar.GetCVar('fragbox', CPlayer).GetBool(); int vTemp = bar? -33 : 49; 
		static const int flags[] = {DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT_BOTTOM, DI_SCREEN_LEFT_TOP|DI_ITEM_LEFT_TOP};
		int xTemp = canBox? 45: 9; vector2 keyPos = (xTemp, vTemp); int flag = bar? flags[0] : flags[1]; 
		double iSize = 8; int locks = Key.GetKeyTypeCount();
		for(int i; i < locks; i++) {Key k = Key(CPlayer.mo.FindInventory(Key.GetKeyType(i)));
		if(k){DrawInventoryIcon(k, keyPos, flag, 1.0, (iSize, iSize));} keyPos.y -= iSize;
		if(i % 3 == 2){keyPos.x -= iSize; keyPos.y += iSize * 3;}}
	}
	
	//[W]epon [S]lot [C]olor [H]andler
	int WSCH(uint s)
	{switch(s) 
		{case 0: return Font.CR_Gray; break;
		case 1: return Font.CR_Fire; break;
		case 2: return Font.CR_Green; break;
		default: return Font.CR_Blue; break;} 
		return Font.CR_Black;
	}
	
	void GetCurrentWepons()
	{class<Inventory> pointer; for(int i = 2; i < 8; i++)
	{int j, k = 0; do {pointer = CPlayer.weapons.GetWeapon(i, j); 
	if(CPlayer.mo.FindInventory(pointer)){k++;} j++;} 
	while(pointer) slotStatus[i-2] = k;}}
	
	void HandleArmory(bool bar)
	{int vTemp = bar? -60 : 36; int slSz; int hTemp = -33; GetCurrentWepons();
	static const int flags[] = {DI_SCREEN_RIGHT_BOTTOM|DI_ITEM_RIGHT_BOTTOM, DI_SCREEN_RIGHT_TOP|DI_ITEM_RIGHT_TOP}; 
	off = bar? flags[0] : flags[1]; for(int i = 2; i < 8; i++)
	{DrawString(mAmountFont, ""..i, (hTemp, vTemp), off, WSCH(slotStatus[i-2])); hTemp += 12; if(i % 3 == 1) {hTemp -= 36; vTemp += 10;}}}
	
	string FragNum() 
	{int number, hold; if(deathmatch){number = CPlayer.FragCount;} else{hold = CPlayer.KillCount; if(hold > 99){number = 99;} else{number = hold;}}
	return String.Format("%2d", number);}	
	void DrawTheFragbox(bool bar)
	{int vTemp = bar? -60 : 36; static const int flags[] = {DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT_BOTTOM, DI_SCREEN_LEFT_TOP|DI_ITEM_LEFT_TOP};
	off = bar? flags[0] : flags[1]; DrawString(mHUDFont, FragNum(), (32,vTemp), off|DI_TEXT_ALIGN_RIGHT, Font.CR_SAPPHIRE);}

	void MainHudFunction(bool bar)
	{bool canBox = Cvar.GetCVar('fragbox', CPlayer).GetBool(); 
		DrawHUDBoxes(bar); RenderTextDammit(bar); DumpDaKeys(bar);
		HandleArmory(bar); if(canBox){DrawTheFragbox(bar);}
		DrawInventoryBar(diparms, (0, 0), 1, DI_SCREEN_CENTER_BOTTOM|DI_ALWAYSSHOWCOUNT);
	}
	
	protected void BarCrap(){MainHudFunction(true);}
	protected void FullscreenCrap(){MainHudFunction(false);}
}

//I really don't feel like replacing the alternative HUD, so this'll be the only one.