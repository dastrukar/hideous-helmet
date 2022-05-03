// This code is very hacky, might be a bit messy -dastrukar
// Original code taken from Hideous Destructor

// HDMagAmmo is used, due to how backpacks handle icons for HDArmour
class HHBaseHelmet : HDMagAmmo abstract
{
	class<HHBaseHelmetWorn> WornHelmet;

	property wornHelmet: WornHelmet;

	Default
	{
		-Inventory.INVBAR // Helmet inventory will be handled via another item
		+HDPickup.CHEATNOGIVE
		+HDPickup.NOTINPOCKETS
		+Inventory.ISARMOR
		Inventory.Amount 1;
		Tag "HUD Helmet";
		Inventory.Icon "HELMA0";
		Inventory.PickupMessage "Picked up the HUD helmet.";

		// set it yourself you lazy prick
		HDMagammo.MaxPerUnit 0; // Max durability
		HDMagammo.MagBulk 0; // Weight per helmet
		HHBaseHelmet.WornHelmet ""; // Which helmet to wear?
	}

	// This is only called if hd_helptext is true
	virtual string GetFlavourText()
	{
		return "This helmet be looking real fine.";
	}

	override bool IsUsed()
	{
		return true;
	}

	/* might not need this
	override int GetSBarNum(int flags)
	{
		int magSize = Mags.Size() - 1;
		if (magSize < 0) return -1000000; // if -1000000, don't count on statusbar inv
		else return Mags[magSize] % 1000;
	}
	*/

	override void AddAMag(int addAmt)
	{
		if (addAmt < 0) addAmt = MaxPerUnit;
		Mags.Push(addAmt);
		Amount = Mags.Size();
	}

	override void MaxCheat()
	{
		SyncAmount();
		for (int i = 0; i < Amount; i++) Mags[i] = MaxPerUnit;
	}

	override void ActualPickup(Actor other, bool silent)
	{
		if (!other) return;

		int durability = Mags[Mags.Size() - 1];
		// Put on the helmet right away?
		if (
			other.Player &&
			other.Player.Cmd.Buttons & BT_USE &&
			!other.FindInventory("HHBaseHelmetWorn", true) &&
			HDPlayerPawn(other).StripTime == 0
		)
		{
			HDArmour.ArmourChangeEffect(other);
			let worn = HHBaseHelmetWorn(other.GiveInventoryType(WornHelmet));
			worn.Durability = durability;
			Destroy();
			return;
		}

		if (!TryPickup(other)) return;

		let helmet = HHBaseHelmet(other.FindInventory(self.GetClassName()));
		helmet.SyncAmount();
		helmet.Mags.Insert(0, durability);
		helmet.Mags.Pop();
		other.A_StartSound(PickupSound, CHAN_AUTO);
		other.A_Log(string.Format("\cg%s", PickupMessage(), true));
	}

	override void Consolidate() {} // Don't consolidate :]

	override double GetBulk()
	{
		SyncAmount();
		return MagBulk * Amount;
	}

	override void SyncAmount()
	{
		if (Amount < 1)
		{
			Destroy();
			return;
		}

		Super.SyncAmount();
		for (int i = 0; i < Amount; i++) Mags[i] = Min(Mags[i], MaxPerUnit);
	}
}

class HHelmet : HDMagAmmo
{
	int Cooldown;

	Default
	{
		+Inventory.INVBAR
		+HDPickup.CHEATNOGIVE
		+HDPickup.NOTINPOCKETS
		+Inventory.ISARMOR
		Inventory.Amount 1;
		HDMagammo.MaxPerUnit HHCONST_HUDHELMET;
		HDMagammo.MagBulk ENC_HUDHELMET;
		Tag "HUD Helmet";
		Inventory.Icon "HELMA0";
		Inventory.PickupMessage "Picked up the HUD helmet.";
	}

	override bool IsUsed()
	{
		return true;
	}

	override int GetSBarNum(int flags)
	{
		int magSize = Mags.size() - 1;
		if (magSize < 0) return -1000000;
		else return Mags[magSize] % 1000;
	}

	override void AddAMag(int addAmt)
	{
		if (addAmt < 0) addAmt = HHCONST_HUDHELMET;
		Mags.Push(addAmt);
		Amount = Mags.Size();
	}

	override void MaxCheat()
	{
		SyncAmount();
		for (int i = 0; i < Amount; i++) Mags[i] = HHCONST_HUDHELMET;
	}

	action void A_WearArmour()
	{
		bool helpText = (Player && CVar.GetCvar("hd_helptext", Player).GetBool());
		Invoker.SyncAmount();
		int dbl = Invoker.Mags[Invoker.Mags.Size() - 1];
		//if holding use, cycle to next armour
		if (Player && Player.Cmd.Buttons & BT_USE) {
			Invoker.Mags.Insert(0, dbl);
			Invoker.Mags.Pop();
			Invoker.SyncAmount();
			return;
		}

		// Strip worn helmet on double click
		if (
			Invoker.Cooldown > 0 &&
			Self.FindInventory("HHelmetWorn")
		)
		{
			Self.DropInventory(Self.FindInventory("HHelmetWorn"));
			return;
		}
		if (HDPlayerPawn(Self).StripTime > 0) return;

		if (Self.FindInventory("HHelmetWorn"))
		{
			Invoker.Cooldown = 10;
			return;
		}

		//and finally put on the actual armour
		HDArmour.ArmourChangeEffect(Self);
		let worn = HHelmetWorn(GiveInventoryType("HHelmetWorn"));
		worn.Durability = dbl;
		Invoker.Amount--;
		Invoker.Mags.Pop();

		if (helpText)
		{
			string blah = string.Format("You put on the helmet.");
			double qual = double(worn.Durability) / HHCONST_HUDHELMET;
			if (qual < 0.2) A_Log(blah.." Just don't get hit.", true);
			else if (qual < 0.3) A_Log(blah.." Does this helmet even work?", true);
			else if (qual < 0.5) A_Log(blah.." It's better than nothing.", true);
			else if (qual < 0.7) A_Log(blah.." This helmet has definitely seen better days.", true);
			else if (qual < 0.9) A_Log(blah.." Seems to be fine.", true);
			else A_Log(blah, true);
		}

		invoker.SyncAmount();
	}

	override void DoEffect()
	{
		if (Cooldown > 0) Cooldown--;
		if (!Amount) Destroy();
	}

	override void ActualPickup(actor other, bool silent)
	{
		Cooldown = 0;
		if (!other) return;

		int durability = Mags[Mags.Size() - 1];
		//put on the armour right away
		if (
			other.Player &&
			other.Player.Cmd.Buttons & BT_USE &&
			!other.FindInventory("HHelmetWorn") &&
			HDPlayerPawn(other).StripTime == 0
		)
		{
			HDArmour.ArmourChangeEffect(other);
			let worn = HDArmourWorn(other.GiveInventoryType("HHelmetWorn"));
			worn.Durability = durability;
			Destroy();
			return;
		}
		if (!TryPickup(other)) return;
		HHelmet aaa = HHelmet(other.FindInventory("HHelmet"));
		aaa.SyncAmount();
		aaa.Mags.Insert(0, durability);
		aaa.Mags.Pop();
		other.A_StartSound(PickupSound, CHAN_AUTO);
		other.A_Log(string.Format("\cg%s", PickupMessage()), true);
	}

	override void BeginPlay()
	{
		Cooldown = 0;
		Super.BeginPlay();
	}

	override void Consolidate() {}

	override double GetBulk()
	{
		SyncAmount();
		double blk = 0;
		for (int i = 0; i < Amount; i++) blk += ENC_HUDHELMET;
		return blk;
	}

	override void SyncAmount()
	{
		if (Amount < 1)
		{
			Destroy();
			return;
		}
		Super.SyncAmount();
		for (int i = 0; i < Amount; i++) Mags[i] = Min(Mags[i], HHCONST_HUDHELMET);
	}

	States
	{
		Spawn:
			HELM A -1;
			stop;
		Use:
			TNT1 A 0 A_WearArmour();
			fail;
	}
}

class HHelmetWorn : HDArmourWorn
{
	int headshots;
	int bodyshots;
	int headDamage;
	int bodyDamage;

	Default {
		HDPickup.RefId "hhw";
		HDPickup.WornLayer 0; // Don't use WornLayer to handle removing helmet
		Tag "HUD Helmet";
	}

	override void BeginPlay()
	{
		Super.BeginPlay();
		Durability = HHCONST_HUDHELMET;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
	}

	override double GetBulk()
	{
		return ENC_HUDHELMET * 0.1;
	}

	override void DrawHudStuff(
		hdstatusbar sb,
		hdplayerpawn hpl,
		int hdFlags,
		int gzFlags
	)
	{
		// Drawing helmet on the HUD is handled in statusbar.zs for layering reasons.
		string helmetSprite = "HELMA0";
		string helmetBack = "HELMB0";
		bool d = sb.hh_durabilitytop.GetBool();

		Vector2 helmpos =
			(hdFlags & HDSB_AUTOMAP)? (24, 86) :
			(hdFlags & HDSB_MUGSHOT)? (((sb.HudLevel == 1) ? -85 : -55), -18) :
			(0, -sb.mIndexFont.mFont.GetHeight() * 2 - 14);
		Vector2 coords = (helmPos.x, helmPos.y + sb.hh_helmetoffsety.GetInt());

		sb.DrawBar(
			helmetSprite, helmetBack,
			Durability, 72,
			coords, -1, sb.SHADER_VERT,
			gzFlags
		);
		sb.DrawString(
			sb.pNewSmallFont, sb.FormatNumber(Durability),
			coords + (10, (d)? -14 : -7),
			gzFlags | sb.DI_ITEM_CENTER | sb.DI_TEXT_ALIGN_RIGHT,
			Font.CR_DARKGRAY,
			scale:(0.5,0.5)
		);
	}

	override inventory CreateTossable(int amt)
	{
		let hdp = HDPlayerPawn(Owner);
		if (hdp.striptime > 0) return null;

		PrintHelmetDebug();

		//armour sometimes crumbles into dust
		if (Durability < Random(1, 5))
		{
			for (int i = 0; i < 10; i++)
			{
				Actor aaa = Spawn("WallChunk", Owner.Pos + (0, 0, Owner.Height - 24), ALLOW_REPLACE);
				Vector3 offsPos = (FRandom(-12, 12), FRandom(-12, 12), FRandom(-16, 4));
				aaa.SetOrigin(aaa.Pos + offsPos, false);
				aaa.Vel = Owner.Vel + offsPos * FRandom(0.3, 0.6);
				aaa.Scale *= FRandom(0.8 ,2.);
			}
			BreakSelf();
			return null;
		}

		//finally actually take off the armour
		HDArmour.ArmourChangeEffect(Owner);
		let tossed = HHelmet(Owner.Spawn(
			"HHelmet",
			(Owner.Pos.x, Owner.Pos.y, Owner.Pos.z + Owner.Height - 20),
			ALLOW_REPLACE
		));
		tossed.Mags.Clear();
		tossed.Mags.Push(Durability);
		tossed.Amount = 1;
		Owner.A_Log("Removing helmet first.", true);
		Destroy();
		return tossed;
	}

	// For convenience
	void BreakSelf()
	{
		PrintHelmetDebug();
		Owner.A_StartSound("helmet/break", CHAN_BODY);
		HDArmour.ArmourChangeEffect(Owner);
		Destroy();
	}

	// Handle damage
	override int, name, int, int, int, int, int HandleDamage(
		int damage,
		name mod,
		int flags,
		actor inflictor,
		actor source,
		int toWound,
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
			if(random(0,5))
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
		if (durability < 1) BreakSelf();

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
						FRandom(0, 1) <= 0.25
					)
					{
						// 25% chance to damage the helmet if shot in the face
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

				if (headshot) headDamage += ddd;
				else bodyDamage += ddd;
			}

			// For debugging
			if (headshot) headshots++;
			else bodyshots++;
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
				hdp.HudBobRecoil2 += (FRandom(-5, 5), FRandom(2.5, 4)) * 0.01 * hitHeight * mass;
				hdp.PlayRunning();
			}
			else if (Random(0, 255) < hitActor.PainChance)
			{
				HDMobBase.ForcePain(hitActor);
			}
		}

		return pen, penshell;
	}

	// Sometimes, reading through the debug log is not worth it
	void PrintHelmetDebug()
	{
		if (hh_debug) Console.PrintF("Helmet stats:\n Headshots: "..headshots.."("..headdamage..")\n Bodyshots: "..bodyshots.."("..bodydamage..")");
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

class HudHelmet : HDPickupGiver
{
	Default
	{
		//$Category "Items/Hideous Destructor"
		//$Title "HUD Helmet"
		//$Sprite "ARMCA0"

		+HDPickup.FITSINBACKPACK
		+Inventory.ISARMOR
		Inventory.Icon "HELMA0";
		HDPickupGiver.PickupToGive "HHelmet";
		HDPickup.Bulk 100;
		HDPickup.RefId "hdh";
		Tag "HUD Helmet (spare)";
		Inventory.PickupMessage "Picked up the HUD helmet.";
	}

	override void ConfigureActualPickup()
	{
		let aaa = HHelmet(ActualItem);
		aaa.Mags.Clear();
		aaa.Mags.Push(HHCONST_HUDHELMET);
		aaa.SyncAmount();
	}
}
