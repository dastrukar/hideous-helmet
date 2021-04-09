// Code borrowed from Ugly as Sin by Caligari87.

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

class HHelmetSpawner:EventHandler{
	override void WorldThingSpawned(WorldEvent e) {
		if(level.maptime > 1) return;
		if(!e.Thing) return;
		let T = e.Thing;

		bool is_corpse = (
			T.GetClassName() == "DeadRifleman" ||
			T.GetClassName() == "ReallyDeadRifleman"
		);

		if((T.GetClassName() == "HDArmour" || is_corpse) && randompick(0,0,1) == 1) {
			let helm = Actor.Spawn(is_corpse?"BrokenDummyHelmet":"DummyHelmet", (T.pos.x, T.pos.y, T.pos.z+5));
			helm.vel.x += frandom(-2,2);
			helm.vel.y += frandom(-2,2);
			helm.vel.z += frandom(1,3);
		}
	}
}
