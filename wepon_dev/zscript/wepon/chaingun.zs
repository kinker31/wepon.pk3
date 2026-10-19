class MoreDakka : BaseWepon
{
	Default
	{Inventory.PickupMessage "$GUNWOW"; Obituary "$GUNOUCH"; Tag "$GUNTAG";
	Weapon.AmmoType "NewClip"; Weapon.SlotNumber 4; Weapon.AmmoUse 2;
	Weapon.AmmoGive 20; MoreDakka.TickLimit 1, 16; MoreDakka.TickStep 0.048;
	MoreDakka.SlowdownFactor 0.333, 0.666;} uint graceTimer, maxTick, minTick;
	bool doTimer, altFire, spinning, swep; double tVal, tStep, slowOne, slowTwo;
	property TickStep: tStep; property TickLimit: minTick, maxTick;
	property SlowdownFactor: slowOne, slowTwo;
	
	uint CGunDamage() {return (11 - (int(tVal/2)));}
	override void DoEffect() {super.DoEffect(); double finalSpeed = 1.0; 
	if (owner && owner.player.ReadyWeapon == self)
	{if(spinning) {if(!altFire && (finalSpeed > slowOne))
		{finalSpeed = tVal / maxTick;} else if (altFire && (finalSpeed > slowTwo)) 
		{finalSpeed = tVal / maxTick;}} else {finalSpeed = 1.0;} }
	owner.speed = owner.default.speed * finalSpeed;}
	
	override void BeginPlay()
	{super.BeginPlay(); tVal = maxTick; swep = true;}
	
	override void OnDeselect(bool fromPowerup, bool onToss)
	{super.OnDeselect(fromPowerup, onToss); owner.speed = owner.default.speed;}
	
	override void Tick()
	{super.Tick(); if (owner && owner.player.ReadyWeapon == self)
		{bool capReached; double fVal = tStep; if(spinning)
			{capReached = tVal < minTick; if(!capReached) 
			{if(altFire){fVal *= 2;} if(tVal > 7.0){fVal = tStep * 2;} 
			tVal -= fVal; if(tVal < 1.0){tVal = 1.0;}}}
			else {capReached = tVal > maxTick; if(!capReached)
			{if(altFire && graceTimer <= 70 && doTimer) {graceTimer++;}
			else {graceTimer = 0; doTimer = false; altFire = false; 
			if(tVal > 7.0){fVal = tStep * 2;} tVal += fVal;}}}
		}
	}
	
	action void MoreBulletPlease()
	{
		double ying = 24 / invoker.tVal; double yang = ying / 3; 
		uint bulletWow = uint(ceil(10/(invoker.tVal + 2))); 
		A_StartSound("weapons/chngun", CHAN_WEAPON); 
		if(invoker.swep) {A_GunFlash("FlashA");}
		else {A_GunFlash("FlashB");} invoker.swep ^= true; 
		WeponBoolet(-bulletWow, invoker.CGunDamage(), 4, (ying, yang), true, 2);	
	}
	action void SetSped() {A_SetTics(int(invoker.tVal));}
	States
	{Spawn:		MGUN A -1; Stop;
	Ready:		CHGG A 1 A_WeaponReady(); Loop;
	Select:		CHGG A 1 A_Raise(); Loop;
	Deselect:
		CHGG A 0 {invoker.altFire = false; invoker.spinning = false;}
		CHGG A 1 A_Lower(); Loop;
	Fire:
		CHGG AB 10 {invoker.spinning = true; invoker.altFire = false;
		SetSped(); MoreBulletPlease();} CHGG A 0 A_Refire(); 
		TNT1 A 0 A_StartSound("click"); Goto Spindown;
	Altfire:
		TNT1 A 0 A_StartSound("click");
		CHGG AB 10 {invoker.spinning = true; invoker.altFire = true;
		invoker.doTimer = true; SetSped();} CHGG A 0 A_Refire(); 
		TNT1 A 0 A_StartSound("click"); Goto Spindown;
	Spindown:
		CHGG AB 10 {invoker.spinning = false; if(invoker.tVal > invoker.maxTick) 
		{return ResolveState("Ready");} else {SetSped(); 
		A_WeaponReady(WRF_NOSWITCH); return ResolveState(null);}}
		TNT1 A 0 A_StartSound("click"); Loop;
	FlashA:		CHGF A 2 Bright A_Light1; Goto LightDone; 
	FlashB:		CHGF B 2 Bright A_Light2; Goto LightDone;
	Spawn:		MGUN A -1; Stop;}
}