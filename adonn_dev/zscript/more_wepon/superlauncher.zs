class ROTTBoom : Rocket abstract
{Default {SeeSound ""; DamageFunction Dambo(0); ROTTBoom.BoomVals 144, 96;
			Speed 32; +FORCERADIUSDMG;}
	readonly uint bDist, bDam; property BoomVals: bDam, bDist;
	const XFLAGS = XF_HURTSOURCE|XF_THRUSTZ|XF_CIRCULAR|XF_CIRCULARTHRUST;
	const XFLAGS2 = SMF_LOOK|SMF_PRECISE;
	static uint Dambo(uint times = 0)
	{uint damWow, j = times; if(j == 0){j = 1;} for(uint i; i < j; i++)
	{damWow += randompick(17, 23, 31, 43);} return damWow;}
}

class BazProj: ROTTBoom
{Default {XScale 1.5; YScale 1.5; Radius 16; Height 12; DamageFunction Dambo(4);}
	
	void Cluster() {uint hat = random(3, 7); vector2 v; double d; vector3 fimp;
	A_Explode(bDam, bDist, XFLAGS); for(uint i; i < hat; i++)
	{d = random(0, 360.); v = AngleToVector(d, 48.0);
	fimp = self.pos + (v.x, v.y, frandom(-4.25, 4.25)); Spawn("Explodo", fimp);}}
	
	States {Spawn:	MISL A 1; Loop;
			Death:	MISL A 0 Cluster(); MISL ABCD 3 Bright; Stop;}
}

class HeatProj: ROTTBoom
{Default {XScale .75; YScale .75; Radius 8; Height 6; DamageFunction Dambo(3);
		+SEEKERMISSILE; ROTTBoom.BoomVals 160, 128; Speed 24;}
	States {Spawn:	MISL A 2 A_SeekerMissile(5, 5, XFLAGS2, 128); Loop;
			Death:	MISL A 0 A_Explode(bDam, bDist, XFLAGS);
					MISL ABCD 2 Bright; Stop;}
}

class DrunkProj: ROTTBoom
{Default {XScale .45; YScale .45; Radius 5; Height 4; DamageFunction Dambo(2); 
		+SEEKERMISSILE; ROTTBoom.BoomVals 128, 144; Speed 24;}

	void Stumble()
	{self.vel.y += frandom[Drunk](-7.5, 7.5);
	 self.vel.z += frandom[Drunk](-0.5, 2.5);}
	
	States {Spawn:	MISL AAAA 3 Stumble();
			Fly:	MISL A 2 A_SeekerMissile(10, 30, XFLAGS2, 128); Loop;
			Death:	MISL A 0 A_Explode(bDam, bDist, XFLAGS);
					MISL ABCD 1 Bright; Stop;}
}

class WallFlame : Actor
{Default {PROJECTILE; Radius 6; Height 2; +RIPPER; +Bright; MaxStepHeight 32; 
			Damage 7; Speed 32; +StepMissile;}
	States	{Spawn:	FIRE ABC 2;
			 Fly:	FIRE DEFE 3; Loop;
			 Death:	FIRE F 2 A_Explode(48., 64.); FIRE GH 2; Stop;}
}

class WallProj: ROTTBoom
{Default {XScale .85; YScale .85; Radius 9; Height 7;
			DamageFunction Dambo(3); Speed 16; -NOGRAVITY;} const DIST = 64.0;

	double SideWinder() {double l, r, ang; FLineTraceData d;
		ang = self.angle + 90;
		LineTrace(ang, 8192., 0.0, TRF_THRUACTORS, 16.0, 0., 0., d);
		r = d.Distance; ang = self.angle - 90;
		LineTrace(ang, 8192., 0.0, TRF_THRUACTORS, 16.0, 0., 0., d);
		l = d.Distance; return min(l, r);}
	
	void SpawnCrap()
	{uint amount = round(SideWinder() / 128.); if (amount < 3) {amount = 3;}
	vector2 temp; actor a; vector3 v, vv; double d; for(uint i; i < amount; i++) 
	{d = self.angle + 90; temp = AngleToVector(d, (DIST * i));
	v = self.pos + (temp.x, temp.y, 8.0);
	a = Spawn("WallFlame", v); if(a) {a.target = self.target; a.angle = self.angle;
	vv = ((cos(angle) * a.speed), (sin(angle) * a.speed), 0); a.vel = vv;}
	d = self.angle - 90; temp = AngleToVector(d, (DIST * i)); 
	v = self.pos + (temp.x, temp.y, 8.0);
	a = Spawn("WallFlame", v); if(a) {a.target = self.target; a.angle = self.angle;
	vv = ((cos(angle) * a.speed), (sin(angle) * a.speed), 0); a.vel = vv;}}}
	
	//Intentional State Fallthrough
	States {Spawn:	MISL AAAAAAAAAAAAAA 5;
			Fall: 	MISL A 5 {self.vel.z -= 5.0;} Loop;
			Death:	MISL A 0 {A_Explode(bDam, bDist, XFLAGS); SpawnCrap();}
					MISL ABCD 1 Bright; Stop;}
}

class Explodo : Actor
{Default {+FORCERADIUSDMG; +BRIGHT; +NOGRAVITY; +NOBLOCKMAP; Radius 1; Height 1;}
States {Spawn:	MISL B 3 NoDelay {A_Explode(192, 160); A_StartSound("weapons/rocklx");} 
				MISL C 5; MISL D 7; Stop;}}

class BombProj: ROTTBoom
{Default {XScale 1.25; YScale 1.25; Radius 12; Height 10; DamageFunction Dambo(7);
			Speed 64; ROTTBoom.BoomVals 256, 192;}
	uint iteration;
	void BombChain(double step = 12.5, uint dist = 64, uint spokes = 6)
	{double spStep = 360.0 / spokes, bang = self.angle, dang; 
	vector2 off; vector3 wow; for(uint i; i < spokes; i++)
	{dang = (bang + (step * self.iteration)) + (i * spStep);
	off = AngleToVector(dang, (dist * self.iteration));
	wow = self.pos + (off.x, off.y, (0.25 * self.iteration));
	Spawn("Explodo", wow);} self.iteration++;}
	
	States
	{Spawn:	MISL A 1; Loop;
	Death:	MISL A 0 A_Explode(bDam, bDist, XFLAGS);
			MISL BCD 2 Bright; TNT1 AAAAAAAAAA 4 BombChain(); Stop;}
}

class SplitProj: ROTTBoom
{Default {XScale .75; YScale .75; Radius 8; Height 6; DamageFunction Dambo(4);
		Speed 24; +SEEKERMISSILE; ROTTBoom.BoomVals 144, 128;}
	bool flop; double splitVal;
	
	void Inchy() {self.splitVal = flop? self.angle + 45.0 : self.angle - 45.0;
	vector2 offWow = AngleToVector(splitVal, 12.5);
	self.vel = (offWow.x, offWow.y, 0.25);}
	
	States
	{Spawn:	MISL AA 3;
	Split:	MISL AAAA 3 Inchy();
	Fly:	MISL A 3 A_SeekerMissile(10, 20, XFLAGS2, 64); Loop;
	Death:	MISL A 0 A_Explode(bDam, bDist, XFLAGS);
			MISL ABCD 1 Bright; Stop;}
}

class BoomstickTwo: BaseWepon
{Default {Weapon.SlotNumber 5; Weapon.AmmoType1 "NewRocketAmmo";
	Weapon.AmmoType2 "NewCell"; Weapon.AmmoGive1 12; Tag "$SUPER_ROCKETTAG";
	Inventory.PickupMessage "$SUPER_ROCKETWOW"; Obituary "$SUPER_ROCKETOUCH";
	Weapon.AmmoUse1 1; Weapon.AmmoUse2 75;}
	uint fMode, pMode; static const uint COSTS[] = {5, 7, 3, 8, 15, 7};
	static const class<Actor> BOOMS[] = {"BazProj", "HeatProj", "DrunkProj",
	"WallProj", "BombProj", "SplitProj"};
	
	static const string NAMES[] =
	{"Bazooka", "Heatseeker", "Drunk", "Flamewall", "Firebomb", "Split"};
	
	override void DoEffect()
	{super.DoEffect(); owner.speed = owner.default.speed * 0.666;}
	override void OnDeselect(bool fromPowerup, bool onToss)
	{super.OnDeselect(fromPowerup, onToss); owner.speed = owner.default.speed;}
	
	action void Splitto()
	{A_PlaySound("superboom/fire", CHAN_WEAPON); A_Recoil(9.5);
	 SplitProj a = SplitProj(WeponProj("SplitProj", (0, 0), (0, -16))); 
	 SplitProj b = SplitProj(WeponProj("SplitProj", (0, 0), (0, 16)));
		if(a) {a.flop = false;} if(b) {b.flop = true;}}
	
	action void LobRockit()
	{A_PlaySound("superboom/fire"); A_Recoil(8.0);
	 WeponProj(invoker.BOOMS[invoker.fMode]);}
	
	action void LobRocks(uint max = 4, double spread = 4.5)
	{A_PlaySound("superboom/fire"); uint itt = random(2, max);
	double ying, yang = (invoker.fMode == 2)? 3.0 : 6.0; 
	for(uint i; i < itt; i++) {ying = frandom(-spread, spread);
	WeponProj(invoker.BOOMS[invoker.fMode], (ying, 0)); A_Recoil(yang);}}
	
	action void Cycle()
	{invoker.pMode++; if(invoker.pMode == invoker.fMode) {invoker.pMode++;}
	if(invoker.pMode > 5) {invoker.pMode = 0;}
	string temp = StringTable.Localize("$TRIAD_SELECT");
	A_Print(String.Format(temp, invoker.NAMES[invoker.pMode], invoker.ammoUse2), 2.5);
	A_PlaySound("misc/chat2", CHAN_WEAPON);}
	
	action void Confirm()
	{if(!invoker.DepleteAmmo(true)){return;}
	invoker.fMode = invoker.pMode; A_Print("$TRIAD_PICKED", 2.5);
	A_PlaySound("plats/pt1_stop", CHAN_WEAPON);}
	
	States
	{
		Spawn:		SUP2 A -1; Stop;
		Ready:		SROC A 1 A_WeaponReady(WRF_ALLOWRELOAD); Loop;
		Select:		SROC A 1 A_Raise(3); Loop;
		Deselect:	SROC A 1 A_Lower(8); Loop;
		Fire: TNT1 A 0 {statelabel s = "Ready";
		if(!invoker.DepleteAmmo(false, true, invoker.COSTS[invoker.fMode]))
		{return ResolveState(s);} switch(invoker.fMode)
	   {case 0: s = "BazFire";	 break; case 1: s = "HSeekFire"; break;
		case 2: s = "DrunkFire"; break; case 3: s = "FWallFire"; break;
		case 4: s = "FBombFire"; break; case 5: s = "SplitFire"; break;
		default: break;} return ResolveState(s);}
		//Intentional State Passthrough
		BazFire: FWallFire:
		FBombFire:	SROC A 4 {LobRockit(); A_GunFlash("FlashA");} SROC B 12; Goto Ready;
		HSeekFire:	SROC A 3 {LobRocks();  A_GunFlash("FlashB");} SROC B 9;  Goto Ready;
		SplitFire:	SROC A 3 {Splitto();   A_GunFlash("FlashB");} SROC B 9;  Goto Ready;
		DrunkFire:
			SROC A 2 {LobRocks(7, 25.);  A_GunFlash("FlashC");} SROC B 6;
			SROC A 2 {LobRocks(5, 12.5); A_GunFlash("FlashC");} SROC B 6;
			SROC A 2 {LobRocks(3, 7.5);  A_GunFlash("FlashC");} SROC B 6; Goto Ready;
		//Normal Singlefire
		FlashA:		SROF A 4 Bright A_Light1();
					SROF BCD 4 Bright A_Light2(); Goto LightDone;
		//Normal Multifire
		FlashB:		SROF A 3 Bright A_Light1();
					SROF BCD 3 Bright A_Light2(); Goto LightDone;
		//Drunk Missiles
		FlashC:		SROF A 2 Bright A_Light1();
					SROF BCD 2 Bright A_Light2(); Goto LightDone;
		Altfire:	SROC B 12 Cycle(); Goto Ready;
		Reload:		SROC B 8 Confirm(); Goto Ready;
	}
}
