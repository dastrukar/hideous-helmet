// This is a class intended for defining armour types :]
class HHArmourType : Thinker abstract
{
	// These two functions are used in HHFunc.IsWornArmour() and HHFunc.IsArmour()
	virtual string GetName()
	{
		return "";
	}

	virtual string GetWornName()
	{
		return "";
	}

	// This is mainly done to hide the armour's durability value when you don't have a helmet
	virtual ui void DrawArmour(
		HDStatusBar sb,
		HDPickup hp,
		int hdFlags,
		int gzFlags
	) {}
}
