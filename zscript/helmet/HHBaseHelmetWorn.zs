class HHBaseHelmetWorn : HDArmourWorn abstract
{
	protected int _helmetBulk;
	protected class<HHBaseHelmet> _tossHelmet;

	int Durability;
	int MaxDurability;
	HHModuleStorage ModuleStorage;
	HHModuleStorage InternalModuleStorage;

	property HelmetBulk: _helmetBulk;
	property TossHelmet: _tossHelmet;
	property MaxDurability: MaxDurability;

	Default {
		+Inventory.ISARMOR;
		Inventory.MaxAmount 1;
		HDDamageHandler.Priority 0;
		HDPickup.WornLayer 0; // Don't use WornLayer to handle removing helmet

		HHBaseHelmetWorn.MaxDurability 0;
		HHBaseHelmetWorn.HelmetBulk 0;
		HHBaseHelmetWorn.TossHelmet "";
	}

	override void BeginPlay()
	{
		Super.BeginPlay();
		Durability = MaxDurability;
		ModuleStorage = HHModuleStorage(new("HHModuleStorage"));
		InternalModuleStorage = HHModuleStorage(new("HHModuleStorage"));
	}

	override double GetBulk()
	{
		return _helmetBulk;
	}

	override Inventory CreateTossable(int amt)
	{
		let hdp = HDPlayerPawn(Owner);
		if (hdp.StripTime > 0) return null;

		// Helmet sometimes crumbles into dust
		if (Durability < Random(1, 5))
		{
			for (int i = 0; i < 10; i++)
			{
				Actor chunk = Spawn("WallChunk", Owner.Pos + (0, 0, Owner.Height - 24), ALLOW_REPLACE);
				Vector3 offsetPos = (FRandom(-12, 12), FRandom(-12, 12), FRandom(-16, 4));
				chunk.SetOrigin(chunk.Pos + offsetPos, false);
				chunk.Vel = Owner.Vel + offsetPos * FRandom(0.3, 0.6);
				chunk.Scale *= FRandom(0.8 ,2.);
			}

			BreakSelf();
			return null;
		}

		// Take off the helmet
		HDArmour.ArmourChangeEffect(Owner);
		let tossed = HHBaseHelmet(Owner.Spawn(
			_tossHelmet,
			(Owner.Pos.x, Owner.Pos.y, Owner.Pos.z + Owner.Height - 20),
			ALLOW_REPLACE
		));
		tossed.Mags.Clear();
		tossed.Mags.Push(Durability);
		tossed.Amount = 1;

		// Spawning a helmet always creates a ModuleStorage, this overwrites it
		tossed.ModuleStorage.Clear();
		tossed.InternalModuleStorage.Clear();
		tossed.ModuleStorage.Push(ModuleStorage);
		tossed.InternalModuleStorage.Push(InternalModuleStorage);

		Owner.A_Log(Stringtable.Localize("$HelmetWorn_Remove"), true);
		Destroy();
		return tossed;
	}

	// For convenience
	void BreakSelf()
	{
		Owner.A_StartSound("helmet/break", CHAN_BODY);
		HDArmour.ArmourChangeEffect(Owner);
		Destroy();
	}

	// Handle damage
	override int, name, int, double, int, int, int HandleDamage(
		int damage,
		name mod,
		int flags,
		actor inflictor,
		actor source,
		double toWound,
		int toBurn,
		int toStun,
		int toBreak
	)
	{
		// "I don't really know how to get this working with the damage system here,
		//	so I'll just do it the really dumb and simple way."
		bool damageTaken;
		int dmgDiff = Durability;

		float hDefense = 1.3;
		float durabilityDmg = Max(0, damage >> Random(3,5));

		// I don't think I need this for now.
		/*if(
			mod=="teeth"||
			mod=="claws"||
			mod=="bite"||
			mod=="scratch"||
			mod=="nails"||
			mod=="natural"
		){
			damage/=h_defense;
			helmet.durability -= durability_dmg;
			damagetaken = true;
		}else*/ if (
			mod == "thermal" ||
			mod == "fire" ||
			mod == "ice" ||
			mod == "heat" ||
			mod == "cold" ||
			mod == "plasma" ||
			mod == "burning"
		)
		{
			// ngl, i don't actually know how this works.
			// but i'm including it anyways, just in case
			if (Random(0,5))
			{
				damage-=10;
				Durability -= durabilityDmg;
				damageTaken = true;
			}
		}
		else if (
			mod == "cutting" ||
			mod == "slashing" ||
			mod == "piercing"
		)
		{
			// Stuff that armour shouldn't block, but also take damage from
			Durability -= durabilityDmg;
			damageTaken = true;
		}
		else if (
			mod != "bleedout" &&
			mod != "internal" &&
			mod != "invisiblebleedout" &&
			mod != "maxhpdrain" &&
			mod != "electro" &&
			mod != "electrical" &&
			mod != "lightning" &&
			mod != "bolt" &&
			mod != "balefire" &&
			mod != "hellfire" &&
			mod != "unholy" &&
			mod != "staples" &&
			mod != "falling" &&
			mod != "drowning" &&
			mod != "slime" &&
			mod != "bashing" &&
			mod != "Melee"
		)
		{
			// Basically any other damage type that armour should block
			Durability -= durabilityDmg;
			damageTaken = true;
		}
		//if (damagetaken && hh_debug) { DoHelmetDebug(dmgdiff-durability, mod); }
		if (Durability < 1) BreakSelf();

		return damage, mod, flags, towound, toburn, tostun, tobreak;
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
		) return pen, penShell;

		// i mean, do you really expect a damaged helmet to block damage as well as it should?
		float sucks = Durability * FRandom(0.4, 1.8);
		if (hh_debug) Console.PrintF(hitActor.GetClassName().."  helmet sucks:  "..sucks);

		float helmetShell = (sucks > 25)? FRandom(15, 20) : FRandom(5, 10);
		bool headshot = (hitHeight > 0.8);
		bool legshot = (hitHeight < 0.5);
		if (legshot)
		{
			// don't protect the legs
			helmetshell = 0;
		}
		else if (!headshot)
		{
			// imagine that the helmet has a magical net
			// also, enemies don't always aim for your "head" anyways, so it's kind of pointless for it to just protect the "head"
			helmetShell *= 0.5;
		}

		string debugText;
		if (hh_debug && headshot) debugText = "HEADSHOT.";
		else if (hh_debug && legshot) debugText = "leg shot.";
		else if (hh_debug) debugText = "body shot.";

		if (debugText) Console.PrintF(debugText);

		// durability stuff
		if (helmetshell > 0)
		{
			// helmet takes some damage
			int ddd = Random(-1, (int(Min(pen, helmetShell) * bullet.Stamina) >> 12));

			if (hh_debug) Console.PrintF("Random(Min("..pen..", "..helmetshell..") * "..bullet.Stamina.." >> 12) = "..ddd);

			if (ddd < 1)
			{
				bool penetrated = (pen > helmetShell);
				if (headshot)
				{
					if (
						penetrated ||
						FRandom(0, 1) <= 0.75
					)
					{
						// 75% chance to damage the helmet if shot in the face
						ddd = 1;
					}
				}
				else if (
					penetrated &&
					FRandom(0, 1) <= 0.50
				)
				{
					// 50% chance to not damage the helmet if you got penetrated in the chest
					ddd = 1;
				}
			}
			if (ddd > 0)
			{
				Durability -= ddd;
				if (hh_debug) Console.PrintF("helmet took "..ddd.." damage");
			}
		}
		else if (hh_debug) Console.PrintF("missed the helmet!");

		if (hh_debug) Console.PrintF(hitActor.getclassname().."  helmet resistance:  "..helmetShell);
		penShell += helmetShell;

		// Helmet can't take it anymore :[
		if (Durability < 1) BreakSelf();

		if (
			penShell > pen &&
			hitActor.Health > 0 &&
			hitActorIsTall
		) {
			hitActor.Vel += vu * 0.001 * hitHeight * mass;
			if (
				hdp &&
				!hdp.Incapacitated
			)
			{
				hdp.WepBobRecoil2 += (FRandom(-5, 5), FRandom(2.5, 4)) * 0.01 * hitHeight * mass;
				hdp.PlayRunning();
			}
			else if (Random(0, 255) < hitActor.PainChance)
			{
				HDMobBase.ForcePain(hitActor);
			}
		}

		return pen, penshell;
	}

	// Process module stuff
	override void DoEffect()
	{
		// Internal modules
		for (int i = 0; i < InternalModuleStorage.Modules.Size(); i++)
		{
			GetDefaultByType((class<HHBaseModule>)(InternalModuleStorage.Modules[i])).DoModuleEffect(Owner);
		}

		// Modules
		for (int i = 0; i < ModuleStorage.Modules.Size(); i++)
		{
			GetDefaultByType((class<HHBaseModule>)(ModuleStorage.Modules[i])).DoModuleEffect(Owner);
		}
	}

	// Handle module HUD stuff. Make sure to use Super.DrawHUDStuff when creating a new helmet!
	override void DrawHUDStuff(
		HDStatusBar sb,
		HDPlayerPawn hpl,
		int hdFlags,
		int gzFlags
	)
	{
		// Internal modules
		for (int i = 0; i < InternalModuleStorage.Modules.Size(); i++)
		{
			GetDefaultByType((class<HHBaseModule>)(InternalModuleStorage.Modules[i])).DoHUDStuff(sb, hpl);
		}

		// Modules
		for (int i = 0; i < ModuleStorage.Modules.Size(); i++)
		{
			GetDefaultByType((class<HHBaseModule>)(ModuleStorage.Modules[i])).DoHUDStuff(sb, hpl);
		}
	}

	void DoHelmetDebug(
		int actualDamage,
		name mod
	)
	{
		A_Log("damage before: "..damage);
		A_Log("helmet took "..actualDamage.." "..mod.." damage");
		A_Log(string.format("damage %d", damage));
	}
}
