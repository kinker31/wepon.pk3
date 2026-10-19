//PlayerBoom can be spawned with gravity, hence bNOGRAVITY usage
class PlayerBoom : Rocket
{
	Default {DamageFunction GetDamage(12, 16, 8); Speed 24; +FORCERADIUSDMG}
	const BOOMFALGS = XF_HURTSOURCE|XF_CIRCULAR|XF_CIRCULARTHRUST;
	static uint GetDamage(uint min, uint max, uint mult)
		{return random(min, max) * mult;}

	States
	{Spawn:	MISL A 1; Loop;
	Death:	MISL A 0
			{A_Explode(208, 144.0, BOOMFALGS, true, 64.0); bNOGRAVITY = true;}
			MISL ABCD 4; Stop;}
}

class PlayerBouncy : Grenade
{Default {DamageFunction PlayerBoom.GetDamage(15, 25, 4); Speed 48;
				DeathSound "weapons/rocklx"; Gravity 0.5; +FORCERADIUSDMG}
}

class ExplosiveOrdinance : BaseWepon
{
	Default {Inventory.PickupMessage "$ROCKWOW"; Weapon.SlotNumber 5; 
	Weapon.AmmoGive1 3; Weapon.AmmoUse1 1;Weapon.AmmoType1 "NewRocketAmmo"; 
	Weapon.AmmoType2 "RocketClip"; Obituary "$ROCKOUCH"; Tag "$ROCKTAG";}
	bool boomBool;

	action void MainFire()
	{double ying, yang; 
		if(!invoker.boomBool) {WeponProj("PlayerBoom"); A_Recoil(0.5);}
		else {if(!invoker.DepleteAmmo(false, true, 3)) {return;}
		vector2 result; A_StartSound("weapons/rocklf"); 
		for(uint i = 0; i < 3; i++) {result = Vec2Aim((7.5, 3.5)); 
		WeponProj("PlayerBouncy", result, (0,0), false);}} A_Recoil(1.25);}
	
	action void BarfRockets()
	{uint amount; vector2 result;
		if(!invoker.boomBool) {amount = random(2, 4);
		for(uint i = 0; i < amount; i++) {result = Vec2Aim((7.5, 2.5));
		WeponProj("PlayerBoom", result, (0, 0), false);}}
		else {amount = random(2, 4) * 3; for(uint i = 0; i < amount; i++)
		{result = Vec2Aim((12.5, 5.5)); A_StartSound("weapons/rocklf");
		WeponProj("PlayerBouncy", result, (0, 0), false);}} 
		A_TakeInventory("RocketClip", 1); A_Recoil(1.5);}
	
	action void LoadEmUpDan() {A_StartSound("*fist"); 
	A_TakeInventory("NewRocketAmmo", 2); A_GiveInventory("RocketClip", 1);}
	
	//boomType is false by default (for rockets), true uses grenades
	action void SwapTypes()
	{invoker.boomBool ^= true; A_StartSound("misc/chat2");
	if(invoker.boomBool){A_Print("$BOOMTRUE");} else{A_Print("$BOOMFALSE");}}
	
	States
	{Spawn:		LAUN A -1; Stop;
	Ready:		MISG A 1 A_WeaponReady(WRF_ALLOWRELOAD); Loop;
	Deselect:	MISG A 1 A_Lower(8); Loop;
	Select:		MISG A 1 A_Raise(8); Loop;
	Fire: MISG A 0 
		{if(invoker.ammo2.amount > 0) {return ResolveState("BarFire");} 
		else if(invoker.ammo1.amount < 1) {return ResolveState("Ready");}
		else {return ResolveState(null);}} MISG A 3 A_GunFlash(); 
		MISG B 12 MainFire(); MISG A 0 A_Refire();
		Goto Ready;
	BarFire:	MISG A 1 A_GunFlash("BarfFlash"); MISG B 3 {BarfRockets();
				if(invoker.ammo2.amount > 0) {return ResolveState(null);}
				else{return ResolveState("Ready");}} Loop;
	Altfire:	MISG A 0 
				{if(invoker.CheckAmmo(PrimaryFire, false, true, 2) &&
				invoker.ammo2.amount < invoker.ammo2.MaxAmount)
				{return ResolveState(null);} else{return ResolveState("Ready");}}
				MISG AA 1 A_WeaponOffset(0.0, 6.0, WOF_KEEPX|WOF_ADD);
	PostAltfire:	MISG A 3; MISG B 7 
					{if(invoker.ammo2.amount < invoker.ammo2.MaxAmount && 
					invoker.ammo1.amount > 1){LoadEmUpDan(); return ResolveState(null);}
					else{return ResolveState("PostPostAltFire");}}
					MISG A 0 A_Refire("PostAltFire", false);
	PostPostAltFire:	MISG AAAA 1 A_WeaponOffset(0.0, 3.0, WOF_KEEPX|WOF_ADD);
						Goto Ready;
	Flash:	MISF A 3 Bright A_Light1(); MISF BCD 2 Bright A_Light2(); Goto LightDone;
	BarfFlash:	MISF ABCD 1 Bright A_Light2(); Goto LightDone;
	Reload:	MISG B 15 SwapTypes(); Goto Ready;
	Spawn:	LAUN A -1; Stop;}
}

class RocketClip : Ammo
{ Default {Inventory.MaxAmount 8; Inventory.Icon "RCLIPICN"; +INVENTORY.IGNORESKILL; Inventory.RestrictedTo "Freechmen";} }
