// general functions that are nice to have
class HHFunc : Service
{
	// primarily for use in statusweapons.zs
	override int GetIntUI(
		String request,
		String stringArg,
		int intArg,
		double doubleArg,
		Object objectArg
	)
	{
		int retVal = 0;

		// Requires: objectArg (HDStatusBar)
		if (request == "CheckWeaponStuff")
			retVal = CheckWeaponStuff(HDStatusBar(objectArg));

		// Requires: stringArg (name), objectArg (HDStatusBar)
		else if (request == "GetWeaponFiremode")
			GetWeaponFiremode(HDStatusBar(objectArg));

		// Requires: stringArg (name), objectArg (HDStatusBar), intArg (hdFlags), doubleArg (gzFlags)
		else if (request == "SBDrawArmour")
			retVal = SBDrawArmour(stringArg, HDStatusBar(objectArg), intArg, doubleArg);

		// Requires: objectArg (HDStatusBar), intArg (hdFlags), doubleArg (gzFlags)
		else if (request == "SBDrawHelmet")
			SBDrawHelmet(HDStatusBar(objectArg), intArg, doubleArg);

		else
			retVal = HandleGetInt(request, stringArg, intArg, doubleArg, objectArg);

		return retVal;
	}

	override int GetInt(
		String request,
		String stringArg,
		int intArg,
		double doubleArg,
		Object objectArg
	)
	{
		return HandleGetInt(request, stringArg, intArg, doubleArg, objectArg);
	}

	clearscope int HandleGetInt(
		String request,
		String stringArg,
		int intArg,
		double doubleArg,
		Object objectArg
	)
	{
		int retVal = 0;

		// Requires: objectArg (Actor)
		if (request == "CheckForArmour")
			retVal = CheckForArmour(Actor(objectArg));

		// Requires: stringArg (name)
		else if (request == "IsArmour")
			retVal = IsArmour(stringArg);

		// Requires: objectArg (Actor)
		else if (request == "GetShowHUD")
			retVal = GetShowHUD(Actor(objectArg));

		else
			Console.PrintF("HHFunc: Invalid request "..request.."! Please fix :[");

		return retVal;
	}

	override Object GetObject(
		String request,
		String stringarg,
		int intArg,
		double doubleArg,
		Object objectArg
	)
	{
		Object retVal;

		// Requires: objectArg (Actor)
		// Note: Helmet can be wrapped under HDArmourWorn
		if (request == "FindHelmet")
			retVal = Object(FindHelmet(Actor(objectArg)));

		// Requires: stringArg (name)
		else if (request == "FindArmourType")
			retVal = FindArmourType(stringArg);

		else
			Console.PrintF("HHFunc: Invalid request "..request.."! Please fix :[");

		return retVal;
	}


	// This looks for any HHBaseHelmetWorn, not HHBaseHelmet
	static clearscope HHelmetWorn FindHelmet(Actor actor)
	{
		return HHelmetWorn(actor.FindInventory("HHelmetWorn", true));
	}

	static clearscope bool CheckForArmour(Actor actor)
	{
		for (Inventory i = actor.Inv; i; i = i.Inv)
		{
			HDDamageHandler hdh = HDDamageHandler(i);
			if (!hdh)
				continue;

			string arm = hdh.GetClassName();
			if (FindArmourType(arm))
				return true;
		}

		return false;
	}

	static clearscope HHArmourType FindArmourType(string name)
	{
		let ti = ThinkerIterator.Create("HHArmourType", Thinker.STAT_DEFAULT);

		// Is this a valid armour name?
		HHArmourType type;
		while (type = HHArmourType(ti.next()))
		{
			if (name == type.GetWornName())
				return type;
		}

		return NULL;
	}

	static clearscope bool IsArmour(string name)
	{
		let ti = ThinkerIterator.Create("HHArmourType", Thinker.STAT_DEFAULT);

		// Is this a valid armour name?
		HHArmourType hhat;
		while (hhat = HHArmourType(ti.next()))
		{
			if (name == hhat.GetName()) return true;
		}

		return false;
	}

	static clearscope int GetShowHUD(Actor actor)
	{
		int helmet = (HHFunc.FindHelmet(actor))? 1 : 0;
		return (helmet);
	}


	// UI and non-static stuff (you probably won't use these)
	transient Array<string> FMRefIds;
	transient Array<FiremodeInfo> FInfo;
	transient CVar hh_hideammo;

	// Returns True, if not a weapon, is in whitelist, or the player has a helmet worn
	ui bool CheckWeaponStuff(HDStatusBar sb)
	{
		if (!hh_hideammo)
			hh_hideammo = CVar.GetCVar("hh_hideammo", sb.CPlayer);

		if (HHFunc.GetShowHUD(sb.hpl) || !hh_hideammo.GetBool())
			return true;

		let w = HDWeapon(sb.CPlayer.ReadyWeapon);
		if (w && w != WP_NOCHANGE)
		{
			// If the weapon doesn't have a slot number, then it ain't a weapon
			bool is_gun = (w.SlotNumber >= 0);
			if (!is_gun)
				return true;

			// Read from hh_weaponwhitelist
			Array<string> whitelist;
			whitelist.Clear();
			string text = CVar.GetCVar("hh_weaponwhitelist", sb.CPlayer).GetString();


			text.Split(whitelist," ");
			for (int i = 0; i < whitelist.Size(); i++)
			{
				// Is this a slot number?
				string text = whitelist[i];
				bool is_slot = (
					text == "1"
					|| text == "2"
					|| text == "3"
					|| text == "4"
					|| text == "5"
					|| text == "6"
					|| text == "7"
					|| text == "8"
					|| text == "9"
					|| text == "0"
				);

				// Are these weapons in the whitelist?
				if (
					(
						is_slot &&
						w.SlotNumber == whitelist[i].ToInt(10)
					) || w.RefId == whitelist[i]
				) return true;
			}

			return false;
		}

		// Apparently this isn't a weapon?
		return true;
	}

	// I can't determine what int the weapon uses for its firemode,
	// so it's better to just let the user handle it.
	// If you wish to add your own stuff, please refer to hh_manual.md
	ui void GetWeaponFiremode(HDStatusBar sb)
	{
		let hdw = HDWeapon(sb.CPlayer.ReadyWeapon);
		if (!hdw)
			return;

		// Already been initialised?
		if (FMRefIds.Size() == 0)
		{
			Array<string> text;
			text.Clear();

			// Get all the text files that match
			int lump = -1;
			while (-1 != (lump = Wads.FindLump("hh_firemodecodes", lump + 1)))
			{
				string s = Wads.ReadLump(lump);
				s.Replace("\r\n", "\n");
				s.Split(text, "\n");
			}

			// Get the segments
			for (int i = 0; i < text.size(); i++)
			{
				Array<string> temp;
				temp.Clear();
				text[i].Split(temp, ":");

				if (temp.Size() >= 3)
				{
					let fc = FiremodeInfo(new("FiremodeInfo"));

					FMRefIds.Push(temp[0]);
					fc.Id = temp[1].ToInt(10);

					temp[2].Split(fc.Img, ",");
					if (temp.Size() > 3)
						temp[3].Split(fc.Bitwise, ",");

					FInfo.Push(fc);
				}
			}
		}

		int id;
		Array<string> img;
		Array<string> bitwise;
		img.Clear();
		bitwise.Clear();
		for (int i = 0; i < FMRefIds.Size(); i++)
		{
			if (FMRefIds[i] == hdw.RefId)
			{
				FiremodeInfo fc = FInfo[i];
				id = fc.Id;
				img.Copy(fc.Img);
				bitwise.Copy(fc.Bitwise);
			}
		}

		string types[7];
		if (img.size() <= 7)
			for (int i = 0; i < img.Size(); i++)
				types[i] = img[i];

		else
			for (int i = 0; i < 7; i++)
				types[i] = img[i];

		// Use Bitwise AND comparison?
		if (!(bitwise.size() < 1))
		{
			string icon;
			for (int i = 0; i < bitwise.Size(); i++)
			{
				if (bitwise[i] == "blank" && !icon)
					icon = img[i];

				else if (hdw.WeaponStatus[id] & bitwise[i].ToInt(10))
					icon = img[i];
			}
			sb.DrawImage(
				icon,
				(-22,-10),
				sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TRANSLATABLE | sb.DI_ITEM_RIGHT
			);
		}
		else
			sb.DrawWepCounter(
				hdw.WeaponStatus[id],
				-22,-10,
				types[0], types[1], types[2], types[3], types[4], types[5], types[6]
			);
	}

	ui bool SBDrawArmour(
		class<HDPickup> pkup,
		HDStatusBar sb,
		int hdFlags,
		int gzFlags
	)
	{
		let hp = HDPickup(sb.CPlayer.mo.FindInventory(pkup));

		HHArmourType type;
		let ti = ThinkerIterator.Create("HHArmourType", Thinker.STAT_DEFAULT);
		while (type = HHArmourType(ti.Next()))
		{
			if (type.GetWornName() == hp.GetClassName())
			{
				type.DrawArmour(sb, hp, hdFlags, gzFlags);
				return true;
			}
		}

		return false;
	}

	ui void SBDrawHelmet(HDStatusBar sb, int hdFlags, int gzFlags)
	{
		let helmet = HDArmourWorn(sb.CPlayer.mo.FindInventory("HHelmetWorn", true));
		if (helmet)
			helmet.DrawHUDStuff(sb, HDPlayerPawn(sb.CPlayer.mo), hdFlags, gzFlags);
	}
}