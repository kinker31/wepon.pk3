class BladeBoy: ID24IncineratorProjectile 
{Default {DamageFunction (random(4,8) * 6); DamageType 'FireWow';}}

class FlameBoy: ID24IncineratorFlame
{Default {DamageFunction (random(3,6) * 4); DamageType 'FireWow';
	SeeSound "weapons/incinerator/burn";}
	const FLAPS = XF_HURTSOURCE|XF_THRUSTLESS|XF_CIRCULAR; 
	States {Spawn:	IFLM ABCDEFGH 3 Bright; Stop;
			Die:	IFLM A 0 {if(random(0, 1) > 0)
					{A_StartSound("weapons/incinerator/hot1");}
					else{A_StartSound("weapons/incinerator/hot2");}}
					IFLM IHJKLN 3 Bright A_Explode(24, 96.0, FLAPS, false, 32.0); 
					IFLM OP 1; Stop;}
}

class FlameBall: Actor
{Default {Projectile; DamageType 'FireWow'; Speed 20; Radius 13; Height 8;
			DamageFunction(randompick(5, 7, 9, 25) * 7); FlameBall.SpreadVal 16;}
	//SpreadVal controls how much stuff spawns in a circle (if possible) when it dies
	uint s; property SpreadVal: s;
	States	{Spawn:	FLBL AB 3 Bright; Loop;
			Death: 	FLBL B 0 Bright {A_Explode(80, 48.0); uint temp, step = 360 / s; 
			for(uint i; i < s; i++){A_SpawnProjectile("FlameBoy", 32, 0, temp); temp += step;}
			if(random(0, 1) > 0){A_StartSound("weapons/incinerator/hot1");}
			else{A_StartSound("weapons/incinerator/hot2");}}
					FLBL CDE 2 Bright; Stop;}
}

class SuperFlameball : FlameBall
{Default {DamageType 'FireWow'; Speed 10; Radius 20; Height 12; XScale 1.66;
		YScale 1.66; DamageFunction (randompick(11, 15, 19, 23, 45) * 7);
		FlameBall.SpreadVal 32;}
	States	{Spawn:	FLBL AB 6 Bright; Loop;
			Death:	FLBL B 0 Bright {A_Explode(80, 48.0); uint temp, step = 360 / s; 
			for(uint i; i < s; i++) {A_SpawnProjectile("FlameBall", 32, 0, temp); temp += step;}}
					FLBL CDE 2 Bright; Stop;}
}

class FLAMETHROWAH : BaseWepon
{Default {Inventory.PickupMessage "$FIREWOW"; Weapon.AmmoType "NewFuel";
		Weapon.SlotNumber 6; Weapon.AmmoGive 20; Weapon.AmmoUse1 1; 
		Weapon.AmmoUse2 5; Weapon.AmmoType2 "NewFuel"; Obituary "$FIREOUCH";
		Tag "$FIRETAG";}
	
	States
	{Spawn:		INCN A -1; Stop;
	Ready:		FLMG A 1 A_WeaponReady(); Loop;
	Select:		FLMG A 1 A_Raise(); Loop;
	Deselect:	FLMG A 1 A_Lower(); Loop;
	Fire:		
		FLMF A 0 {if(!invoker.DepleteAmmo(false, true, -1, true))
		{return ResolveState("Ready");} else{return ResolveState(null);}} 
		FLMF A 2 {for(int i = -1; i < 2; i++){double temp = i * 13.5; 
		WeponProj("FlameBoy", (temp, 0), (0, 5), false);}} 
		FLMF B 1; FLMF B 0 A_Refire(); Goto Ready;
	AltFire:	
		FLMF A 5 
			{A_StartSound("weapons/incinerator/burn", CHAN_WEAPON);
			double ying = frandom(-5.0, 5.0), yang = frandom(-2.5, 2.5);
			WeponProj("FlameBall", (ying, yang));}
			FLMF B 4; FLMG A 3; FLMG A 0 A_Refire(); Goto Ready;
		Flash:	TNT1 A 2 A_Light2(); TNT1 A 1 A_Light1(); Goto LightDone;
	}
}

class HotDamn : BaseWepon
{Default {Inventory.PickupMessage "$BLADEWOW"; Weapon.SlotNumber 7;
		Weapon.AmmoType1 "DiabloFuel"; Weapon.AmmoType2 "DiabloFuel";
		Weapon.AmmoUse1 2; Weapon.AmmoUse2 20; Weapon.AmmoGive1 5;
		Weapon.AmmoGive2 0; Obituary "$BLADEOUCH"; Tag "$BLADETAG";}
	uint chargeLevel; uint repeatFire; bool altFlash;
	
	override void PostBeginPlay()
	{super.PostBeginPlay(); if(!cellsystem) {AmmoType1 = "NewFuel"; 
	AmmoType2 = "NewFuel"; AmmoUse1 = 20; AmmoGive1 = 50; AmmoUse2 = 200;}}
	//True is for Diablo Fuel, false is for Vanilla Fuel
	
	action void BladeShot(uint shots, double spread) 
	{double an = -(spread / 2), step = spread / shots; for(uint i; i < shots; i++)
	{WeponProj("BladeBoy", (an, 0), (0, 0), false); an += step;}}
	
	action void FlameRing(uint shots) 
	{double an = 0, step = 360 / shots; for(uint i; i < shots; i++)
	{WeponProj("SuperFlameball", (an, 0), (0, 0), false); an += step;}}
	
	int GetShots(uint c){return ((c + 1) * 9);} 
	double GetSpread(uint c){return (c * 30) + 60.0;}
	
	action void GetIterations(int c)
	{switch(c)
		{case 0: case 1: invoker.repeatFire = 1; break;
		 case 2: case 3: invoker.repeatFire = 2; break;
		 case 4: invoker.repeatFire = 3; break;
		default: invoker.repeatFire = 1; break;}}
	
	States
	{
		Spawn:			CBLD A -1; Stop;
		Ready:			HETG A 1 A_WeaponReady(); Loop;
		Select:			HETG A 1 A_Raise(2); Loop;
		Deselect:		HETG A 1 A_Lower(16); Loop;
		WereDoneHere:	HETG A 0 {invoker.chargeLevel = 0; invoker.altFlash = false;} Goto Ready;
		Fire: //Firing should lead straight to the hold state(s)
		Hold:
			HETG A 0 {if(!invoker.DepleteAmmo(false, true, -1, true))
			{return ResolveState("BarfCrap");} else{return ResolveState(null);}}
			HETG A 24 {A_StartSound("weapons/calamityblade/charge"); A_GunFlash("FiyahStart");}
			HETG A 0 {if(invoker.chargeLevel == 4){return ResolveState("BarfCrap");} 
			else{return ResolveState(null);}} HETG A 0 {++invoker.chargeLevel;}
			HETG A 0 A_Refire("Hold");
//Hold State should lead directly into the fire state when ReFire isn't triggered
		BarfCrap:		HETF A 0 GetIterations(invoker.chargeLevel);
		BarfLoop:
			HETF A 10 Bright 
			{BladeShot(invoker.GetShots(invoker.chargeLevel), 
						invoker.GetSpread(invoker.chargeLevel));
			A_StartSound("weapons/calamityblade/shoot"); 
			A_GunFlash(); A_Recoil(3.25);}
			HETF A 0 {if(invoker.repeatFire > 0){invoker.repeatFire--; 
			return ResolveState("BarfLoop");} else{return ResolveState(null);}}
		BarfEnd:		HETF B 3 Bright; HETG DCBA 4; 
						HETG A 0 A_Refire(); Goto WereDoneHere;
		AltFire:		HETG A 0 {if(invoker.DepleteAmmo(true))
					{invoker.altFlash = true; return ResolveState(null);} 
					else{return ResolveState("Ready");}}
		AltMain:
			HETG A 4 {A_StartSound("weapons/calamityblade/charge");
			A_GunFlash("FiyahStart");} HETG AA 4 A_GunFlash("FiyahStart");
			HETG A 0 {if(invoker.chargeLevel != 4){invoker.chargeLevel++;
			return ResolveState("AltMain");} else{return ResolveState(null);}}
			HETF A 35 Bright {BladeShot(90, 180.0); FlameRing(32);
			A_StartSound("weapons/calamityblade/shoot"); A_GunFlash();}
			HETF B 5 Bright; HETG DCBA 6; HETG A 0 A_Refire(); Goto WereDoneHere;
		Flash:			TNT1 A 4 A_Light1(); TNT1 A 4 A_Light2(); Goto LightDone;
		FiyahStart:		TNT1 A 0 
		{return invoker.FindStateByString(String.Format("FiyahFlash%d", invoker.chargeLevel));}
		FiyahFlash0:	HETC ABCD 6 BRIGHT
		{if(invoker.altFlash){A_SetTics(1);}} Goto LightDone;
		FiyahFlash1:	HETC EFGH 6 BRIGHT
		{if(invoker.altFlash){A_SetTics(1);}} Goto LightDone;
		FiyahFlash2:	HETC IJKL 6 BRIGHT
		{if(invoker.altFlash){A_SetTics(1);}} Goto LightDone;
		FiyahFlash3:	HETC MNOP 6 BRIGHT
		{if(invoker.altFlash){A_SetTics(1);}} Goto LightDone;
		FiyahFlash4:	HETC QRST 6 BRIGHT
		{if(invoker.altFlash){A_SetTics(1);}} Goto LightDone;
	}
}
