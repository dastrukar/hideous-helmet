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
			if (!(hdp && hdp.FindInventory("HDArmourWorn"))) {
				continue;
			}
			HDArmourWorn arm = HDArmourWorn(hdp.FindInventory("HDArmourWorn"));
			if (arm && !(hdp.FindInventory("HHArmourNerf"))) {
				hdp.GiveInventory("HHArmourNerf", 1);
			}
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
				!(hdp && hdp.FindInventory("HDArmourWorn")) &&
				!(hdmb && hdmb.FindInventory("HDArmourWorn"))
			) || (
				!hh_nerfarmour
			)
		) {
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
			Console.PrintF("HEADSHOT");
			HDArmourWorn arm = HDArmourWorn((hdp)? hdp.FindInventory("HDArmourWorn") : hdmb.FindInventory("HDArmourWorn"));
			double addpenshell = (arm.mega)? 30 : (10 + Max(0, (arm.durability - 120) >> 3));
			int crackseed = int(level.time + angle) & (1 | 2 | 4 | 8 | 16 | 32);

			if (hdmb && !hdmb.bhashelmet) {
				addpenshell=-1;
			} else {
				if (
					crackseed > Clamp(arm.durability, 1, 3) &&
					AbsAngle(bullet.angle, hitactor.angle) > (180. - 5.) &&
					bullet.pitch > -20 &&
					bullet.pitch < 7
				) {
					double dec = (arm.mega)? FRandom(5, 10) : addpenshell * 0.5;
					penshell -= dec;
				} else {
					penshell -= Min(addpenshell * 0.5, 10);
				}
			}
		}

		return pen, penshell;
	}
}
