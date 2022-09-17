// The main helmet spawner handler
class HHHelmetSpawner : EventHandler
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
		let ti = ThinkerIterator.Create("HHSpawnType", Thinker.STAT_DEFAULT);

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
		let helm = HudHelmet(Actor.Spawn("HudHelmet", pos, ALLOW_REPLACE));

		helm.Vel.x += FRandom(-2, 2);
		helm.Vel.y += FRandom(-2, 2);
		helm.Vel.z += FRandom(1, 3);

		helm.Mags.Clear();
		helm.Mags.Push(durability);
		helm.SyncAmount();
	}
}
