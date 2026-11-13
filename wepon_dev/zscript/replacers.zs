class ReplaceVanillaActors : EventHandler
{
	override void CheckReplacement(ReplaceEvent e)
	{ //This is painfully janky code, but sometimes one must prioritize UZDoom's happiness over his own
		if(e.Replacee == 'Clip')  { e.Replacement = 'NewClip';  return; }
		if(e.Replacee == 'Shell') { e.Replacement = 'NewShell'; return; }
		if(e.Replacee == 'RocketAmmo')  { e.Replacement = 'NewRocketAmmo';  return; }
		if(e.Replacee == 'Cell') { e.Replacement = 'NewCell'; return; }
		if(e.Replacee == 'ID24Fuel') { e.Replacement = 'NewFuel'; return; }
		if(e.Replacee == 'ClipBox')  { e.Replacement = 'JankClip';  return; }
		if(e.Replacee == 'ShellBox') { e.Replacement = 'JankShell'; return; }
		if(e.Replacee == 'RocketBox')  { e.Replacement = 'JankRocket';  return; }
		if(e.Replacee == 'CellPack') { e.Replacement = 'JankCell'; return; }
		if(e.Replacee == 'ID24FuelTank')  { e.Replacement = 'JankFuel';  return; }
		if(e.Replacee == 'Pistol') { e.Replacement = 'DualPistols'; return; }
		if(e.Replacee == 'Chainsaw')  { e.Replacement = 'Vroom';  return; }
		if(e.Replacee == 'Shotgun') { e.Replacement = 'SemiAutoShotty'; return; }
		if(e.Replacee == 'SuperShotgun')  { e.Replacement = 'SuperDeluxeShotgun';  return; }
		if(e.Replacee == 'Chaingun') { e.Replacement = 'MoreDakka'; return; }
		if(e.Replacee == 'RocketLauncher') { e.Replacement = 'ExplosiveOrdinance'; return; }
		if(e.Replacee == 'PlasmaRifle')  { e.Replacement = 'EnergyPewPewWeapon';  return; }
		if(e.Replacee == 'BFG9000') { e.Replacement = 'BigFuckingGun'; return; }
		if(e.Replacee == 'ID24Incinerator')  { e.Replacement = 'FLAMETHROWAH';  return; }
		if(e.Replacee == 'ID24CalamityBlade') { e.Replacement = 'HotDamn'; return; }
	}
}

class WeponHandler: EventHandler
{vector3 wow; Actor a; string s, r, t; bool bl; id24Handler yoink;
	static const string pStr[] = {"NewCell", "JankCell", "EnergyPewPewWeapon", "BigFuckingGun"};
	static const string fStr[] = {"NewFuel", "JankFuel", "FLAMETHROWAH", "HotDamn"};
	
	string GrabName(bool c, string a, string b){return c? a: b;}
	override void OnRegister() {yoink = id24Handler.Yoink(); bl = yoink.IsID24();}
	
	vector3 Spawnbo(WorldEvent e, double hOff = 1)
	{vector3 wump; vector2 woah;
		woah.x = random(-24, 24); woah.y = random(-24, 24); 
		wump = e.thing.Vec3Offset(woah.x, woah.y, hOff, false);
	return wump;}
	
	void BFGLogic(WorldEvent e)
	{if(!cellsystem || !e.thing) { return; }
        if(!(e.thing is 'JankCell' || e.thing is 'JankFuel')) { return; }
		 int temp = (bfgcellchance == 0)? 2 : bfgcellchance;
		if(random(0, temp - 1) == 0) {return;}
		class<actor> s = (e.thing is 'JankCell')? "BFGCell":"DiabloFuel";
		a = e.thing.Spawn(s, wow, NO_REPLACE);
	}
	
	void id24Logic(WorldEvent e)
	{s = e.thing.GetClassName(); wow = Spawnbo(e);
		for(uint i; i < 4; i++) {r = GrabName(!bl, pStr[i], fStr[i]);
			t = GrabName(bl, pStr[i], fStr[i]); if(s != r) {continue;}
			int temp = (cellfuelchance == 0)? 2 : cellfuelchance;
			if(random(0, cellfuelchance - 1) == 0) {return;}
			a = e.thing.Spawn(t, wow, NO_REPLACE);}
	}
	
	override void WorldThingSpawned(WorldEvent e)
	{BFGLogic(e); id24Logic(e);}
}
