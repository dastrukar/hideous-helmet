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
			!(T is "HHelmet") &&
			(
				T is "HDArmour" ||
				(T is "HDMagAmmo" && HDMagAmmo(T).bIsArmor)
			) &&
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
			HHHelmetSpawner.SummonHelmet(HHCONST_HUDHELMET, T.Pos);
		}
	}
}
