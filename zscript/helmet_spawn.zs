// Some code borrowed from Ugly as Sin by Caligari87.

class HasHelmet : InventoryFlag{
	int durability;
}

class DummyHelmet : IdleDummy {
	int durability;

	override void postbeginplay() {
		super.postbeginplay();
		let helm = HHelmet(spawn("HHelmet", pos, ALLOW_REPLACE));
		helm.vel = vel;
		helm.mags.clear();
		helm.mags.push(durability);
		helm.syncamount();
	}
}

class BrokenDummyHelmet : IdleDummy {
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

class HHelmetSpawner : EventHandler {
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
		
		bool is_jackboot = (
			(T is "HideousShotgunGuy") &&
			HideousShotgunGuy(T).wep == -1
		);

		bool is_marine = (T is "UndeadRifleman");

		Vector3 t_pos = (T.pos.x, T.pos.y, T.pos.z+5);
		if (T is "HDArmour" && frandom(0,1) >= hh_armourspawn) {
			// Armour
			DummyHelmet helm = DummyHelmet(Actor.Spawn("DummyHelmet", t_pos));
			helm.durability = HHCONST_HUDHELMET;
			helm.vel.x += frandom(-2,2);
			helm.vel.y += frandom(-2,2);
			helm.vel.z += frandom(1,3);
		} else if (
			(is_jackboot && frandom(0,1) >= hh_jackbootspawn) ||
			(is_marine && frandom(0,1) >= hh_marinespawn)
		) {
			// Jackboots and marines
			int hh_mindurability = cvar.getcvar("hh_mindurability").getint();
			int hh_maxdurability = cvar.getcvar("hh_maxdurability").getint();

			T.GiveInventory("HasHelmet", 1);
			HasHelmet helm = HasHelmet(T.CheckInventory("HasHelmet"));
			helm.durability = Random(hh_mindurability, hh_maxdurability);
		}
	}

	// Enemies have helmets, drop em
	override void WorldThingDied(WorldEvent e) {
		if (!e.Thing) return;
		let T = e.Thing;

		Vector3 t_pos = (T.pos.x, T.pos.y, T.pos.z+5);

		if (T.CheckInventory("HasHelmet")) {
			DummyHelmet helm = DummyHelmet(Actor.Spawn("DummyHelmet", t_pos));

			helm.durability = HasHelmet(T.CheckInventory("HasHelmet")).durability;
			helm.vel.x += frandom(-2,2);
			helm.vel.y += frandom(-2,2);
			helm.vel.z += frandom(1,3);

			// Make sure the enemy can't try to drop another helmet again
			T.TakeInventory("HasHelmet");
		}
	}
}
