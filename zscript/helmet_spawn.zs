// Some code borrowed from Ugly as Sin by Caligari87.

class HasHelmet : InventoryFlag{
	int durability;

	override void Tick() {
		// Drop helmet if dead
		if (Owner && Owner.health < 1) {
			// If has helmet, use that for durability
			Inventory helm = Owner.FindInventory("HHelmetWorn");
			if (helm) {
				durability = HHelmetWorn(helm).durability;
			}

			if (durability > 0) {
				Vector3 t_pos = (Owner.pos.x, Owner.pos.y, Owner.pos.z + 5);
				HHelmetSpawner.SummonHelmet(durability, t_pos);
			}

			Destroy();
		}
	}
}

class HHelmetSpawner : EventHandler {
	// Armour should come with helmets
	override void WorldThingSpawned(WorldEvent e) {
		if(!e.Thing) return;
		let T = e.Thing;
		
		bool is_jackboot = (
			(T is "HideousShotgunGuy") &&
			HideousShotgunGuy(T).wep == -1
		);

		bool is_marine = (T is "HDMarine");

		Vector3 t_pos = (T.pos.x, T.pos.y, T.pos.z + 5);
		if (
			Level.maptime < 2 &&
			T is "HDArmour" &&
			FRandom(0,1) <= hh_armourspawn
		) {
			// Armour
			// Just has a chance to spawn with a helmet
			SummonHelmet(HHCONST_HUDHELMET, t_pos);
		} else if (
			(is_jackboot && FRandom(0,1) <= hh_jackbootspawn) ||
			(is_marine && FRandom(0,1) <= hh_marinespawn)
		) {
			// Jackboots and marines
			// Now determined on spawn instead of on death!
			T.GiveInventory("HasHelmet", 1);

			// Wear helmet?
			if (hh_enemywearshelmet) {
				T.GiveInventory("HHelmetWorn", 1);
				HHelmetWorn wrn = HHelmetWorn(T.FindInventory("HHelmetWorn"));
				wrn.durability = Random(hh_d_random_min, hh_d_random_max);

				if (hh_debug) {
					Console.PrintF("Gave helmet to "..T.GetClassName().." with durability "..wrn.durability);
				}
			} else {
				HasHelmet helm = HasHelmet(T.FindInventory("HasHelmet"));
				helm.durability = Random(hh_d_random_min, hh_d_random_max);
			}
		}
	}

	// Moved to a function for convenience
	static void SummonHelmet(int durability, Vector3 pos) {
		HHelmet helm = HHelmet(Actor.Spawn("HHelmet", pos, ALLOW_REPLACE));

		helm.vel.x += frandom(-2,2);
		helm.vel.y += frandom(-2,2);
		helm.vel.z += frandom(1,3);

		helm.mags.clear();
		helm.mags.push(durability);
		helm.syncamount();
	}
}
