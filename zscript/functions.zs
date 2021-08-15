// general functions that are nice to have
struct HHMath {
	static bool CheckForArmour(Actor actor) {
		for (Inventory i = actor.Inv; i; i = i.Inv) {
			HDDamageHandler hdh = HDDamageHandler(i);
			if (hdh) {
				string arm = hdh.GetClassName();
				if (IsArmour(arm)) {
					return true;
				}
			}
		}
		return false;
	}

	static bool IsArmour(string name) {
		array<string> armour_names;

		// Get the lumps that start with "hh_armourlist"
		int lump = -1;
		while ((lump = Wads.FindLump("hh_armourlist", lump + 1)) != -1) {
			string s = Wads.ReadLump(lump);
			s.split(armour_names, "\n");
		}

		// Is this a valid armour name?
		for (int i = 0; i < armour_names.Size(); i++) {
			if (name == armour_names[i]) {
				return true;
			}
		}

		return false;
	}
}
