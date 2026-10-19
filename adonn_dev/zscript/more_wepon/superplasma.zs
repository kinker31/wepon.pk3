class PlasmaYoyo : PlasmaBall
{Default{Speed 0; SeeSound ""; Obituary "$SUPER_YOYOUCH"; XScale 3.5; Speed 0;
		YScale 3.5; Radius 26; Height 18; DamageFunction BigDam(); Alpha 1.0;}
	double dist, dast; const MIN_AGE = 22; const MAX_AGE = 700; const ORBSPED = 32;
	const flags = WARPF_WARPINTERPOLATION|WARPF_NOCHECKPOSITION|WARPF_COPYPITCH;
	
	static uint BigDam()
	{return (randompick(48, 64, 72, 80) * randompick(1, 1, 2, 4, 4, 8, 8, 16));}
	
	uint GetBalls()
	{uint base = random(24, 48);
	uint fin = base + round(self.GetAge() / 6.66);
	if(fin > 144){fin = 144;} return fin;}
	
	//pitches.x -> Lowest pitch (down), pitches.y -> Highest Pitch (up)
	static vector3 SpOff(double dist, vector2 pitches)
	{double ying = frandom(0., 360.), yang = frandom(pitches.x, pitches.y);
	vector3 vf = dist * ((cos(ying) * cos(yang)),
			(sin(ying) * cos(yang)), (sin(yang))); return vf;}
	
	void BackForth() 
	{self.UpdateDist(); vector2 gomi = AngleToVector(-target.pitch, self.dist);
	self.dast = 12.5 * sin(M_PI * self.GetAge() * 4);
	A_Warp(AAPTR_TARGET, gomi.x, self.dast, (32.0 + gomi.y), 0, flags);}
	
	void BigExplode()
	{A_Explode(160); uint max = self.GetBalls(); PewPewBolt b; vector3 v;
		for(uint i; i < max; i++) {v = SpOff(ORBSPED, (-2.5, 75.));
		b = PewPewBolt(Spawn("PewPewBolt", (self.pos + v)));
		if(b){b.bNoGravity = false; b.vel = v * 1.5;}}
	}
	
	void UpdateDist()
	{/*First, increase dist constantly for MIN_AGE ticks (~2 seconds).
	Then, wobble it up and down with trig-magic over a period of X * PI.
	After MAX_AGE Ticks, constantly decrease dist 'till it slams into player.*/
		if(self.GetAge() < MIN_AGE) {dist += ORBSPED;}
		else if (self.GetAge() > MAX_AGE) {dist -= ORBSPED;}
		else {dist += (ORBSPED * cos(M_PI * self.GetAge() * 2));}}
	
	override int SpecialMissileHit(Actor victim)
	{ if(!victim || ((target && victim == target) && self.GetAge() < MAX_AGE)) 
		{return MHIT_PASS;} return MHIT_DEFAULT;}
	
	States
	{Spawn:	PLSS AABB 1 Bright BackForth(); Loop;
	Death:	PLSE A 3 Bright; PLSE B 3 BigExplode(); PLSE CD 2; Stop;}
}

class SuperPewBolt : PlasmaBall
{Default{Speed 64; SeeSound ""; Obituary "$SUPER_PLASMAOUCH"; Alpha 1.0; +Bright;
		DamageFunction BigDam(); XScale 5.5; YScale 5.5; Radius 24; Height 24;}
	array<Actor> whacked;
	
	static uint BigDam()
	{return randompick(37, 43, 57, 71) * randompick(1, 1, 1, 4, 8);}
	
	void PlasmaBoom(uint base)
	{uint iters = random(base, (base * 3)); Actor hold; vector3 fPos;
	vector2 v; double angwow; for(uint i; i < iters; i++)
	{angwow = frandom(0., 360.); v = AngleToVector(angWow, self.speed);
	fPos = self.pos + (v.x, v.y, 4.0); hold = Spawn("PewPewBolt", fPos);
	if(hold){hold.bNoGravity = false; hold.vel = (v.x, v.y, frandom(0., 8.));}}}
	
	override int SpecialMissileHit(Actor victim)
	{ if(!victim || (target && victim == target)) {return MHIT_PASS;}
		if (victim.bDONTRIP){return MHIT_DESTROY;}
		bool canShot = victim.bSHOOTABLE && !victim.bNONSHOOTABLE;
		bool notList = whacked.Find(victim) == whacked.Size();
		Actor sauce = target? target : Actor(self); if(canShot && notList)
		{victim.DamageMobj(victim, sauce, BigDam(), 'normal');
		uint hVal = round(2.0 * Log(victim.Health));
		self.PlasmaBoom(hVal); whacked.Push(victim);} return MHIT_PASS;}
	
	States
	{Spawn: PLSS AB 3; Loop;
	Death: PLSE A 4 PlasmaBoom(96); PLSE BCD 3; Stop;}
}

class SuperPewPewWeapon : BaseWepon
{
	Default {Weapon.SlotNumber 6; Weapon.AmmoType1 "NewCell"; Weapon.AmmoType2 "NewCell"; 
	Weapon.AmmoUse1 0; Weapon.AmmoUse2 0; Weapon.AmmoGive1 80; Weapon.AmmoGive2 0; 
	Inventory.PickupMessage "$SUPER_PLASMAWOW"; Tag "$SUPER_PLASMATAG";}
	actor yoyo; uint backfire; const DIST = 64.0; bool isFire;
	//Primary (Fire, Mantain), Secondary (Fire, Charge)
	static const uint COSTS[] = {32, 4, 80, 2};
	const MAXBACK = 1023; const FACTOR = 168;

	void UpCost(uint cost) {ammouse1 = COSTS[cost];}

	action void YoyoFunc()
	{if(!invoker.owner) {return;} vector3 init; invoker.UpCost(1);
	if(!invoker.yoyo) {invoker.UpCost(0);}
	if(!invoker.yoyo && invoker.DepleteAmmo(false)) 
	{init = Vec3Angle(invoker.DIST, invoker.angle, 8.0);
	invoker.yoyo = Spawn("PlasmaYoyo", init);
	if(invoker.yoyo) {invoker.yoyo.target = self;} 
	A_StartSound("superplasma/fire"); return;}
	invoker.isFire = player && (player.cmd.buttons & BT_ATTACK); 
	if(!(invoker.isFire) || !invoker.DepleteAmmo(false)) 
	{invoker.yoyo.ExplodeMissile(); player.SetPSprite(PSP_WEAPON, 
									invoker.ResolveState("PostFire")); return;}}
	
	action void AltfireCharge(uint baseTicks)
	{invoker.UpCost(3); if(!invoker.DepleteAmmo(false))
	{player.SetPSprite(PSP_WEAPON, invoker.ResolveState("Oops")); return;} 
	uint minus = invoker.backfire / invoker.FACTOR; invoker.backfire += random(16, 48);
	A_SetTics(baseTicks - minus); if(invoker.backfire > invoker.MAXBACK) 
	{player.SetPSprite(PSP_WEAPON, invoker.ResolveState("BigBolt")); return;}}
	
	action void CanAltfire()
	{if(invoker.backfire > invoker.MAXBACK) {invoker.backfire = invoker.MAXBACK;}
	uint thresh = invoker.MAXBACK - invoker.backfire; bool cancan =  (random(0, thresh) < 256);
	if(cancan){player.SetPSprite(PSP_WEAPON, invoker.ResolveState("BigBolt")); return;}
	else{player.SetPSprite(PSP_WEAPON, invoker.ResolveState("Oops")); return;}}
	
	action void Whoops(uint amount)
	{double ying; actor a; A_Explode(); A_StartSound("weapons/rocklx");
	if(random(0, 255) == 0) {A_StartSound("superplasma/funni", CHAN_6);}
	for(uint i; i < amount; i++) {ying = frandom(0, 360.0); A_Recoil(2.5);
	a = WeponProj("PewPewBolt", (ying, 12.5), (0, 0), false); if(a)
	{a.bNoGravity = false; a.speed = 48;}} invoker.backfire = 0;}
	
	action void FireAlt()
	{double ying, yang; actor bolt; invoker.UpCost(2);if(!invoker.DepleteAmmo(false))
	{player.SetPSprite(PSP_WEAPON, invoker.ResolveState("Oops")); return;}
	A_StartSound("superplasma/altfire"); for(uint i; i < 48; i++) 
	{ying = frandom[Plas](-30, 30); yang = frandom[Plas](-7.5, 7.5);
	bolt = WeponProj("PewPewBolt", (ying, yang), (0, 0), false);
	if(bolt){bolt.vel *= 3.5; bolt.bNoGravity = false;}}
	WeponProj("SuperPewBolt"); invoker.backfire = 0; A_Recoil(7.5);}
	
	States
	{Spawn:		SUP3 A -1; Stop;
	Ready:		SPLS A 1 A_WeaponReady(); Loop;
	Select:		SPLS A 1 A_Raise(4); Loop;
	Deselect:	SPLS A 1 A_Lower(8); Loop;
	Fire:		SPLS K 4 Bright {YoyoFunc(); 
				A_StartSound("superplasma/idle", CHAN_5, CHANF_LOOP, 0.45);} 
				SPLS JD 3 Bright;
	FireLoop:	SPLS CB 2 Bright YoyoFunc(); Loop;
	PostFire:	SPLS CBCB 3 Bright; SPLS MLML 4 Bright; 
				SPLS A 0 A_StopSound(CHAN_5); Goto Ready;
	AltFire:	SPLS A 0 A_StartSound("superplasma/idle", CHAN_5, CHANF_LOOP, 0.75);
	AltLoop:	SPLS ML 7 Bright AltfireCharge(7); SPLS A 0 A_Refire("AltLoop");
				SPLS A 0 CanAltfire();
	Oops:		SPLS K 3 Bright {Whoops(random(36, 72)); A_StopSound(CHAN_5);}
				SPLS I 2 Bright; SPLS A 30; Goto Ready;
	BigBolt:	SPLS K 5 Bright FireAlt(); SPLS I 5 Bright; SPLS A 5; 
				SPLS A 0 A_StopSound(CHAN_5); Goto Ready;}
}
