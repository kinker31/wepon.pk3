class Freechmen : DoomPlayer
{
	Default
	{Player.DisplayName "WeponGuy"; Player.StartItem "DualPistols";  
	Player.StartItem "NewClip", 80; Player.StartItem "PunchO";
	DamageFactor "FireWow", 0.25; Player.StartItem "SemiAutoClip", 12; 
	Player.StartItem "DeluxeClip", 4;}
}

class SmolRocket : PlayerBoom 
	{Default {Radius 6; Speed 40; Mass 25; ExplosionRadius 96; -RANDOMIZE;
		ExplosionDamage 64; Gravity 2; Damage 4; XScale 0.5; YScale 0.5; 
		Obituary "$SHOTROCKOUCH"; -NOGRAVITY;}}
