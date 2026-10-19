class SupaThrowaa : BaseWepon
{
	Default {Weapon.SlotNumber 6; Weapon.AmmoType1 "NewFuel"; Weapon.AmmoType2 "NewFuel"; 
			 Weapon.AmmoUse1 2; Weapon.AmmoGive1 32; Weapon.AmmoUse2 8; Weapon.AmmoGive2 0; 
			 Inventory.PickupMessage "$SUPER_FLAMEWOW"; Obituary "$SUPER_FLAMEOUCH";
			 Tag "$SUPER_FLAMETAG";} uint manuProg;
	
	//Organized into three collumms because triple projectiles
	static const double FLAMEY_PATTERN[] =
	{
		-22.5, 	0.0, 	22.5,
		-45.0, 	-22.5, 	0,
		-67.5, 	-45.0, 	-22.5,
		-45.0, 	-22.5, 	0,
		-22.5, 	0.0, 	22.5,
			0, 	22.5, 	45.0,
		22.5, 	45.0, 	67.5,
			0, 	22.5, 	45.0
	};
	
	action void OhGodTheFlame(uint flameAmount, double maxCone)
	{double ying, yang; int offX, offY;
		if(!invoker.DepleteAmmo(invoker.bAltfire)) {return;}
		for(uint i = 0; i < flameAmount; i++)
		{[ying, yang] = RandomizerCrap(-maxCone, maxCone); yang /= 3.5;
		WeponProj("FlameBoy", (ying, yang), (0, 0), false);}
	}
	
	action void MancuBarficus()
	{uint num = invoker.manuProg * 3;
		A_StartSound("weapons/incinerator/burn", CHAN_WEAPON);
		for(uint i = 0; i < 3; i++)
		{WeponProj("FlameBall", (invoker.FLAMEY_PATTERN[i + num], 0));}
		invoker.manuProg++; if(invoker.manuProg > 7) {invoker.manuProg = 0;}	
	}
	
	States
	{
		Spawn:		SUP4 A -1; Stop;
		Ready:		SFLM A 1 A_WeaponReady(); Loop;
		Select:		SFLM A 1 A_Raise(6); Loop;
		Deselect:	SFLM A 1 A_Lower(6); Loop;
		Fire:		SFLM EF 3 Bright OhGodTheFlame(8, 12.5); 
					SFLM F 0 A_Refire(); SFLM ABABAB 4; Goto Ready;
		AltFire:	SFLM B 8;
		AltfireLoop:
					SFLM C 3 Bright; SFLM D 3 Bright MancuBarficus();
					SFLM D 0 A_Refire("AltfireLoop");
		LoopDone:	SFLM ABAB 2 A_WeaponReady(); SFLM ABAB 3 A_WeaponReady(); 
					SFLM ABAB 4; Goto Ready;
		Flash: 		TNT1 A 2 A_Light2(); TNT1 A 2 A_Light1(); Goto Lightdone;
	}
}
