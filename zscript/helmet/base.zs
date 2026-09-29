// This code is very hacky, might be a bit messy -dastrukar
// Original code taken from Hideous Destructor

class HHelmet : HDArmour
{
	int Cooldown;

	Default
	{
		-HDPickup.DROPTRANSLATION
		
		Tag "$TAG_HHELMET";
		
		Inventory.Icon "HELMA0";
		Inventory.PickupMessage "$PICKUP_HHELMET";
		
		HDPickup.refid "hdh";
		
		HDMagammo.MaxPerUnit HHCONST_HUDHELMET;
		HDMagammo.MagBulk ENC_HUDHELMET;
	}

	action void A_WearHelmet(int delay = 25, int toStun = 90, bool blackout = true)
	{
		bool helpText = HDWeapon.CheckDoHelpText(self);
		Invoker.SyncAmount();
		int dbl = Invoker.Mags[Invoker.Mags.Size() - 1];
		//if holding use, cycle to next armour
		if (Player && Player.Cmd.Buttons & BT_USE) {
			Invoker.Mags.Insert(0, dbl);
			Invoker.Mags.Pop();
			Invoker.SyncAmount();
			return;
		}

		// Get worn armour's defaults/metadata
		let wornName = invoker.WornName();
		let wornCls = (Class<HDArmourWorn>)(wornName);
		let wornDefs = GetDefaultByType(wornCls);

		// Strip worn helmet on double click
		if (
			Invoker.Cooldown > 0 &&
			Self.FindInventory(wornName)
		)
		{
			Self.DropInventory(Self.FindInventory(wornName));
			return;
		}
		if (HDPlayerPawn(Self).StripTime > 0) return;

		if (Self.FindInventory(wornName))
		{
			Invoker.Cooldown = 10;
			return;
		}

		//and finally put on the actual armour
		invoker.onArmourChange(self, delay, toStun, blackout);

		HDF.Give(self, wornname);
		let worn = HDArmourWorn(FindInventory(wornName));
		worn.Durability = dbl;
		Invoker.Amount--;
		Invoker.Mags.Pop();

		invoker.WearArmourHelpText(self, dbl);

		invoker.SyncAmount();
	}

	override void WearArmourHelpText(actor wearer, double durability)
	{
		if (!HDWeapon.CheckDoHelpText(wearer)) return;
		wearer.A_Log(
			Stringtable.Localize("$HHELMET_PUTON")
			..gettag()
			..Stringtable.Localize("$HD_SENTENCEBREAK")
			..Stringtable.Localize(GetArmourOpinion(durability / maxperunit))
		,true);
	}

	override string GetArmourOpinion(double qual)
	{
		if (qual < 0.2) return "$HHELMET_DUR20";
		if (qual < 0.3) return "$HHELMET_DUR30";
		if (qual < 0.6) return "$HHELMET_DUR60";
		if (qual < 0.7) return "$HHELMET_DUR70";
		if (qual < 0.9) return "$HHELMET_DUR90";
		return "";
	}

	States
	{
		Spawn:
			HELM A -1;
			stop;
		Use:
			TNT1 A 0 A_WearHelmet();
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
		Tag "$TAG_HHELMET";

		HDPickup.RefId "hhw";
		HDPickup.WornLayer 0; // Don't use WornLayer to handle removing helmet
		HDPickup.bulk ENC_HUDHELMET * 0.1;

		HDArmourWorn.armoursprite "HELMA0";
		HDARmourWorn.armourback "HELMB0";

		HDArmourWorn.coverage ARMOUR_FACE|ARMOUR_HEAD;
		HDArmourWorn.durability HHCONST_HUDHELMET;
		HDArmourWorn.hindrance Int.MAX; // Don't hinder player speed
		HDArmourWorn.thickness 1;
	}

	override void DrawHudStuff(
		hdstatusbar sb,
		hdplayerpawn hpl,
		int hdFlags,
		int gzFlags
	)
	{
		// Drawing helmet on the HUD is handled in statusbar.zs for layering reasons.
		bool d = hh_durabilitytop;

		Vector2 helmpos =
			(hdFlags & HDSB_AUTOMAP)? (24, 86) :
			(hdFlags & HDSB_MUGSHOT)? (((sb.HudLevel == 1) ? -85 : -55), -18) :
			(0, -sb.mIndexFont.mFont.GetHeight() * 2 - 14);
		Vector2 coords = (helmPos.x, helmPos.y + hh_helmetoffsety);

		sb.DrawBar(
			armoursprite, armourback,
			durability, default.durability,
			coords, -1, sb.SHADER_VERT,
			gzFlags
		);
		sb.DrawString(
			sb.pNewSmallFont, sb.FormatNumber(durability),
			coords + (10, (d)? -14 : -7),
			gzFlags | sb.DI_ITEM_CENTER | sb.DI_TEXT_ALIGN_RIGHT,
			Font.CR_DARKGRAY,
			scale:(0.5,0.5)
		);
	}


	override Inventory CreateTossable(int amt)
	{
		if (HDPlayerPawn(Owner) && HDPlayerPawn(Owner).striptime > 0)
			return null;

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
		string tosstype = GetClassName();
		tossType = tossType.left(tossType.length() - 4);
		let tossed = HDArmour(Owner.Spawn(
			tossType,
			(Owner.Pos.x, Owner.Pos.y, Owner.Pos.z + Owner.Height - 20),
			ALLOW_REPLACE
		));
		tossed.Mags.Clear();
		tossed.Mags.Push(Durability);
		tossed.Amount = 1;

		tossed.onArmourChange(Owner);
		Owner.A_Log(Stringtable.Localize("$HHELMET_REMOVE"), true);
		Destroy();
		return tossed;
	}

	override bool isDamageIgnored(name mod, int flags, int durThresh)
	{
		return (flags&DMG_NO_ARMOR)
			|| mod == 'staples'
			|| mod == 'maxhpdrain'
			|| mod == 'internal'
			|| mod == 'jointlock'
			|| mod == 'falling'
			|| mod == 'slime'
			|| mod == 'bleedout'
			|| mod == 'drowning'
			|| mod == 'poison'
			|| mod == 'electrical'
			|| mod == 'invisiblebleedout'
			|| mod == 'electro'
			|| mod == 'lightning'
			|| mod == 'bolt'
			|| mod == 'balefire'
			|| mod == 'hellfire'
			|| mod == 'unholy'
			|| mod == 'bashing'
			|| mod == 'melee'
			|| !owner;
	}

	override double getBasePenShell()
	{
		// i mean, do you really expect a damaged helmet to block damage as well as it should?
		return ((Durability * FRandom(0.4, 1.8)) > 25)? FRandom(15, 20) : FRandom(5, 10);
	}

	override void doDamageArmour(int armourdamage) {
		super.doDamageArmour(armourdamage);

		if (hh_debug) Console.PrintF("helmet took "..armourdamage.." damage");
	}

	// Sometimes, reading through the debug log is not worth it
	void PrintHelmetDebug()
	{
		if (hh_debug) Console.PrintF("Helmet stats:\n Headshots: "..headshots.."("..headdamage..")\n Bodyshots: "..bodyshots.."("..bodydamage..")");
	}

	// For convenience
	void BreakSelf()
	{
		PrintHelmetDebug();
		Owner.A_StartSound("helmet/break", CHAN_BODY);
		HDArmour.ArmourChangeEffect(Owner);
		Destroy();
	}
}
