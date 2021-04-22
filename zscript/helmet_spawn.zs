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
		helm.vel = vel;
		helm.mags.clear();
		helm.mags.push(frandom(10, 40));
		helm.syncamount();
	}
}

class HHelmetSpawner:EventHandler {
	float hh_jackbootspawn;
	float hh_armourspawn;
	float hh_corpsespawn;
	override void WorldLoaded(WorldEvent e) {
		hh_jackbootspawn = 1 - cvar.getcvar("hh_jackbootspawn").getfloat();
		hh_armourspawn = 1 - cvar.getcvar("hh_armourspawn").getfloat();
		hh_corpsespawn = 1 - cvar.getcvar("hh_corpsespawn").getfloat();
	}
	override void WorldThingSpawned(WorldEvent e) {
		if(level.maptime > 1) return;
		if(!e.Thing) return;
		let T = e.Thing;

		bool is_corpse = (
			T.GetClassName() == "DeadRifleman" ||
			T.GetClassName() == "ReallyDeadRifleman"
		);

		Actor helm;
		Vector3 t_pos = (T.pos.x, T.pos.y, T.pos.z+5);
		if (T.GetClassName() == "HDArmour" && frandom(0,1) >= hh_armourspawn) helm = Actor.Spawn("DummyHelmet", t_pos);
		else if (is_corpse && frandom(0,1) >= hh_corpsespawn) helm = Actor.Spawn("BrokenDummyHelmet", t_pos);

		if (helm) {
			helm.vel.x += frandom(-2,2);
			helm.vel.y += frandom(-2,2);
			helm.vel.z += frandom(1,3);
		}
	}

	// Jackboots have helmets, drop em
	override void WorldThingDied(WorldEvent e) {
		if (!e.Thing) return;
		let T = e.Thing;


		Actor helm;
		Vector3 t_pos = (T.pos.x, T.pos.y, T.pos.z+5);
		if (T.GetClassName() == "UndeadJackbootman") {
			if (
				!T.findinventory("HasDroppedHelmetBefore", false) &&
				frandom(0,1) >= hh_jackbootspawn
			) helm = Actor.Spawn("BrokenDummyHelmet", t_pos);
			// Make sure the jackboot can't drop another helmet again
			T.setinventory("HasDroppedHelmetBefore", 1);
		}

		if (helm) {
			helm.vel.x += frandom(-2,2);
			helm.vel.y += frandom(-2,2);
			helm.vel.z += frandom(1,3);
		}
	}
}
