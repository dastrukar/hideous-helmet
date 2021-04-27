// Some code borrowed from Ugly as Sin by Caligari87.

class HasDroppedHelmetBefore:InventoryFlag{
}

class DummyHelmet:IdleDummy {
	override void postbeginplay() {
		super.postbeginplay();
		let helm = HHelmet(spawn("HHelmet", pos, ALLOW_REPLACE));
		helm.vel = vel;
		helm.mags.clear();
		helm.mags.push(50);
		helm.syncamount();
	}
}

class BrokenDummyHelmet:IdleDummy {
	override void postbeginplay() {
		super.postbeginplay();
		let helm = HHelmet(spawn("HHelmet", pos, ALLOW_REPLACE));

		int hh_mindurability = cvar.getcvar("hh_mindurability").getint();
		int hh_maxdurability = cvar.getcvar("hh_maxdurability").getint();

		helm.vel = vel;
		helm.mags.clear();
		helm.mags.push(random(hh_mindurability, hh_maxdurability));
		helm.syncamount();
	}
}

class HHelmetSpawner:EventHandler {
	float hh_jackbootspawn;
	float hh_armourspawn;
	float hh_marinespawn;
	override void WorldLoaded(WorldEvent e) {
		hh_jackbootspawn = 1 - cvar.getcvar("hh_jackbootspawn").getfloat();
		hh_armourspawn = 1 - cvar.getcvar("hh_armourspawn").getfloat();
		hh_marinespawn = 1 - cvar.getcvar("hh_marinespawn").getfloat();
	}

	// Armour should come with helmets
	override void WorldThingSpawned(WorldEvent e) {
		if(level.maptime > 2 || !e.Thing) return;
		let T = e.Thing;
		let T_name = T.GetClassName();

		Actor helm;
		Vector3 t_pos = (T.pos.x, T.pos.y, T.pos.z+5);
		if (T_name == "HDArmour" && frandom(0,1) >= hh_armourspawn) helm = Actor.Spawn("DummyHelmet", t_pos);

		if (helm) {
			helm.vel.x += frandom(-2,2);
			helm.vel.y += frandom(-2,2);
			helm.vel.z += frandom(1,3);
		}
	}

	// Enemies have helmets, drop em
	override void WorldThingDied(WorldEvent e) {
		if (!e.Thing) return;
		let T = e.Thing;
		let T_name = T.GetClassName();

		Actor helm;
		Vector3 t_pos = (T.pos.x, T.pos.y, T.pos.z+5);

		// Jackboots
		bool is_jackboot = ((
			T_name == "HideousShotgunGuy" ||
			T_name == "UndeadJackbootMan" ||
			T_name == "DeadHideousShotgunGuy") &&
			HideousShotgunGuy(T).wep == -1
		);

		// Marines
		bool is_marine = (
			T_name == "DeadRifleman" ||
			T_name == "ReallyDeadRifleman" ||
			T_name == "UndeadRifleman"
		);

		if (is_jackboot || is_marine) {
			if (
				!T.findinventory("HasDroppedHelmetBefore", false) &&
				frandom(0,1) >= hh_jackbootspawn
			) helm = Actor.Spawn("BrokenDummyHelmet", t_pos);

			// Make sure the enemy can't try to drop another helmet again
			T.setinventory("HasDroppedHelmetBefore", 1);
		}

		if (helm) {
			helm.vel.x += frandom(-2,2);
			helm.vel.y += frandom(-2,2);
			helm.vel.z += frandom(1,3);
		}
	}
}
