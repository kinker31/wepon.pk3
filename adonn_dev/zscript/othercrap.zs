extend class Freechmen {Default {Player.StartItem "PunchTwo";}}
class GoldBullet : Ammo
{Default {Inventory.Amount 1; Inventory.MaxAmount 3; Ammo.BackpackMaxAmount 6;
		+INVENTORY.IGNORESKILL Inventory.Icon "GCLPA0"; Inventory.PickupMessage "$GOTGOLDBULLET";}
	States {Spawn: GCLP A -1; Stop;}
}

class QuadDamage : PowerDamage 
{ Default { powerup.duration -30; damagefactor "normal", 4; inventory.icon "QDAMA0";} }
class SupaSpeed: PowerSpeed 
{ Default { powerup.duration -60; Speed 1.75; inventory.icon "SPEDA0";} }
class HalfDamage : PowerProtection 
{ Default { powerup.duration -45; damageFactor "Normal", 0.5; inventory.icon "HLFDA0";} }

class QuadSphere: PowerupGiver
{Default{+COUNTITEM; +VISIBILITYPULSE; +INVENTORY.AUTOACTIVATE; +INVENTORY.ALWAYSPICKUP; 
		+INVENTORY.BIGPOWERUP; Inventory.MaxAmount 0; Powerup.Type "QuadDamage"; Inventory.PickupMessage "$QDAM";}
States {Spawn: QDAM ABCDCBA 3 Bright; Loop;}}
class HalfDamageSphere: PowerupGiver
{Default{+COUNTITEM; +VISIBILITYPULSE; +INVENTORY.AUTOACTIVATE; +INVENTORY.ALWAYSPICKUP; 
		+INVENTORY.BIGPOWERUP; Inventory.MaxAmount 0; Powerup.Type "HalfDamage"; Inventory.PickupMessage "$AGIS";}
States {Spawn: HLFD ABCDCBA 3 Bright; Loop;}}
class SupaSpeedSphere: PowerupGiver
{Default {+COUNTITEM; +VISIBILITYPULSE; +INVENTORY.AUTOACTIVATE; +INVENTORY.ALWAYSPICKUP;
		+INVENTORY.BIGPOWERUP; Inventory.MaxAmount 0; Powerup.Type "SupaSpeed"; Inventory.PickupMessage "$SPED";}
States {Spawn: SPED ABCDCBA 3 Bright; Loop;}}

class UltraHealth: Health {Default{+INVENTORY.ALWAYSPICKUP; Inventory.Amount 400; Inventory.MaxAmount 400;}}
class UltraArmor: DemonArmor {Default{Armor.SavePercent 75; Armor.SaveAmount 400;}}
class UltraSphere: CustomInventory
{
	Default {+COUNTITEM; +INVENTORY.ALWAYSPICKUP; +INVENTORY.ISHEALTH; +INVENTORY.ISARMOR; 
			Inventory.PickupMessage "$ULTRAS"; Inventory.PickupSound "misc/p_pkup"; Tag "$ULTRASTAG";}
	States	{Spawn:	ULTR ABCD 2 BRIGHT; Loop;
					Pickup:	TNT1 A 0 {A_GiveInventory("UltraArmor", 1);
					A_GiveInventory("UltraHealth", 1);} Stop;}
}

class GoldArmor: BasicArmorPickup 
{
	Default {Radius 20; Height 16; Inventory.Pickupmessage "$GOLDISHARMOR";
			Inventory.Icon "ARM3A0"; Armor.Savepercent 41.665; Armor.Saveamount 150;} 
	States{Spawn: ARM3 A 5; ARM3 B 5 Bright; Loop;}
}
class DemonArmor: BasicArmorPickup 
{
	Default{Radius 20; Height 16; Inventory.Pickupmessage "$DEMONARMOR"; 
			Inventory.Icon "ARM4A0"; Armor.Savepercent 75; Armor.Saveamount 400;}
	States{Spawn: ARM4 A 4; ARM4 B 4 Bright; Loop;}
}