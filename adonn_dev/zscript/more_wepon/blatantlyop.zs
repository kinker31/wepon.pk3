class HoovyLauncher: BaseWepon
{
	Default
	{Inventory.PickupMessage "$OPROCKWOW"; Weapon.SlotNumber 8; Obituary "$OPROCKOUCH"; 
		Tag "$OPROCKTAG"; HoovyLauncher.maxAngle 30.0; +WEAPON.BFG;
		+WEAPON.EXPLOSIVE; +WEAPON.CHEATNOTWEAPON;} double a; property maxAngle: a;
	
	action void OPShot()
	{double b = -37.5; for(int i = 0; i < 11; i++)
	{WeponProj("PlayerBoom", (b, 0), (0, 0), false); b += 7.5;}}
	
	action void OPNades()
	{A_StartSound("weapons/rocklf", CHAN_WEAPON);
	WeponProj("PlayerBouncy", (0, 9.0), (0, 0), false); 
	uint g = random(24, 32); double b;  for(uint i = 0; i < g; i++) 
	{b = frandom(-invoker.a, invoker.a);
	WeponProj("PlayerBouncy", (b, 9.0), (0, 0), false);}}
	
	States
	{Ready:		OPRL A 1 A_WeaponReady(); Loop;
	Select:		OPRL A 1 A_Raise(24); Loop; 
	Deselect:	OPRL A 1 A_Lower(24); Loop;
	Fire:		OPRL A 2 A_GunFlash(); OPRL B 3 OpShot();
				OPRL B 0 A_Refire(); Goto Ready;
	AltFire:	OPRL A 2 A_GunFlash(); OPRL B 3 OPNades();
				OPRL B 0 A_Refire(); Goto Ready;
	Flash:		OPRF A 2 Bright A_Light2(); OPRF BCD 1 Bright A_Light1(); Goto LightDone;
	Spawn:		OPRW A -1; Stop;}
}

class HoovyBFG: BaseWepon
{
	Default
	{Inventory.PickupMessage "$OPBFGWOW"; Weapon.SlotNumber 8; Obituary "$OPBFGOUCH"; 
		Tag "$OPBFGTAG"; +WEAPON.BFG; +WEAPON.EXPLOSIVE; +WEAPON.CHEATNOTWEAPON;}
	
	States
	{Ready:		SBFG A 1 A_WeaponReady(); Loop;
	Select:		SBFG A 1 A_Raise(24); Loop;
	Deselect:	SBFG A 1 A_Lower(24); Loop;
	Fire:
		SBFG C 7 {FireWeponBFGRails(120, 85.0); InstantlyPukeBolts(4, 120);
		double yap = -30.0, yop = -7.5; for(uint i = 0; i < 3; i++)
		{for(uint j = 0; j < 5; j++) {WeponProj("BigOuchyBall", (yap, yop));
		yap += 15.0;} yap = -30.0; yop += 7.5;}}
		SBFG B 7 A_Refire(); Goto Ready;
	AltFire: 	SBFG B 8 A_BFGSound(); 
				SBFG CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC 1 InstantlyPukeBolts(2, 80);
				SBFG B 7 A_Refire(); Goto Ready;
	Spawn:		SBFW A -1; Stop;}
}

class HoovySSG: BaseWepon
{
	Default
	{Inventory.PickupMessage "$OPSSGWOW"; Weapon.SlotNumber 8; Obituary "$OPSSGOUCH";
	Tag "$OPSSGTAG"; +WEAPON.BFG; +WEAPON.EXPLOSIVE; +WEAPON.CHEATNOTWEAPON;}
	const DANG = -60;
	
	action void OPShotgun(bool altfire)
	{uint slugs, bucks = 0; if(!altfire) {[slugs, bucks] = GetBuckshot(200, 60);}
	else {[slugs, bucks] = GetBuckshot(100, 30);
	double ang = invoker.DANG; for(uint i = 0; i < 17; i++)
	{WeponProj("SmolRocket", (ang, 9.0), (0, 0), false); ang += 7.5;}}
	A_GunFlash(); A_StartSound("weapons/sshotf", CHAN_WEAPON);
	WeponPBoolet(pCalc(true), slugs, 1, stangle: (30.0, 4.5));
	WeponBoolet(bucks, pCalc(false), 1, (45.0, 9.0));}
	
	States
	{Ready:		OPSG A 1 A_WeaponReady(); Loop;
	Select:		OPSG A 1 A_Raise(24); Loop;
	Deselect:	OPSG A 1 A_Lower(24); Loop;
	Flash:		OPSF A 3 Bright A_Light2(); OPSF B 3 Bright A_Light1(); Goto LightDone;
	Fire:		OPSG A 6 OPShotgun(false); OPSG A 0 A_Refire(); Goto Ready;
	AltFire:	OPSG A 12 OPShotgun(true); OPSG A 0 A_Refire(); Goto Ready;	
	Spawn:		OPSW A -1; Stop;}
}
