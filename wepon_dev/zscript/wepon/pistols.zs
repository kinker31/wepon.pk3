class DualPistols: BaseWepon
{
	Default {Inventory.PickupMessage "$SIDEWOW"; Weapon.AmmoType1 "NewClip"; 
	Weapon.AmmoType2 "NewClip"; Weapon.SlotNumber 2; Weapon.AmmoUse1 1; 
	Weapon.AmmoUse2 12; Weapon.AmmoGive1 25; Obituary "$SIDEOUCH"; Tag "$SIDETAG"; 
	+WEAPON.WIMPY_WEAPON;} bool swip, mode; //mode controls piercing boolet
	
	action void PewPewPistol()
	{vector2 aiming = altpistol? (7.5, 2.5) : (2.5, 1.);
	uint dice = altpistol? 4 : 3, dam = altpistol? 4 : 10, limb;
		if(invoker.mode) {limb = altpistol? 2 : 3;
			WeponPBoolet(dam, 1, dice, limb, 1024, aiming, eat: (!altpistol));}
		else {dam += altpistol? 8 : 12;
			WeponBoolet(2, dam, dice, aiming, true);}
	A_StartSound("weapons/pistol"); A_Light1();}
	
	action void PewPewAltFire(int iter, double maxAngle)
	{double ying = -maxAngle, yang, divider = 1.5; int i, j; bool yomp;
	for(i = -iter; i <= iter; i++) {yang = -maxAngle / divider;
	for(j = -iter; j <= iter; j++) {yomp = (abs(i) + abs(j)) < (iter + 1);
	if(yomp){WeponBoolet(0, 7, 12, (ying, yang));}
	yang += ((maxAngle / iter) / divider);} ying += (maxAngle / iter);}}
	
	action void Swappity() {invoker.mode ^= true;
		if(invoker.mode) {A_Print("$PEWTRUE");}
		else {A_Print("$PEWFALSE");} A_StartSound("weapons/shotgr");}
	
	States
	{Spawn:		PIST A -1; Stop;
	Ready:		DPIS A 1 A_WeaponReady(WRF_NOBOB|WRF_ALLOWRELOAD); Loop;
	Select:		DPIS A 1 A_Raise(12); Loop;
	Deselect:	DPIS A 1 A_Lower(12); Loop;
	Fire:		DPIS A 0 {if(invoker.swip){return ResolveState("FireLeft");}
				return ResolveState("FireRight");} Goto Ready;
	FireLeft:	DPIS B 2 Bright PewPewPistol(); DPIS C 2 A_Light0(); Goto OkDone;
	FireRight:	DPIS D 2 Bright PewPewPistol(); DPIS E 2 A_Light0(); Goto OkDone;
	OkDone:		DPIS A 0 {invoker.swip ^= true;} DPIS A 0 A_Refire(); Goto Ready;
	Altfire:	DPIS A 0 {if(!invoker.DepleteAmmo(true, true))
				{return ResolveState("Ready");} return ResolveState(null);}
				DPIS F 0 A_StartSound("weapons/shotgf", CHAN_WEAPON); DPIS F 5; 
				DPIS G 5 Bright PewPewAltFire(2, 8.5); DPIS F 5 A_Light0(); DPIS A 5; 
				DPIS A 0 A_Refire(); Goto Ready;
	Reload:		DPIS F 15 Swappity(); Goto Ready;
	Flash:		TNT1 A 1; Stop;
	}
}
