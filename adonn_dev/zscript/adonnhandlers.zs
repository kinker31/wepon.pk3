class AdonnHand : EventHandler
{const MAX_SPAWN = 24.0;
	void RepoLog(ReplaceEvent a, class<actor> thingOne, class<actor> thingTwo, 
					uint thresh, bool thingOn)
	{if(!thingOn){return;} bool temp = (uint(random[HandlerRNG](0, 255)) < thresh);
	if(a.Replacee == thingOne && temp) {a.Replacement = thingTwo;}}
	
	void RepoSpawn(WorldEvent a, class<actor> thingOne, class<actor> thingTwo, 
					uint thresh, bool thingOn)
	{if(!thingOn){return;} bool temp = (uint(random[HandlerRNG](0, 255)) < thresh);
		string tempA = a.thing.GetClassName(), tempB = thingOne.GetClassName();
		vector3 finalV; vector2 tempV; if((tempA == tempB) && temp)
		{tempV = BaseWepon.RanXY(-MAX_SPAWN, MAX_SPAWN, 1.0);
		finalV = a.thing.Vec3Offset(tempV.x, tempV.y, 1.0);
		actor dummy = a.thing.Spawn(thingTwo, finalV, NO_REPLACE);}
	}
	
	override void CheckReplacement(ReplaceEvent e)
	{uint switchVal, randomNumber, percentChance[4], chanceswitch[4] = {0},
		cvarswitch[] = {blurspeed, soulaegis, invulnquad, megaultra}; 
		bool spawnSp[4] = {0}; if(e.Replacee == "Vroom") //Chainsaw Replacement Logic
		{switch(replacechainsaw) {case 0: break;
		case 1: e.Replacement = "HoovyLauncher"; break;
		case 2: e.Replacement = "HoovyBFG"; break;
		case 3: e.Replacement = "HoovySSG"; break;}}
		
		//Sphere Replacement Loop(s)
		for(int i = 0; i < 4; i++)
		{switch(cvarswitch[i])
		   {case 0:  percentChance[i]  = 0;		break;
			case 1:  percentChance[i]  = 256;	break;
			case 2:  percentChance[i]  = 128;	break;
			case 3:  percentChance[i]  = 192; 	break;
			case 4:  percentChance[i]  = 64;	break;
			default: percentChance[i]  = 256;	break;}
			spawnSp[i] = percentChance[i] != 0;}
		
		//Other Stuff
		RepoLog(e,"BlurSphere",	"SupaSpeedSphere",	percentChance[0], spawnSp[0]);
		RepoLog(e,"SoulSphere",	"HalfDamageSphere",	percentChance[1], spawnSp[1]);
		RepoLog(e,"InvulnerabilitySphere",	"QuadSphere",	percentChance[2],	spawnSp[2]);
		RepoLog(e,"MegaSphere",	"UltraSphere",	percentChance[3],	spawnSp[3]);
		RepoLog(e,"GreenArmor", "GoldArmor",	127, altarmor);
		RepoLog(e,"BlueArmor", 	"DemonArmor",	192, superguns);
		//RepoLog(e,"Berserk", "FistPack", 192, fistpack_c);
	}
	
	override void WorldThingSpawned(WorldEvent e)
	{uint chance; //Golden Pistol Spawning
		switch(goldenrarity)
		{case 0: chance = 8; break; case 1: chance = 16; break;
		case 2: chance = 32; break; case 3: chance = 64; break;}
		RepoSpawn(e, "JankCell", "GoldBullet", chance, goldenpistol);
		RepoSpawn(e, "BigFuckingGun", "GoldPistol", chance, goldenpistol);
		RepoSpawn(e,"SuperDeluxeShotgun",	"UltraShotgun",		32, superguns);
		RepoSpawn(e,"MoreDakka", 		"YetMoreDakka", 	24, superguns);
		RepoSpawn(e,"ExplosiveOrdinance",	"BoomstickTwo",		16, superguns);
		RepoSpawn(e,"EnergyPewPewWeapon",	"SuperPewPewWeapon",	12, superguns);
		RepoSpawn(e,"FLAMETHROWAH", 	"SupaThrowaa", 		8, superguns);
	}
}

