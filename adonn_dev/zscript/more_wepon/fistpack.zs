//Does WeaponLevel2 even work with overlays like this...?
class FistPack : PowerupGiver
{Default	{+COUNTITEM; +INVENTORY.ALWAYSPICKUP; +Inventory.AUTOACTIVATE;
			+Inventory.ISHEALTH; Inventory.PickupMessage "$SUPER_FISTWOW";
			Powerup.Type "PowerWeaponLevel2"; Powerup.Color "Blue", 0.25;}
	States {Spawn: FPCK A -1 Bright; Stop;}
}

extend class PunchO {Default {Weapon.SisterWeapon "PunchTwo";}}
class PunchTwo : PunchO
{Default {+WEAPON.POWERED_UP; Weapon.SisterWeapon "PunchO"; 
			Obituary "$SUPER_FISTOUCH"; Tag "$SUPER_FIST";}

	//Super Fist Overlay
	action void SFO(bool hide)
	{Console.Printf("DEBUG ONE (VOID)");
	 if(hide){A_Overlay(4, null); A_Overlay(5, null);} 
	 else{A_Overlay(4, "ReadyOne"); A_Overlay(5, "ReadyTwo");}}
	
	//Super Fist Function
	action void SFF()
	{Console.Printf("DEBUG TWO (VOID)");
	bool hasBerserk = CountInv("PowerStrength");
	uint multiLower = hasBerserk? 8 : 1, multiHigher = hasBerserk? 16 : 3,
		finalMulti = random(multiLower, multiHigher),
		finalVal = random(invoker.dMin, invoker.dMax) * finalMulti;
		A_CustomPunch(finalVal, true, CPF_NOTURN, null, 72, 0, 0, null, "*fist", "miss");
	}
	
	States
	{
		Ready:		TNT1 A 0 SFO(false);
		PostReady:	TNT1 A 1 A_WeaponReady(WRF_ALLOWRELOAD); Loop;
		ReadyOne:	F4ST A 1 
		{if(GetPlayerInput(INPUT_BUTTONS) & (BT_RELOAD)) 
		{return ResolveState("MegaPunchOne");}
		else if(GetPlayerInput(INPUT_BUTTONS) & (BT_ATTACK)) 
		{return ResolveState("BottomFists");}
		return ResolveState(null);} Loop;
		ReadyTwo:	F5ST A 1
		{if(GetPlayerInput(INPUT_BUTTONS) & (BT_RELOAD)) 
		{return ResolveState("MegaPunchTwo");}
		else if(GetPlayerInput(INPUT_BUTTONS) & (BT_ALTATTACK)) 
		{return ResolveState("TopFists");}
		return ResolveState(null);} Loop;
		BottomFists: F4ST B 2; F4ST C 4 SFF();
		BottomFistsLoop: F4ST D 2; F4ST E 4 SFF();
						 F4ST D 2; F4ST C 4 SFF();
						 TNT1 A 0
						 {if(GetPlayerInput(INPUT_BUTTONS) & (BT_ATTACK))
						 {return ResolveState("BottomFistsLoop");} 
						 return ResolveState(null);}
						 F4ST B 2; Goto ReadyOne;
		TopFists: F5ST B 2; F5ST C 4 SFF();
		TopFistsLoop: F5ST D 2; F5ST E 4 SFF();
					  F5ST D 2; F5ST C 4 SFF();
					  TNT1 A 0
					  {if(GetPlayerInput(INPUT_BUTTONS) & (BT_ALTATTACK))
					  {return ResolveState("TopFistsLoop");} 
					  return ResolveState(null);}
					  F5ST B 2; Goto ReadyTwo;
		MegaPunchOne:
			F4ST D 3; F4ST F 10 A_CustomPunch(120, true, CPF_NOTURN, null, 
											  72, 0, 0, null, "*fist", "miss");
			F4ST D 3; F4ST A 16; Goto ReadyOne;
		MegaPunchTwo:
			F5ST D 3; F5ST F 10 A_CustomPunch(120, true, CPF_NOTURN, 
											  null, 72, 0, 0, null);
			F5ST D 3; F5ST A 16; Goto ReadyTwo;
		Select:		F4ST A 1 A_Raise(12);  Loop;
		Deselect:	F4ST A 0 SFO(true); F4ST A 1 A_Lower(12);  Loop;
		Fire:		TNT1 A 0; Goto PostReady;
		AltFire:	TNT1 A 0; Goto PostReady;
		Reload: 	TNT1 A 0; Goto PostReady;
	}
}
