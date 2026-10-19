class GoldProj: FastProjectile
{Default {Projectile; DeathSound "weapons/rocklx"; +FORCEXYBILLBOARD; +Ripper; -Randomize; 
		Radius 6; Height 6; Speed 80; Damage 32; Obituary "$GOLDBULLETOUCH";}
	States {Spawn: GBUL AB 2 Bright; Loop; Death: GBUL CDE 3 Bright; Stop;}
}

class GoldPistol: BaseWepon
{
	Default
	{Inventory.PickupMessage "$GOLDWOW"; Weapon.AmmoType "GoldBullet";
	Weapon.SlotNumber 2; Weapon.SelectionOrder 256; Weapon.AmmoUse 1;
	Weapon.AmmoGive 1; Obituary "$GOLDOUCH"; Tag "$GOLDTAG";}
	
	action void GoldBoolet()
	{if(!invoker.DepleteAmmo(false)) {return;}
		A_GunFlash(); A_StartSound("goldenpistol/fire", CHAN_WEAPON);
		WeponBoolet(0, 1000, 1, (0, 0)); WeponProj("GoldProj");}
	
	action void MultiGold(uint amount)
	{if(!invoker.DepleteAmmo(true)){return;}
		A_StartSound("goldenpistol/fire", CHAN_WEAPON); A_GunFlash();
		double ying, yang = RandomizerCrap(-5, 5); 
		for(uint i = 0; i < amount; i++)
		{WeponBoolet(-1, 125, 3, (ying, yang)); 
			[ying, yang] = RandomizerCrap(-5, 5);
			WeponProj("GoldProj", (ying, yang), (0, 0), false);
			[ying, yang] = RandomizerCrap(-5, 5);}
	}
	
	States
	{Ready:		GPIS A 1 A_WeaponReady(WRF_NOBOB); Loop;
	Select:		GPIS A 1 A_Raise(12); Loop;
	Deselect:	GPIS A 1 A_Lower(12); Loop;
	Fire:		GPIS B 4 Bright GoldBoolet();
				GPIS C 16; GPIS BA 4 A_Light0();
				GPIS A 0 A_Refire(); Goto Ready;
	Altfire:	GPIS A 0 {}
				GPIS B 2 Bright MultiGold(3); GPIS BA 2;
				GPIS A 0 A_Refire(); Goto Ready;
	Flash:		GPSF A 2 Bright A_Light2();
				GPSF A 2 Bright A_Light1(); Goto LightDone;
	Spawn:		GOLD A -1; Stop;}
}
