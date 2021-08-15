// general functions that are nice to have
struct HHFunc {
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

		ThinkerIterator ti = ThinkerIterator.Create("HHArmourType");

		// Is this a valid armour name?
		HHArmourType hhat;
		while (hhat = HHArmourType(ti.next())) {
			if (name == hhat.armour_name) {
				return true;
			}
		}

		return false;
	}
}

// This is a class intended for defining armour types :]
class HHArmourType : Thinker abstract {
	string armour_name;

	virtual ui void DrawArmour(
		HDStatusBar sb,
		HDPickup hp,
		int hdflags,
		int gzflags
	) {} // This should be overridden to draw the armour stuff
}
