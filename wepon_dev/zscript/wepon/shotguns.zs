class SemiAutoShotty : BaseWepon
{
	Default {Inventory.PickupMessage "$SHOTWOW"; Obituary "$SHOTOUCH";
	Tag "$TAGSHOT"; Weapon.SlotNumber 3; +WEAPON.NOAUTOFIRE; +WEAPON.AMMO_CHECKBOTH;
	Weapon.AmmoType1 "SemiAutoClip"; Weapon.AmmoType2 "NewShell"; Weapon.AmmoGive1 0; 
	Weapon.AmmoGive2 4;} int max, a, b; const USE1 = 1; const USE2 = 4;
	
	action void FireRocks(uint amount, double spread, double offset)
	{vector2 angles, sets; bool cen, dir, lef;
		for(uint i; i < amount; i++)
		{angles = RanXY(-spread, spread, 3.5); angles.y += 12.5;
		cen = angles.x ~== 0; dir = angles.x > 0;
		sets.y = frandompick(0, -1.25, -2.5, -3.0);
		if(!cen) {sets.x = dir? frandompick(0,   1.5,  3.0,  4.5): 
								frandompick(-0, -1.5, -3.0, -4.5);}
		WeponProj("SmolRocket", angles, sets, false); A_Recoil(2.25);}}
	
	action void A_PumpAction (bool altfire)
	{uint slugs, bucks, budgetB, budgetS; bool dir, cen; double offT, a, b;
		invoker.ammouse1 = altfire? USE2 : USE1;
		if(!invoker.DepleteAmmo(false)) {return;}
		A_GunFlash(); A_StartSound("weapons/shotgf", CHAN_WEAPON);
		if(!buckshotbehavior)
			{bucks = altfire? 12: 7; WeponBoolet(bucks, 5, 3, (5.6, 0.5));
			slugs = random(2, 4); if(altfire) 
			{FireRocks(slugs, 5.6, 2.5);} return;}
		budgetB = altfire? 15: 18; budgetS = altfire? 4: 7;
		[slugs, bucks] = GetBuckshot(budgetB, budgetS);
		WeponPBoolet(pCalc(true), slugs, 1, stangle: (4.5, 0.75));
		WeponBoolet(bucks, pCalc(false), 1, (7.5, 1.25));
		if(altfire) {uint fireEm = random(3, 7); FireRocks(fireEm, 7.5, 1.25);}
	}
	
	bool ReloadNeeded()
	{bool	a = ammo2.amount < 1, 
			b = ammo1.amount == ammo1.MaxAmount;
			return a || b;}
	
	States
	{Spawn:		SHOT A -1; Stop;
	Ready: 		SHTG A 1 A_WeaponReady(WRF_ALLOWRELOAD); Loop;
	Select: 	SHTG A 1 A_Raise(12); Loop;
	Deselect: 	SHTG A 1 A_Lower(12); Loop;
	Fire:		SHTG A 4 {if(invoker.ammo1.amount < 1) 
				{return ResolveState("Reload");} A_PumpAction(false); 
				return ResolveState(null);} Goto Ready;
	AltFire:	SHTG A 8 {if(invoker.ammo1.amount < 4)
				{return ResolveState("Reload");} A_PumpAction(true); 
				return ResolveState(null);} Goto Ready;
	Reload:		
		SHTG A 0 {if(invoker.ReloadNeeded())
		{return ResolveState("Ready");} return ResolveState(null);}
		SHTG A 0 A_StartSound("weapons/shotgr", CHAN_WEAPON); SHTG BC 3;
		SHTG D 4 {A_TakeInventory("NewShell", 1);
					A_GiveInventory("SemiAutoClip", 1);}
		SHTG CBA 3; Goto Ready;
	Flash:	SHTF A 3 Bright A_Light1(); 
			SHTF B 3 Bright A_Light2(); Goto LightDone;
	}
}

class SuperDeluxeShotgun: BaseWepon
{
	Default {Inventory.PickupMessage "$SUPERWOW"; Weapon.SlotNumber 3; 
	Obituary "$SUPEROUCH"; Tag "$SUPERTAG"; +WEAPON.NOAUTOFIRE; 
	+WEAPON.AMMO_CHECKBOTH; Weapon.AmmoType1 "DeluxeClip"; Weapon.AmmoUse1 2;
	Weapon.AmmoType2 "NewShell"; Weapon.AmmoGive1 0; Weapon.AmmoGive2 4;}
	int max, a, b; const SMIN = 2; const SMAX = 4;
	
	action void A_DoubleBarrel (bool altfire)
	{invoker.AmmoUse1 = altfire? SMAX : SMIN;
	if(!invoker.DepleteAmmo(false)) {return;}
	A_GunFlash(); A_StartSound ("weapons/sshotf", CHAN_WEAPON);
	if(buckshotbehavior) {uint slugs, bucks = 0; 
		if (altfire) {[slugs, bucks] = GetBuckshot(90, 16);}
		else {[slugs, bucks] = GetBuckshot(42, 7);}
		WeponPBoolet(pCalc(true), slugs, 1, stangle: (7.5, 3.75));
		WeponBoolet(bucks, pCalc(false), 1, (15, 7.5)); A_Recoil(4.5);}
		
	else {if(!altfire) {WeponBoolet(20, 5, 3, (11.2, 7.1));} 
		else {	WeponBoolet(20, 5, 3, (11.2, 7.1)); 
				WeponBoolet(20, 5, 3, (11.2, 7.1)); A_Recoil(2.5);}}
	}

	bool ReloadBool(bool mode)
	{bool a = ammo1.amount < 2, b = ammo1.amount == ammo1.MaxAmount,
		  c = ammo2.amount < 2; if(!mode) {return a || b;} return c || b;}

	States
	{Spawn:		SGN2 A -1; Stop;
	Ready: 		SHT2 A 1 A_WeaponReady(WRF_ALLOWRELOAD); Loop;
	Select:		SHT2 A 1 A_Raise(8); Loop;
	Deselect:	SHT2 A 1 A_Lower(8); Loop;
	Fire:		SHT2 A 12 {if(invoker.ammo1.amount < 2) 
				{return ResolveState("Reload");} A_DoubleBarrel(false);
				return ResolveState(null);} Goto Ready;
	AltFire:	SHT2 A 20 {if(invoker.ammo1.amount < 4) 
				{return ResolveState("Reload");} A_DoubleBarrel(true);
				return ResolveState(null);} Goto Ready;
	Reload:
		SHT2 A 0 {if(invoker.ReloadBool(true)) 
		{return ResolveState("Ready");} return ResolveState(null);}
		SHT2 BC 5; SHT2 D 6 A_StartSound("weapons/sshoto"); Goto ReloadLoop;
	ReloadLoop:
		SHT2 E 4; SHT2 F 6 {A_StartSound("weapons/sshotl");
		A_TakeInventory("NewShell", 2); A_GiveInventory("DeluxeClip", 2);}
		SHT2 A 0 {if(invoker.ReloadBool(false)) 
		{return ResolveState("ReloadDone");} else{return ResolveState(null);}}
		Loop;
	ReloadDone:	SHT2 G 4; SHT2 H 6 A_StartSound("weapons/sshotc"); Goto Ready;
	Flash:		SHT2 I 3 Bright A_Light1(); SHT2 J 3 Bright A_Light2(); Goto LightDone;
	Spawn:		SGN2 A -1; Stop;}
}

//	These two ammotypes use Ammo1 for their reloading mechanics, set 
//	DepleteAmmo()'s first value to false if you wish to use them.
class SemiAutoClip : Ammo 
{Default 
{Inventory.MaxAmount 6; Inventory.Icon "CLIP1ICN"; +INVENTORY.IGNORESKILL;}}
class DeluxeClip : Ammo 
{Default 
{Inventory.MaxAmount 4; Inventory.Icon "CLIP2ICN"; +INVENTORY.IGNORESKILL;}}
