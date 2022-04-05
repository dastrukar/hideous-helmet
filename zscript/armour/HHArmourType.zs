// This is a class intended for defining armour types :]
class HHArmourType : Thinker abstract
{
	string ArmourName;
	string ArmourWornname;

	virtual ui void DrawArmour(
		HDStatusBar sb,
		HDPickup hp,
		int hdFlags,
		int gzFlags
	) {} // This should be overridden to draw the armour stuff
}
