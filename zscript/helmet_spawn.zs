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
	override void WorldLoaded(WorldEvent e) {
		New("HHSpawnType_Default");
	}

	override void WorldThingSpawned(WorldEvent e) {
		if(!e.Thing) return;
		let T = e.Thing;

		// Find anything inheriting from HHSpawnType and use it :]
		ThinkerIterator ti = ThinkerIterator.Create("HHSpawnType");

		HHSpawnType hhst;
		while (hhst = HHSpawnType(ti.next())) {
			if (hhst.CheckConditions(T, level.time)) {
				hhst.SpawnHelmet(T);
				return;
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

class HHSpawnType : Thinker abstract {
	virtual bool CheckConditions(Actor T, int time) {
		return false;
	}

	virtual void SpawnHelmet(Actor T) {}
}

// If you want to override the default spawn type, just use a ThinkerIterator and destroy this
class HHSpawnType_Default : HHSpawnType {
	override bool CheckConditions(Actor T, int time) {
		bool is_helmetman = (
			(
				ZombieShotgunner(T) &&
				ZombieShotgunner(T).wep == -1 &&
				FRandom(0, 1) <= hh_jackbootspawn
			) || (
				HDOperator(T) &&
				FRandom(0, 1) <= hh_marinespawn
			)
		);
		bool is_armour = (
			time < 2 &&
			HHFunc.IsArmour(T.GetClassName()) &&
			FRandom(0, 1) <= hh_armourspawn
		);

		return (is_helmetman || is_armour);
	}

	override void SpawnHelmet(Actor T) {
		if (
			ZombieShotgunner(T) ||
			HDOperator(T)
		) {
			T.GiveInventory("HasHelmet", 1);
			if (hh_enemywearshelmet) {
				T.GiveInventory("HHelmetWorn", 1);
				HHelmetWorn wrn = HHelmetWorn(T.FindInventory("HHelmetWorn"));
				wrn.durability = Random(hh_d_random_min, hh_d_random_max);

				if (hh_debug) {
					Console.PrintF("Gave helmet to "..T.GetClassName().." with durability "..wrn.durability);
				}
			}
		} else {
			// Armoru
			HHelmetSpawner.SummonHelmet(HHCONST_HUDHELMET, (T.pos.x, T.pos.y, T.pos.z));
		}
	}
}
