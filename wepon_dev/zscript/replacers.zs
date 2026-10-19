class ReplaceVanillaActors : EventHandler
{
	override void CheckReplacement(ReplaceEvent e)
	{ //Thanks for letting me steal your spawner code, Kinsie
		static const string oldOnes[] =
		{"Clip", "Shell", "RocketAmmo", "Cell", "ID24Fuel", 
		"ClipBox", "ShellBox", "RocketBox", "CellPack", "ID24FuelTank",
		"Pistol", "Chainsaw", "Shotgun", "SuperShotgun", 
		"Chaingun", "RocketLauncher", "PlasmaRifle",
		"BFG9000", "ID24Incinerator", "ID24CalamityBlade"};
		static const string newOnes[] = 
		{"NewClip", "NewShell", "NewRocketAmmo", "NewCell", "NewFuel", 
		"JankClip", "JankShell", "JankRocket", "JankCell", "JankFuel",
		"DualPistols", "Vroom", "SemiAutoShotty", "SuperDeluxeShotgun", 
		"MoreDakka", "ExplosiveOrdinance", "EnergyPewPewWeapon", 
		"BigFuckingGun", "FLAMETHROWAH", "HotDamn"};
		for(uint i; i < oldOnes.size(); i++)
		{if(e.Replacee == oldOnes[i]) {e.Replacement = newOnes[i];}}
	}
}

class BFGCellHandler: EventHandler
{vector3 wow; vector2 woah; Actor a; string packName;
	override void WorldThingSpawned(WorldEvent e)
	{packName = e.thing.GetClassName(); bool isReplaceable = 
		(packName == "JankCell" || packName == "JankFuel");
		if(isReplaceable && cellsystem) {int temp = bfgcellchance; if(temp == 0)
		{temp = 2;} if(random(0, temp - 1) > 0) {woah.x = random(-24, 24); 
		woah.y = random(-24, 24); wow = e.thing.Vec3Offset(woah.x, woah.y, 1, false);
		class<actor> s = (packName == "JankCell")? "BFGCell":"DiabloFuel"; 
		a = e.thing.Spawn(s, wow, NO_REPLACE);}}}
}

class id24SpawnLogic: EventHandler
{
	bool bl; vector3 wow; vector2 woah; Actor ac; string s, r, t;
	static const string pStr[] = {"NewCell", "JankCell", "EnergyPewPewWeapon", "BigFuckingGun"};
	static const string fStr[] = {"NewFuel", "JankFuel", "FLAMETHROWAH", "HotDamn"};
	string GrabName(bool c, string a, string b){return c? a: b;}
	override void WorldThingSpawned(WorldEvent e)
	{
		if(!id24crap){return;}  let h = id24Handler.Yoink(); bl = h.IsID24(); for(uint i; i < 4; i++)
		{s = e.thing.GetClassName();	
		r = GrabName(!bl, pStr[i], fStr[i]);
		t = GrabName(bl, pStr[i], fStr[i]); if(s == r)
		{int temp = cellfuelchance; 
		if(temp == 0) {temp = 2;} 
		if(random(0, cellfuelchance - 1) > 0)
		{woah.x = random(-24, 24); woah.y = random(-24, 24); 
		wow = e.thing.Vec3Offset(woah.x, woah.y, 1, false); 
		ac = e.thing.Spawn(t, wow, NO_REPLACE);}}}
	}
}
