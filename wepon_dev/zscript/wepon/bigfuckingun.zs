class BFGBolt1 : PlasmaBall
{
	Default {BounceType "Doom"; BounceFactor 0.90; WallBounceFactor 0.90;
		BounceCount 8; DamageFunction GetBoltDamage(4, 8, 3, 3); Speed 96; 
		SeeSound ""; Obituary "$BFGBOLTOUCH";} 
	static int GetBoltDamage(int min, int max, int mult1, int mult2)
	{int dmg = random(min, max) * mult1; 
		if(stronkBFG) {dmg *= mult2;} return dmg;}
	States {Spawn:	PRBG AB 4 	  Bright; Loop;
			Death:	APBX ABCDEF 2 Bright; Stop;}
}
class BFGBolt2 : BFGBolt1
{
	Default {BounceFactor 0.33; WallBounceFactor 0.33;
		BounceCount 4; Speed 128;} Array<Actor> munts;
	
	override int SpecialMissileHit(Actor victim)
	{ if(!victim || (target && victim == target)) {return MHIT_PASS;}
		if (victim.bDONTRIP){return MHIT_DESTROY;}
			bool canShot = victim.bSHOOTABLE && !victim.bNONSHOOTABLE;
			bool notList = munts.Find(victim) == munts.Size();
			Actor sauce = target? target : Actor(self);
			if(canShot && notList) {victim.DamageMobj(victim, sauce, 
				GetBoltDamage(6, 10, 2, 2), 'normal');
			munts.Push(victim);} return MHIT_PASS;}
	
	States {Spawn:	PRBR AB 4 	 Bright; Loop;
			Death:	BFER ABCDE 2 Bright; Stop;}
}

class BigOuchyBall : BFGBall replaces BFGBall
{
	Default {Obituary "$BFGBALLOUCH"; Damage 256; Speed 33;}
	const FLAGS = XF_NOALLIES|XF_CIRCULAR|XF_CIRCULARTHRUST;
	
	override void PostBeginPlay()
	{super.PostBeginPlay(); if (!(target && target.player)) {return;}
		bool crap = CVar.GetCvar('bfgSkin', target.player).GetBool();
		if(crap) {self.translation = target.translation;}
	}
	
	States	{Spawn:	BFS1 AB 2 Bright; Loop;
			Death:	BFE1 A 4 Bright A_Explode(384, 512.0, FLAGS, false, 128);
					BFE1 BCDEF 4 Bright; Stop;}
}
//bfgSkin logic should apply to the BFG explosion effects too
class Flashy : BFGExtra
{Default {-ZDoomTrans; Renderstyle "Normal"; +FORCEXYBILLBOARD; +PUFFGETSOWNER;}
	override void PostBeginPlay()
	{super.PostBeginPlay(); if (!(target && target.player)) {return;}
		bool crap = CVar.GetCvar('bfgSkin', target.player).GetBool();
		if(crap) {self.translation = target.translation;}
	}
}

class BigFuckingGun : BaseWepon
{Default {Inventory.PickupMessage "$BFGWOW"; Weapon.SlotNumber 7;
	Tag "$BFGTAG"; Weapon.AmmoType1 "BFGCell"; Weapon.AmmoType2 "BFGCell";
	Weapon.AmmoUse1 1; Weapon.AmmoUse2 2; Weapon.AmmoGive1 1; 
	Weapon.AmmoGive2 0; Obituary "$BFGOUCH";}
	
	override void PostBeginPlay()
	{super.PostBeginPlay(); //True is for BFG Cells, false is for Vanilla Cells
	if(!cellsystem) {AmmoType1 = "NewCell"; AmmoType2 = "NewCell";
	AmmoUse1 = 100; AmmoGive1 = 100; AmmoUse2 = 200;}}
	
	action void ReskinCheck()
	{if (!player) {return;}
		bool crud = CVar.GetCvar('bfgSkin', player).GetBool();
		A_OverlayFlags(PSP_FLASH, PSPF_PLAYERTRANSLATED, crud);}
	
	States
	{Spawn:		BFUG A -1; Stop;
	Ready:		BFGG A 1 A_WeaponReady(); Loop;
	Select:		BFGG A 1 A_Raise(4); Loop;
	Deselect:	BFGG A 1 A_Lower(12); Loop;
	Flash:	BFGF A 0 ReskinCheck();
			BFGF A 5 Bright A_Light1(); 
			BFGF B 5 Bright A_Light2(); Goto LightDone;
	Fire:	BFGG B 10 FireWeponBFGRails(60, 75.0); BFGG C 5;
			BFGG C 15 {A_Explode(128, -1.0, XF_NOSPLASH|XF_CIRCULAR|XF_CIRCULARTHRUST);
			InstantlyPukeBolts(6, 40); WeponProj("BigOuchyBall"); A_Recoil(1.25);}
			BFGG B 5 A_Light0(); BFGG A 5 A_Refire();
			Goto Ready;
	Altfire:	BFGG A 0 {if(!invoker.DepleteAmmo(invoker.bAltfire))
					{return ResolveState("Ready");} 
					else {A_BFGSound(); return ResolveState(null);}}
				BFGG B 20 A_GunFlash(); BFGG B 0 A_Recoil(3.25);
				BFGG BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB 1
				InstantlyPukeBolts(3, 42); BFGG B 10 A_Light0(); 
				BFGG A 10 A_Refire(); Goto Ready;}
}

