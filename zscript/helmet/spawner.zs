class HasHelmet : InventoryFlag
{
	override void Tick()
	{
		// Drop helmet if dead
		if (!Owner && Owner.health >= 1) return;

		// If has helmet, use that for durability
		int durability;
		Inventory helm = Owner.FindInventory("HHelmetWorn");
		if (helm) durability = HHelmetWorn(helm).Durability;

		if (durability > 0)
		{
			Vector3 tPos = (Owner.Pos.x, Owner.Pos.y, Owner.Pos.z + 5);
			HHelmetSpawner.SummonHelmet(durability, tPos);
		}

		Destroy();
	}
}

class HHelmetSpawner : EventHandler
{
	override void WorldLoaded(WorldEvent e)
	{
		New("HHSpawnType_Default");
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		if (!e.Thing) return;
		Actor T = e.Thing;

		// Find anything inheriting from HHSpawnType and use it :]
		ThinkerIterator ti = ThinkerIterator.Create("HHSpawnType");

		HHSpawnType hhst;
		while (hhst = HHSpawnType(ti.next()))
		{
			if (hhst.CheckConditions(T, Level.Time))
			{
				hhst.SpawnHelmet(T);
				return;
			}
		}
	}

	// Moved to a function for convenience
	static void SummonHelmet(int durability, Vector3 pos)
	{
		let helm = HHelmet(Actor.Spawn("HHelmet", pos, ALLOW_REPLACE));

		helm.Vel.x += FRandom(-2, 2);
		helm.Vel.y += FRandom(-2, 2);
		helm.Vel.z += FRandom(1, 3);

		helm.Mags.Clear();
		helm.Mags.Push(durability);
		helm.SyncAmount();
	}
}

class HHSpawnType : Thinker abstract
{
	// Used for checking if a helmet should spawn. If returns true, SpawnHelmet() will be called.
	virtual bool CheckConditions(Actor T, int time)
	{
		return false;
	}

	virtual void SpawnHelmet(Actor T) {}
}

// If you want to override the default spawn type, just use a ThinkerIterator and destroy this
class HHSpawnType_Default : HHSpawnType
{
	override bool CheckConditions(Actor T, int time)
	{
		bool isHelmetMan = (
			(
				ZombieShotgunner(T) &&
				ZombieShotgunner(T).Wep == -1 && // Are you a Helmeted Jackboot?
				FRandom(0, 1) <= hh_jackbootspawn
			) || (
				HDOperator(T) &&
				FRandom(0, 1) <= hh_marinespawn
			)
		);
		bool isArmour = (
			time < 2 &&
			HHFunc.IsArmour(T.GetClassName()) &&
			FRandom(0, 1) <= hh_armourspawn
		);

		return (isHelmetMan || isArmour);
	}

	override void SpawnHelmet(Actor T)
	{
		if (
			ZombieShotgunner(T) ||
			HDOperator(T)
		)
		{
			T.GiveInventory("HasHelmet", 1);
			if (hh_enemywearshelmet)
			{
				T.GiveInventory("HHelmetWorn", 1);
				HHelmetWorn wrn = HHelmetWorn(T.FindInventory("HHelmetWorn"));
				wrn.durability = Random(hh_d_random_min, hh_d_random_max);

				if (hh_debug) Console.PrintF("Gave helmet to "..T.GetClassName().." with durability "..wrn.durability);
			}
		}
		else
		{
			// Armoru
			HHelmetSpawner.SummonHelmet(HHCONST_HUDHELMET, T.Pos);
		}
	}
}
