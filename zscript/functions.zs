// general functions that are nice to have
struct HHFunc
{
	// This looks for any HHelmetWorn, not HHelmet
	static HDArmourWorn FindHelmet(Actor actor)
	{
		return HDArmourWorn(actor.FindInventory("HHelmetWorn", true));
	}

	static bool CheckForArmour(Actor actor)
	{
		for (Inventory i = actor.Inv; i; i = i.Inv)
		{
			HDDamageHandler hdh = HDDamageHandler(i);
			if (!hdh) continue;

			string arm = hdh.GetClassName();
			if (IsWornArmour(arm)) return true;
		}
		return false;
	}

	static bool IsWornArmour(string name)
	{
		ThinkerIterator ti = ThinkerIterator.Create("HHArmourType");

		// Is this a valid armour name?
		HHArmourType hhat;
		while (hhat = HHArmourType(ti.next()))
		{
			if (name == hhat.ArmourWornName) return true;
		}

		return false;
	}

	static bool IsArmour(string name)
	{
		ThinkerIterator ti = ThinkerIterator.Create("HHArmourType");

		// Is this a valid armour name?
		HHArmourType hhat;
		while (hhat = HHArmourType(ti.next()))
		{
			if (name == hhat.ArmourName) return true;
		}

		return false;
	}
}

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

// this is cursed, but gzdoom doesn't let me store structs in dynamic arrays :[
class FiremodeInfo
{
	int id;
	array<string> img;
	array<string> bitwise;
}
