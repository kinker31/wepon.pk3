class PunchO : BaseWepon 
{
	Default {Weapon.SlotNumber 1; Obituary "$FISTOUCH"; Tag "$TAGAFIST";
	PunchO.DamageValues 12, 16; Weapon.BobRangeX 0.25; Weapon.BobRangeY 0.25; 
	+WEAPON.WIMPY_WEAPON; +WEAPON.NOALERT; +WEAPON.MELEEWEAPON;}
	uint dMin; uint dMax; property DamageValues: dMin, dMax;
	
	//ternaries don't work here for some reason, so this'll have to do,
	action void FistFun()
	{uint multi = 1; if(CountInv("PowerStrength")) {multi = 10;} 
		uint value = random(invoker.dMin, invoker.dMax) * multi;
		A_CustomPunch(value, true, CPF_NOTURN, null, 72, 0, 0, null, "*fist", "miss");}
	
	//Hides the overlays if true, shows them if false
	action void FistOverlay(bool hide)
	{if(hide){A_Overlay(2, null); A_Overlay(3, null);} 
	else{A_Overlay(2, "LeftReady"); A_Overlay(3, "RightReady");} }
	
	States
	{
		Ready:		TNT1 A 0 FistOverlay(false);
		PostReady:	TNT1 A 1 A_WeaponReady(); Loop;
		Select:		FSTW A 1 A_Raise(12); Loop;
		Deselect:	TNT1 A 0 FistOverlay(true); FSTW A 1 A_Lower(12); Loop;
		Fire:		TNT1 A 0; Goto PostReady;
		AltFire:	TNT1 A 0; Goto PostReady;
		LeftReady: 
			FSTL A 1 
			{
				if(GetPlayerInput(INPUT_BUTTONS) & (BT_ATTACK))
				{return ResolveState("LeftHook");} return ResolveState(null);
			} 
			Loop;
		RightReady: 
			FSTR A 1 
			{
				if(GetPlayerInput(INPUT_BUTTONS) & (BT_ALTATTACK))
				{return ResolveState("RightHook");} return ResolveState(null);
			} 
			Loop;
		LeftHook:	FSTL B 2; FSTL C 4 FistFun(); FSTL BA 2; Goto LeftReady;
		RightHook:	FSTR B 2; FSTR C 4 FistFun(); FSTR BA 2; Goto RightReady;
	}
}

class Vroom : BaseWepon
{
	Default {Weapon.SlotNumber 1; Inventory.PickupMessage "$CHAINWOW"; 
	Obituary "$CHAINOUCH"; Tag "$CHAINTAG";Vroom.DamageValues 6, 12; 
	Weapon.BobRangeX 0.25; Weapon.KickBack 0; +WEAPON.MELEEWEAPON;
	Weapon.UpSound "weapons/sawup"; Weapon.ReadySound "weapons/sawidle"; 
	+WEAPON.NOAUTOSWITCHTO;} uint dMin; uint dMax; 
	property DamageValues: dMin, dMax; double dizziness; double dizzyStep; 
	bool altFiring;
	
	override Void BeginPlay() {super.BeginPlay(); dizzyStep = 0.5;}
	override Void Tick()
	{super.Tick(); if(dizziness > 0 && !altFiring) {dizziness -= dizzyStep;}
	if(dizziness ~== 0) {dizziness = 0.0;}if(owner) {owner.angle += dizziness;}}
	
	action void SawFun()
	{uint multi = 1; if(CountInv('PowerStrength')){multi = 4;}
	uint value = random(invoker.dMin, invoker.dMax) * multi;
	A_Saw("weapons/sawfull", "weapons/sawhit", value, null, SF_NORANDOM, 80, 0, 0);}
	
	action void SpinAroundLikeAnIdiot(uint rays)
	{uint multi = 1; if(CountInv('PowerStrength')){multi = 4;}
	uint value = random(invoker.dMin, invoker.dMax) * multi;
	invoker.dizziness = 30; double aStep = 360 / rays; double a = 0.0; double pp;
	A_StartSound("weapons/sawhit", CHAN_WEAPON);
	for(uint i = 0; i < rays; i++)
		{pp = AimLineAttack(a, 80, null, 0.0, ALF_CHECK3D);
		LineAttack(a, 80, pp, value, 'Melee', null, LAF_ISMELEEATTACK); a += aStep;}}
	
	States
	{Spawn:		CSAW A -1; Stop;
	Ready:		DSAW AB 4 A_WeaponReady(); Loop;
	Select:		DSAW C 1 A_Raise(12); Loop;
	Deselect:	DSAW C 1 A_Lower(12); Loop;
	Fire:		DSAW CD 2 SawFun(); DSAW D 0 A_ReFire(); Goto Ready;
	AltFire:	DSAW C 0 {invoker.altFiring = true;}
				DSAW CD 2 SpinAroundLikeAnIdiot(16); DSAW D 0 A_ReFire(); 
				DSAW D 0 {invoker.altFiring = false;} Goto Ready;}
}