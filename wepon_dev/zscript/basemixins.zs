/*WOO YEAH QUATERNION BLACK MAGIC

Also, I know it's not the most kosher thing in the world to plop fifteen-plus
functions into a base class, but vanilla UZDoom kinda does this too. That, and
I'd rather not copy-paste this shit for anything adonn uses for their respective
weaponry. Scales better in the long run, too.*/

class BaseWepon: Weapon 
{
	static double, double RandomizerCrap(double minnie, double mickey)
	{double temp1, temp2;
		temp1 = frandom(minnie, mickey); temp2 = frandom(minnie, mickey);
	return temp1, temp2;}
	
	static vector2 Vec2Aim(vector2 vec)
	{vector2 temp; 
		temp.x = frandom(-vec.x, vec.x); temp.y = frandom(-vec.y, vec.y); 
	return temp;}
	
	static vector2 RanXY(double x, double y, double yDiv)
	{double temp1, temp2; [temp1, temp2] = RandomizerCrap(x, y);
	vector2 result = (temp1, (temp2 / yDiv)); return result;}
	
	//pDir: Player Direction, amplitude: Random Devation Mode
	static double, double GimbalUnlocker(quat pDir, vector2 direction,
										bool amplitude = false)
	{	quat 	offy; 	double yin, yan; vector2 temp;
		vector3 up =	(0, 0, 1), forwards =	(1, 0, 0),
				right =	(0, -1, 0), finalDir;
		
		if(amplitude) {temp = Vec2Aim(direction);
		offy = (Quat.AxisAngle(up, temp.x)) * (Quat.AxisAngle(right, temp.y));}
		else {offy = (Quat.AxisAngle(up, direction.x)) * 
					 (Quat.AxisAngle(right, direction.y));}
		
		finalDir = ((pDir * offy) * forwards).Unit();
		yin = atan2(finalDir.y, finalDir.x); 
		yan = -asin(clamp(finalDir.z, -1.0, 1.0)); return yin, yan;}
	
	quat playerAngle; double yin2, yan2; vector3 offThree;
	
	//num follows A_FireBullets convention, hence the signed int
	action void WeponBoolet(int num, uint dam, uint modu, vector2 deviation, 
							bool nomAmmo = false, uint ammoNom = 0, bool explicit = false, 
							bool soundy = false, vector2 offsets = (0, 0))
	{if(nomAmmo && !invoker.DepleteAmmo(invoker.bAltFire, true, ammoNom)) {return;}
		if(soundy) {A_StartSound(player.ReadyWeapon.AttackSound, CHAN_WEAPON);}
		uint iterations = abs(num); if(num == 0) {iterations = 1;}
		double autoPitch = BulletSlope();
		invoker.playerAngle = Quat.FromAngles(angle, autoPitch, roll);
		bool firstOne = ((num == 1) && (self.Player.refire == 0)), applyS;
		for(uint i = 0; i < iterations; i++) {int finalDam = dam * random(1, modu);
		applyS = (!firstOne && (num != 0) && !explicit); if(firstOne) {deviation = (0, 0);}
		[invoker.yin2, invoker.yan2] = 
		GimbalUnlocker(invoker.playerAngle, deviation, applyS);
		LineAttack(invoker.yin2, PLAYERMISSILERANGE, invoker.yan2, finalDam,
				'Hitscan', "BulletPuff", 0, null, offsets.y, 0, offsets.x);}
	}

	bool LimitCheck(uint size, uint limit)
	{if(limit == 0) {return true;} else {return size <= limit;}}
	
	vector3 APUnit(double ang, double pit)
	{vector2 plane = AngleToVector(ang);
		return (plane.x, plane.y, sin(-pit));}

	action void WeponPierce(uint dam = 5, uint limit = 3,
	double maxDist = 8192,  vector2 stangle = (0, 0), vector2 offset = (0, 0), 
	class<actor> pSpawn = "BulletPuff", bool wallSpawn = true)
	{double budget = maxDist; Array<Actor> monters; FLineTraceData datum;
		vector3 orPos = (pos.x, pos.y, pos.z + player.viewz - pos.z), pomp; 
		bool hit, realHit; double autoPitch = BulletSlope();
		invoker.playerAngle = Quat.FromAngles(angle, autoPitch, roll);
		[invoker.yin2, invoker.yan2] = 
			GimbalUnlocker(invoker.playerAngle, stangle, false);
		vector3 hump = invoker.APUnit(invoker.yin2, invoker.yan2);
		do 
			{realHit = false; hit = LineTrace(invoker.yin2, budget, invoker.yan2, 
                TRF_ABSPOSITION, orPos.z, orPos.x, orPos.y, datum);
			if (datum.HitType == TRACE_HitNone) {break;}
				pomp = datum.HitLocation;
			if(datum.HitType == TRACE_HitWall)
				{if(!wallSpawn) {break;} vector3 norm = pomp - (hump);
					SpawnPuff(pSpawn, norm, invoker.angle, 0, 1); 
						break;} let pointy = datum.HitActor; 
			if(!pointy){break;} if(monters.Find(pointy) == monters.Size() && 
			invoker.LimitCheck(monters.Size(), limit)) 
				{realHit = true; pointy.DamageMobj(self, self, dam, 'Hitscan'); 
					monters.Push(pointy); pointy.SpawnBlood(pomp, angle, dam);
					orPos = pomp + (hump * 2); budget -= datum.Distance;
					SpawnPuff(pSpawn, pomp, invoker.angle, 0, 1);}
			else 
				{realHit = true; budget -= datum.Distance; 
					orPos = pomp + (hump * 2);}
		} while(realHit && budget > 0)
	}
	
	action void WeponPBoolet(uint dam = 5, uint num = 1, uint modu = 1,
	uint limit = 3,  double maxDist = 8192, vector2 stangle = (0, 0),
	vector2 offset = (0, 0), bool eat = false, uint ammoEat = 1, 
	bool soundo = true, class<actor> pSpawn = "BulletPuff")
	{if(eat && !invoker.DepleteAmmo(invoker.bAltFire, true, ammoEat)) {return;}
		if(soundo) {A_StartSound(player.ReadyWeapon.AttackSound, CHAN_WEAPON);}
		uint damResult; vector2 aim; for(uint i; i < num; i++)
			{damResult = dam * random(1, modu); aim = Vec2Aim(stangle);
			WeponPierce(damResult, limit, maxDist, aim, offset, pSpawn);}
	}
	
	action Actor, Actor WeponProj(class<Actor> flingy, vector2 eulerAng = (0, 0),
	vector2 offsets = (0, 0), bool nomAmmo = true)
	{Actor misl1, misl2; double tangle, titch;
		invoker.playerAngle = Quat.FromAngles(angle, pitch, roll);
		[invoker.yin2, invoker.yan2] = 
		GimbalUnlocker(invoker.playerAngle, eulerAng, false);
		tangle = DeltaAngle(angle, invoker.yin2);
		titch = DeltaAngle(pitch, invoker.yan2);
		[misl1, misl2] = A_FireProjectile(flingy, tangle, nomAmmo, offsets.x,
										  offsets.y, FPF_NOAUTOAIM, titch);
		if(misl1 && misl2) {return misl1, misl2;} 
		else if (misl2) {return null, misl2;}
		return null, null;}
	
	static uint, uint GetBuckshot(uint budget, uint maxSlugs)
	{uint hatValue, s, b = 0; while(budget != 0)
	{uint hatValue = random(0, 4); if(hatValue == 4 && s < maxSlugs && budget > 2) 
									{s++; budget -= 3;} else {b++; budget -= 1;}}
	return s, b;}
	
	//True is for slugs, false for buckshot.
	static uint pCalc(bool typeB)
	{uint hatValue, result = 0; if(typeB) {result = random(15, 20);
	hatValue = random(0, 2); if(hatValue == 0) {result *= 2;}}
	else {result = random(5, 10);} return result;}
	
	static int randomBFG(uint rmin, uint rmax, uint count)
	{uint output, rint = 0; for (uint j = 0; j < count; j++)
	{rint = random(rmin, rmax); output += rint;} return output;}
	
	action void FireBetaBolt(uint chance)
	{vector2 stank; uint rngVal = random(0, chance);
	if(rngVal == 0){stank = Vec2Aim((12.5, 7.5));
	WeponProj("BFGBolt2", (stank.x, stank.y), (0, 0), false);}
	else {stank = Vec2Aim((32.5, 9.));
	WeponProj("BFGBolt1", (stank.x, stank.y), (0, 0), false);}}
	
	action void InstantlyPukeBolts(uint c, uint bolts)
	{for(uint i = 0; i < bolts; i++){FireBetaBolt(c);}}
	
	action void FireWeponBFGRails(int rayAmount, double maxAngle)
	{uint min = 1, max = 8, count = 16, damBoy; double rayAngle;
		if(stronkBFG) {min = 4; max = 12; count = 20;}
		A_BFGSound(); A_GunFlash(); for(int i = 0; i < rayAmount; i++)
		{damBoy = randomBFG(min, max, count);
			rayAngle = (-(maxAngle/2) + ((maxAngle * i) / rayAmount));
		WeponPierce(damBoy, 0, PLAYERMISSILERANGE, (rayAngle, 0),
			pSpawn: "Flashy", wallSpawn: false);}
	}
}