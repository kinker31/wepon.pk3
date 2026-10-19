class YetMoreDakka : MoreDakka
{
	Default {Weapon.SlotNumber 4; Weapon.AmmoType1 "NewClip"; Weapon.AmmoUse1 4;
			Weapon.AmmoGive1 50; Inventory.PickupMessage "$SUPER_CHAINWOW";
			Obituary "$SUPER_CHAINOUCH"; Tag "$SUPER_CHAINTAG"; MoreDakka.TickLimit 4.0, 32.0; 
			MoreDakka.TickStep 0.025; MoreDakka.SlowdownFactor 0.450, 0.125;}
	uint superHeat; const maxThreshold = 630; const minThreshold = 115;
	const PRIMARY_USE = 4; const SECOND_USE = 7;
	
	action void HereBeBoolet(uint boolet, vector2 maxAngles = (22.5, 3.25))
	{invoker.ammouse1 = PRIMARY_USE; if(invoker.DepleteAmmo(false)) {return;}
		double ying = (maxAngles.x / invoker.tVal), 
			   yang = (maxAngles.y / (invoker.tVal / 2));
		uint finalBoolet = uint(ceil(boolet/(invoker.tVal / 4)));
		A_StartSound("supergun/fire", CHAN_WEAPON);
		if(invoker.swep) {A_GunFlash("FlashA");}
		else {A_GunFlash("FlashB");} invoker.swep ^= true;
		WeponPBoolet(invoker.CGunDamage(), finalBoolet, 6, 2, stangle: (ying, yang));
		if(invoker.superHeat < maxThreshold) {++invoker.superHeat;}
	}
	
	action void BooletAndBoom(uint boolet, uint missiles, vector2 maxAngles)
	{invoker.ammouse1 = SECOND_USE; if(invoker.DepleteAmmo(false)) {return;}
		if(invoker.superHeat > minThreshold) {HereBeBoolet(12, (13.5, 9.0));
		double yinp, yanp; for(uint i; i < missiles; i++)
			{[yinp, yanp] = RandomizerCrap(-7.5, 7.5);
			WeponProj("DrunkProj", (0, 0), (yinp, yanp), false);}
		invoker.superHeat -= 5;}}
	
	States
	{
		Spawn:		SUP1 A -1; Stop;
		Ready:		SCGN A 1 A_WeaponReady(WRF_ALLOWRELOAD); Loop;
		Select:		SCGN A 1 A_Raise(7); Loop;
		Deselect:	SCGN A 1 A_Lower(7); Loop;
		Fire:
			SCGN AB 30 {invoker.spinning = true; invoker.altFire = false;
			SetSped(); HereBeBoolet(16);} SCGN A 0 A_Refire();
			TNT1 A 0 A_StartSound("click"); Goto Spindown;
		Reload:
			TNT1 A 0 A_StartSound("click");
			SCGN AB 30 {invoker.spinning = true; invoker.altFire = true;
			invoker.doTimer = true; SetSped();}
			SCGN A 0 {//A_Refire doesn't work for anything past altfire
			if(GetPlayerInput(INPUT_BUTTONS) & (BT_RELOAD))
			{return ResolveState("Reload");} else {return ResolveState(null);}}
			TNT1 A 0 A_StartSound("click"); Goto Spindown;
		Altfire:
			TNT1 A 0 {if(invoker.superHeat < minThreshold)
			{return ResolveState("NotQuite");} else{return ResolveState(null);}}
			SCGN AB 7 {invoker.spinning = true; invoker.altFire = false;
			BooletAndBoom(8, 6, (13.5, 6.66));} SCGN A 0 A_Refire();
			TNT1 A 0 {invoker.superHeat = 0; A_StartSound("click");} Goto Spindown;
		NotQuite: SCGN AB 7 A_StartSound("click"); Goto Ready;
		Spindown:
			SCGN AB 30
			{invoker.spinning = false; if(invoker.tVal > invoker.maxTick) 
			{return ResolveState("Ready");} 
			else {SetSped(); A_WeaponReady(WRF_NOSWITCH); return ResolveState(null);}}
			TNT1 A 0 A_StartSound("click"); Loop;
		FlashA:		SCGF A 2 Bright A_Light1; Goto LightDone; 
		FlashB:		SCGF B 2 Bright A_Light2; Goto LightDone;
	}
}
