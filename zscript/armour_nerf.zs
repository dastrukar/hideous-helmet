// Helmet + Armour is kind of busted, let's fix that :]

class HHArmourNerfHandler : EventHandler {
	override void WorldTick() {
		if (!hh_nerfarmour) {
			return;
		}
		// Loop through all the players
		for (int i; i < MAXPLAYERS; i++) {
			HDPlayerPawn hdp = HDPlayerPawn(players[i].mo);

			// Check for armour
			if (!(
				hdp &&
				!hdp.FindInventory("HHArmourNerf") &&
				HHMath.CheckForArmour(hdp)
			)) {
				continue;
			}

			hdp.GiveInventory("HHArmourNerf", 1);
			if (hh_debug) {
				Console.PrintF("Gave Nerf to "..CVar.GetCVar("name", players[i]).GetString());
			}
		}
	}

	// Enemies must suffer as much as you
	override void WorldThingSpawned(WorldEvent e) {
		let T = e.Thing;

		if (hh_nerfarmour && T is "HDMobBase") {
			if (hh_debug) {
				Console.PrintF("Gave Nerf to "..T.GetClassName());
			}
			T.GiveInventory("HHArmourNerf", 1);
		}
	}
}

class HHArmourNerf : HDDamageHandler {
	Default {
		Inventory.MaxAmount 1;
		HDPickup.wornlayer 0;
		HDDamageHandler.priority 0;
	}

	override double, double OnBulletImpact(
		HDBulletActor bullet,
		double pen,
		double penshell,
		double hitangle,
		double deemedwidth,
		vector3 hitpos,
		vector3 vu,
		bool hitactoristall
	) {
		let hitactor = Owner;
		if (!hitactor) {
			return 0, 0;
		}

		let hdmb = HDMobBase(hitactor);
		let hdp = HDPlayerPawn(hitactor);
		double hitheight = hitactoristall? ((hitpos.z - hitactor.pos.z) / hitactor.height) : 0.5;

		// Don't exist if there's no armour left
		// Or you just disabled nerfing the armour
		if (
			(
				!(hdp && HHMath.CheckForArmour(hdp)) &&
				!(hdmb && HHMath.CheckForArmour(hdmb))
			) || (
				!hh_nerfarmour
			)
		) {
			if (hh_debug) {
				Console.PrintF("Removing Nerf from "..hitactor.GetClassName());
			}
			Destroy();
			return pen, penshell;
		}

		// If standing right over an incap'd victim, bypass armour
		if (
			bullet.pitch > 80 &&
			(
				(hdp && hdp.incapacitated) ||
				(
					hdmb &&
					hdmb.frame >= hdmb.downedframe &&
					hdmb.InStateSequence(hdmb.curstate, hdmb.ResolveState("falldown"))
				)
			)
		) {
			return pen, penshell;
		}

		// Nerf head defense
		if (hitheight > 0.8) {
			// might redo this some day, but for the time being, this makes stuff more compatible with other armour related stuff
			double addpenshell = frandom(5, 15);
			penshell -= addpenshell;

			if (hh_debug) {
				Console.PrintF(hitactor.GetClassName().." got their armour nerfed by "..addpenshell);
			}
		}

		return pen, penshell;
	}
}
