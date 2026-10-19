/*	Thanks to PySpy's mod(s) for the... uh... 'gernerous donation'!
	
	Also, for the record, I know it's not quite kosher to put my
	miscellaneous scripts and actors in here, but what am I gonna do?
	Just make some file called 'misc_scripts.zs' and just do it like
	that? Like a SANE person?
	
	Who do you think I am?
*/

class id24Handler: StaticEventHandler 
{private bool id24; bool IsID24(){return id24;}
	override void OnEngineInitialize()
	{id24 = Wads.FindLump("ZZZGATE1", 0) != -1; Console.Printf("id24 Status: %u", id24);} 
	static id24Handler Yoink(){return id24Handler(id24Handler.Find("id24Handler"));}
}

class ItsAllCheese : Actor
{override void PostBeginPlay() {super.PostBeginPlay();
ThrowAbortException("I got the munchies, I eat my lunchies...");}}

class UZDoomDiesWhenItsKilled : StaticEventHandler
{
	ui uint uzdied_rand, temp, itr; ui bool weponIsGo;
	override void uiTick() 
	{if(gamestate == GS_LEVEL) {weponIsGo = true;}
	else if(gamestate == GS_FULLCONSOLE && weponIsGo)
	{weponIsGo = false; uzdied_rand = crandom(0, 4096);
		S_StartSound("world/vmabort", 0, CHAN_UI); if(uzdied_rand == 4096)
		{for(itr = 0; itr < 9; itr++) {console.printf(ULTRA_SECRET_TEXT[itr]);}}
			else {temp = uzdied_rand % 8;
			string holdem = StringTable.localize(string.format("$CRASH_%u", temp));
			console.printf(holdem); console.printf(StringTable.localize("$CRASH_WOW"));}
		}
	}
	
	//If you saw this in SLADE, no you didn't.
	static const string ULTRA_SECRET_TEXT[] =
	{
		"the heated intimacy came to an end",
		"there was a silence their thoughts",
		"could not drown. as the steam settled",
		"they rubbed their hands against the",
		"windows to see if anyone had caught",
		"them admist the act. but they were",
		"both too distracted by how moist their",
		"fingertips had now become, and how cold",
		"they felt against their tender skin."
	};
}