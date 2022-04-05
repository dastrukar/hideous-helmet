// Helmet + Armour is kind of busted, let's fix that :]

class HHArmourNerfHandler : EventHandler
{
	override void WorldTick()
	{
		if (!hh_nerfarmour) return;

		// Loop through all the players
		for (int i; i < MAXPLAYERS; i++)
		{
			let hdp = HDPlayerPawn(Players[i].mo);

			// Check for armour
			if (!(
				hdp &&
				!hdp.FindInventory("HHArmourNerf") &&
				HHFunc.CheckForArmour(hdp)
			)) continue;

			hdp.GiveInventory("HHArmourNerf", 1);
			if (hh_debug) Console.PrintF("Gave Nerf to "..CVar.GetCVar("name", players[i]).GetString());
		}
	}

	// Enemies must suffer as much as you
	override void WorldThingSpawned(WorldEvent e)
	{
		let T = e.Thing;

		if (hh_nerfarmour && T is "HDMobBase")
		{
			if (hh_debug) Console.PrintF("Gave Nerf to "..T.GetClassName());
			T.GiveInventory("HHArmourNerf", 1);
		}
	}
}

class HHArmourNerf : HDDamageHandler
{
	Default
	{
		Inventory.MaxAmount 1;
		HDPickup.WornLayer 0;
		HDDamageHandler.Priority 0;
	}

	override double, double OnBulletImpact(
		HDBulletActor bullet,
		double pen,
		double penShell,
		double hitAngle,
		double deemedWidth,
		vector3 hitPos,
		vector3 vu,
		bool hitActorIsTall
	)
	{
		let hitActor = Owner;
		if (!hitActor) return 0, 0;

		let hdmb = HDMobBase(hitActor);
		let hdp = HDPlayerPawn(hitActor);
		double hitHeight = hitActorIsTall? ((hitPos.z - hitActor.Pos.z) / hitActor.Height) : 0.5;

		// Don't exist if there's no armour left
		// Or you just disabled nerfing the armour
		if (
			(
				!(hdp && HHFunc.CheckForArmour(hdp)) &&
				!(hdmb && HHFunc.CheckForArmour(hdmb))
			) ||
			!hh_nerfarmour
		)
		{
			if (hh_debug) Console.PrintF("Removing Nerf from "..hitActor.GetClassName());
			Destroy();
			return pen, penshell;
		}

		// If standing right over an incap'd victim, bypass armour
		if (
			bullet.Pitch > 80 &&
			(
				(hdp && hdp.Incapacitated) ||
				(
					hdmb &&
					hdmb.Frame >= hdmb.DownedFrame &&
					hdmb.InStateSequence(hdmb.CurState, hdmb.ResolveState("falldown"))
				)
			)
		) return pen, penshell;

		// Nerf head defense
		if (hitHeight > 0.8)
		{
			// might redo this some day, but for the time being, this makes stuff more compatible with other armour related stuff
			double nerf = FRandom(5, 15);
			penShell -= nerf;

			if (hh_debug) Console.PrintF(hitActor.GetClassName().." got their armour nerfed by "..nerf);
		}

		return pen, penShell;
	}
}
