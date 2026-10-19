class UltraShotgun: BaseWepon
{
	Default {Weapon.SlotNumber 3; Weapon.AmmoType1 "NewShell"; Weapon.AmmoType2 "NewShell"; 
			Weapon.AmmoUse1 4; Weapon.AmmoUse2 12; Weapon.AmmoGive1 12; Weapon.AmmoGive2 0; 
			Inventory.PickupMessage "$ULTRAWOW"; Obituary "$ULTRAOUCH"; Tag "$ULTRATAG";}
	bool isFiring, isAltFire;
	override void DoEffect()
	{super.DoEffect(); double finalSpeed = 1.0;
	if (owner && owner.player.ReadyWeapon == self)
	{if(isFiring){if(isAltFire){finalSpeed = 0.25;}
	else{finalSpeed = 0.444;}} else{finalSpeed = 1.0;}}
	owner.speed = owner.default.speed * finalSpeed;}
	
	action void UltraBlast(bool altFire)
	{if(!invoker.DepleteAmmo(invoker.bAltFire)) {return;}
	A_GunFlash(); uint a = altFire? 256 : 128; uint b = altFire? 96 : 48;
	uint slugs, bucks = GetBuckshot(a, b); 
	double	da = altFire? 90.0: 60.0,
			db = altFire? 7.5: 3.0,
			dc = da / 2, dd = db / 1.5;
	WeponPBoolet(pCalc(true), slugs, 1, 4, stangle: (dc, db));
	WeponBoolet(-bucks, pCalc(false), 1, (da, db));
	A_StartSound("weapons/sshotf", CHAN_WEAPON);}

	States
	{Spawn:		ULSG A -1; Stop;
	Ready: 		ULSH A 1 A_WeaponReady(); Loop;
	Select:		ULSH A 1 A_Raise(8); Loop; 
	Deselect:	ULSH A 1 A_Lower(8); Loop;
	Done:		ULSH B 35; ULSH A 0 {invoker.isFiring = false;
				invoker.isAltFire = false; A_StopSound(CHAN_5);} Goto Ready;
	Fire:		ULSH A 0 {invoker.isFiring = true; 
				A_StartSound("usloop", CHAN_5, CHANF_LOOPING, 0.75, ATTN_NONE, 0.5);}
				ULSF BABABABABABABABABABA 2 Bright;
	FireLoop:	ULSF B 3 Bright UltraBlast(false); ULSF A 3 Bright;
				ULSH A 0 A_Refire("FireLoop"); Goto Done;
	Altfire:	ULSH A 0 {invoker.isFiring = true; invoker.isAltFire = true;
				A_StartSound("usloop", CHAN_5, CHANF_LOOPING, 0.75, ATTN_NONE, 0.5);}
				ULSF BABABABABABABABABABABABABABABABABABABABA 2 Bright;
	AltLoop:	ULSF B 5 Bright UltraBlast(true); ULSF A 4 Bright;
				ULSH A 0 A_Refire("AltLoop"); Goto Done;
	Flash:		TNT1 A 2 A_Light2(); TNT1 A 2 A_Light1(); Goto Lightdone;}
}
