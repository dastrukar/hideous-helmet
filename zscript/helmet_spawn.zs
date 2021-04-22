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
	override void WorldThingSpawned(WorldEvent e) {
		if(level.maptime > 1) return;
		if(!e.Thing) return;
		let T = e.Thing;

		float hh_armourspawn = 1 - cvar.getcvar("hh_armourspawn").getfloat();
		float hh_corpsespawn = 1 - cvar.getcvar("hh_corpsespawn").getfloat();

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

		float hh_jackbootspawn = 1 - cvar.getcvar("hh_jackbootspawn").getfloat();

		Actor helm;
		Vector3 t_pos = (T.pos.x, T.pos.y, T.pos.z+5);
		if (T.GetClassName() == "UndeadJackbootman" && frandom(0,1) >= randomnum) helm = Actor.Spawn("BrokenDummyHelmet", t_pos);

		if (helm) {
			helm.vel.x += frandom(-2,2);
			helm.vel.y += frandom(-2,2);
			helm.vel.z += frandom(1,3);
		}
	}
}
