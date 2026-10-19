/*I don't know why UZDoom doesn't let people just forcefully replace vanilla
ammotypes. Also, for the record, try to keep all your lines of code WITHIN 80
collums. Makes stuff a lot more readable when you come back about half a year
later and you're wondering why some of your shit isn't working. Not that it helps
much with my habit of stuffing code as densely as possible... but eh, it's the
thought that counts.*/

class NewClip : Ammo
{Default 
	{Inventory.Amount 10; Inventory.MaxAmount 300; Ammo.BackpackAmount 20;
	Ammo.BackpackMaxAmount 750; Inventory.Icon "AMMOA0"; Inventory.PickupMessage "$GOTCLIP";}
	States { Spawn: CLIP A -1; Stop; }
}
class JankClip : NewClip 
{Default {Inventory.Amount 40; Inventory.PickupMessage "$GOTCLIPBOX";}
States {Spawn: AMMO A -1; Stop;}}

class NewShell : Ammo
{Default 
	{Inventory.Amount 4; Inventory.MaxAmount 64; Ammo.BackpackAmount 8; 
	Ammo.BackpackMaxAmount 160; Inventory.Icon "SBOXA0"; 
	Inventory.PickupMessage "$GOTSHELLS";} States { Spawn: SHEL A -1; Stop; }
}
class JankShell : NewShell 
{Default {Inventory.Amount 16; Inventory.PickupMessage "$GOTSHELLBOX";} 
States {Spawn: SBOX A -1; Stop;}}

class NewRocketAmmo: Ammo
{Default 
	{Inventory.Amount 1; Inventory.MaxAmount 48; Ammo.BackpackAmount 2; 
	Ammo.BackpackMaxAmount 120; Inventory.Icon "BROKA0"; 
	Inventory.PickupMessage "$GOTROCKET";} States { Spawn: ROCK A -1; Stop; }
}
class JankRocket : NewRocketAmmo 
{Default {Inventory.Amount 4; Inventory.PickupMessage "$GOTROCKBOX"; 
-INVENTORY.IGNORESKILL} States {Spawn: BROK A -1; Stop;}}

class NewCell: Ammo
{Default 
	{Inventory.Amount 20; Inventory.MaxAmount 200; Ammo.BackpackAmount 40; 
	Ammo.BackpackMaxAmount 500; Inventory.Icon "CELPA0"; 
	Inventory.PickupMessage "$GOTCELL";} States { Spawn: CELL A -1; Stop; }
}
class JankCell : NewCell 
{Default {Inventory.Amount 80; Inventory.PickupMessage "$GOTCELLBOX";} 
States {Spawn: CELP A -1; Stop;}}

class NewFuel: Ammo
{Default 
	{Inventory.Amount 10; Inventory.MaxAmount 250; Ammo.BackpackAmount 10; 
	Ammo.BackpackMaxAmount 600; Inventory.Icon "FTNKA0"; 
	Inventory.PickupMessage "$ID24_GOTFUELCAN";} States {Spawn: FCPU A -1; Stop;}
}
class JankFuel : NewFuel 
{Default {Inventory.Amount 50; Inventory.PickupMessage "$ID24_GOTFUELTANK";} 
States {Spawn: FTNK A -1; Stop; }}

class BFGCell : Ammo
{ Default
	{ Inventory.PickupMessage "$GOTBFGCORE"; Inventory.Icon "BFGCA0"; 
	Inventory.Amount 1; Inventory.MaxAmount 2; Ammo.BackpackMaxAmount 6; 
	+INVENTORY.IGNORESKILL} States { Spawn: BFGC A -1; Stop; }
}
class DiabloFuel : Ammo
{ Default
	{ Inventory.PickupMessage "$GOTDIABLO"; Inventory.Icon "DIABA0"; 
	Inventory.Amount 5; Inventory.MaxAmount 25; Ammo.BackpackMaxAmount 75; 
	+INVENTORY.IGNORESKILL} States { Spawn: DIAB A -1; Stop; }
}

class NewPack : BackpackItem replaces Backpack 
{Default {Height 26; Inventory.PickupMessage "$GOTBACKPACK";} 
States {Spawn: BPAK A -1; Stop;}}
