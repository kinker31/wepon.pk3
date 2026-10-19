class PewPewBolt : PlasmaBall
{Default {Radius 11; DamageFunction GetSpreadDamage(4, 8); Speed 80; SeeSound "";}

	static uint HandleDamage(uint min, uint max)
	{uint baseDamage = random(min, max); return baseDamage * 5;}
	
	static double GetMulti(double ang)
	{double finalR = cos(ang * 1.5); return finalR;}
	
	uint GetSpreadDamage(uint minI, uint maxI)
	{uint dam = HandleDamage(minI, maxI); double damDouble = double(dam); 
	dam = ceil(damDouble); return dam;}
	
	//Tick override gradually slows projectile down to 24 units/sec over ~1 sec.
	override void Tick() 
	{super.Tick(); if(vel.length() > 24 && !IsFrozen()) {vel *= 0.975;}}
	
	//Needed for Spread Functions
	double sp;
	override void BeginPlay() {super.BeginPlay(); sp = 1.0;}
	
	States
	{Spawn:		PLSS A 0 {A_FadeOut(invoker.sp);}
	PostSpawn:	PLSS AB 4 Bright {if(GetAge() > 175)
				{return ResolveState("Death");}
				else {return ResolveState(null);}} Loop;
	Death:		PLSE ABCDE 2 Bright; Stop;}
}

class BigBlueball : PewPewBolt
{
	Default
	{Radius 13; Speed 36; XScale 2; YScale 2; BounceFactor 1.0; BounceCount 16; 
	DamageFunction HandleDamage(15, 20); Gravity 1.0; +BOUNCEAUTOOFFFLOORONLY;
	Obituary "$BIGPLASMAOUCH"; SeeSound ""; BounceSound "weapons/plasmaf"; 
	+CANBOUNCEWATER; +BOUNCEONFLOORS; -NOGRAVITY; +USEBOUNCESTATE; +BOUNCEAUTOOFF;}
	
	uint max; double ying, yang;
	
	States
	{Spawn:	RBAL AB 4 Bright; Loop;
	Bounce.Floor:	PLSE A 0
		{invoker.max = random(12, 16) * 2; for(uint i = 0; i < max; i++)
		{invoker.ying = frandom(-179.9, 179.9); invoker.yang = frandom(24, 48); 
		A_SpawnProjectile("PlasmaMine", 40.0, 0, invoker.ying, 0, invoker.yang);}}
		Goto Spawn;
	Death:	PLSE A 0
		{invoker.max = random(16, 32) * 4; for(uint i = 0; i < max; i++)
		{invoker.ying = frandom(-179.9, 179.9);invoker.yang = frandom(48, 96);
		A_SpawnProjectile("PlasmaMine", 40.0, 0, invoker.ying, 0, invoker.yang);}
		A_Explode(96, -1.0, 0, false, 48);} PLSE ABCDE 2 Bright; Stop;
	}
}

class PlasmaMine: PewPewBolt
{
	Default {DamageFunction HandleDamage(2, 4); BounceFactor 0.75; 
		Obituary "$PLASMAMINEOUCH"; Speed 16; -NOGRAVITY; BounceType "Classic";}
	States {Spawn:	PLSS AB 2 Bright {if(GetAge() > 35 ) 
			{return ResolveState("Death");} else {return ResolveState(null);}} Loop;
			Death:	PLSE A 1 A_Explode(48, 32, 0, false, 16); PLSE BCDE 1 Bright; Stop;}
}

class EnergyPewPewWeapon : BaseWepon
{
	Default {Inventory.PickupMessage "$PLASMAWOW"; Weapon.AmmoType "NewCell";
	Weapon.SlotNumber 6; Weapon.AmmoGive 40; Weapon.AmmoUse1 1; Weapon.AmmoUse2 30;
	Weapon.AmmoType2 "NewCell"; Obituary "$PLASMAOUCH"; Tag "$PLASMATAG";
	EnergyPewPewWeapon.MaxHeat 300;} bool isFiring; uint b, heat, mHeat; double s;
	property MaxHeat: mHeat;
	
	Actor pointy; PewPewBolt childPew;
	void GetTheActor() {childPew = PewPewBolt(pointy);}
	
	override void BeginPlay()
	{super.BeginPlay(); b = 1; s = 30.0;}
	//Shamelessly stole this from Doom Delta
	override void Tick()
	{super.Tick(); if(!owner || owner.player.ReadyWeapon != self) {return;}
		if (!isFiring) {heat = 0; b = 1; s = 30.0; return;}
		if(heat <= mHeat) {heat++;} b = (floor(heat / 100) * 2) + 1; 
		s = 37.5 - (floor((heat + 100) / 100.0) * 7.5);}
	
	action void PewPewFan(uint bolts, double step)
	{if(!invoker.DepleteAmmo(invoker.bAltFire)) {return;}
	A_GunFlash(); double boltAngle = step * -floor(double(bolts) / 2.0);
	if(bolts == 1) {boltAngle = 0;} for(uint i = 0; i < bolts; i++)
	{invoker.pointy = WeponProj("PewPewBolt", (boltAngle, 0), (0, 0), false);
	if(invoker.pointy) {invoker.GetTheActor(); invoker.childPew.sp = 
	PewPewBolt.GetMulti(boltAngle);} boltAngle += step;}
	A_StartSound("weapons/plasmaf", CHAN_WEAPON, CHANF_OVERLAP, 0.5);}
	
	States
	{Spawn:		PLAS A -1; Stop;
	Ready:		PLSG A 1 A_WeaponReady(); Loop;
	Select:		PLSG A 1 A_Raise(); Loop;
	Deselect:	PLSG A 1 A_Lower(); Loop;
	Fire:
		PLSG A 0 {invoker.isFiring = true;}
		PLSG A 4 PewPewFan(invoker.b, invoker.s);
		PLSG B 16 A_ReFire;
		PLSG B 0 {invoker.isFiring = false;}
		Goto Ready;
	AltFire:
		PLSG A 5
		{if(!invoker.DepleteAmmo(true, true, 20))
		{return ResolveState("Ready");} A_GunFlash(); 
		A_StartSound("weapons/plasmaf", CHAN_WEAPON);
		double maxAngle = 45.0; double ying; double yang;
		for(uint i = 0; i < uint(random(16, 32)); i++)
		{ying = frandom(-maxAngle, maxAngle);
		yang = frandom(-maxAngle, maxAngle) / 10;
		invoker.pointy = WeponProj("PewPewBolt", (ying, yang), (0, 0), false);
		if(invoker.pointy) {invoker.GetTheActor(); 
		invoker.childPew.sp = PewPewBolt.GetMulti(ying);}}
		WeponProj("BigBlueball", (0, 16), (0, 20), false);
		return ResolveState(null);}
		PLSG B 25;
		PLSG A 0 A_Refire;
		Goto Ready;
	Flash:		PLSF AB 2 Bright A_Light1; Goto LightDone;}
}
