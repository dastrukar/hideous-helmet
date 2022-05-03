// Ah yes, more item micro management
class HHHelmetManager : HDWeapon
{
	private Array<string> _Helmets;
	private Array<HHBaseModule> _Modules;
	private bool _HelmetMode;

	string SelectedHelmet;

	Default
	{
		+Weapon.WIMPY_WEAPON;
		+Weapon.NO_AUTO_SWITCH;
		+NOINTERACTION;
		Weapon.SelectionOrder 1000;
	}

	override void BeginPlay()
	{
		Super.BeginPlay();

		_HelmetMode = true;

		for (int i = 0; i < AllActorClasses.Size(); i++)
		{
			if (AllActorClasses[i] == "HHBaseHelmet") _Helmets.Push(GetDefaultByType(AllActorClasses[i]).GetClassName());
		}
	}

	override Inventory CreateTossable(int amt)
	{
		if (Owner) Owner.A_DropInventory(SelectedHelmet, amt);
		return null;
	}

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon wp, HDPlayerPawn hpl)
	{
		Vector2 charSize = (sb.pSmallFont.mFont.GetCharWidth("0"), sb.pSmallFont.mFont.GetHeight());
		Vector2 helmetsPos = (0, 0);
		Vector2 modulesPos = (charSize.x * -4, 0);
		Vector2 lModulesPos = (-modulesPos.x, 0);
		Vector2 headerPos = (helmetsPos.x, helmetsPos.y + (charSize.y * -4));
		Vector2 hudScale = (hh_managerscale, hh_managerscale);

		int commonFlags = sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER | sb.DI_ITEM_CENTER;
		int moduleFlags = sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_RIGHT | sb.DI_ITEM_CENTER;
		int lModuleFlags = sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_LEFT | sb.DI_ITEM_CENTER;

		HHBaseHelmet selHelmet = GetHelmet();

		// Header
		sb.DrawString(
			sb.pSmallFont,
			"=== Helmet Manager ===",
			headerPos,
			commonFlags,
			scale: hudScale
		);

		if (!GetHelmet())
		{
			sb.DrawString(
				sb.pSmallFont,
				"You don't have any helmets.",
				(0, 0),
				commonFlags,
				scale: hudScale
			);
			return;
		}

		// Arrows
		sb.DrawString(
			sb.pSmallFont,
			"<--",
			(0, -charSize.y),
			commonFlags,
			scale: hudScale
		);
		sb.DrawString(
			sb.pSmallFont,
			"-->",
			(0, charSize.y),
			commonFlags,
			scale: hudScale
		);

		// Draw current helmet
		sb.DrawString(
			sb.pSmallFont,
			selHelmet.GetTag(),
			(helmetsPos.x, helmetsPos.y + (charSize.y * 1)),
			commonFlags,
			scale: hudScale
		);
		sb.DrawImage(
			TexMan.GetName(selHelmet.Icon),
			helmetsPos,
			commonFlags,
			scale: hudScale
		);
	}

	clearscope HHBaseHelmet GetHelmet()
	{
		return HHBaseHelmet(Owner.FindInventory(SelectedHelmet));
	}

	// Should only be called by Use state :]
	static void ManageHelmet(HHBaseHelmet helmetType)
	{
		let master = HDPlayerPawn(helmetType.Owner);
		let manager = HHHelmetManager(master.FindInventory("HHHelmetManager"));

		manager.SelectedHelmet = helmetType.GetClassName();
		master.UseInventory(manager);
	}

	void UpdateModuleList()
	{
		_Modules.Clear();

		Inventory item;
		while (item = Owner.Inv)
		{
			if (item is "HHBaseModule") _Modules.Push(HHBaseModule(item));
		}
	}

	action void A_HMReady()
	{
		A_WeaponReady();
		HHBaseHelmet helmet = Invoker.GetHelmet();
		if (!helmet) return;

		// Wear helmet
		if (JustPressed(BT_ZOOM)) helmet.TryWearHelmet();

		// Cycle items
		else if (JustPressed(BT_ATTACK))
		{
			if (Invoker._HelmetMode)
			{
				// Helmet
				helmet.Mags.Insert(0, helmet.Mags[helmet.Mags.Size() - 1]);
				helmet.Mags.Pop();
			}
			else
			{
				// Modules
			}
		}
		else if (JustPressed(BT_ALTATTACK))
		{
			// Helmet
			if (Invoker._HelmetMode)
			{
				Array<int> tmpMags;
				for (int i = 1; i < helmet.Mags.Size(); i++)
				{
					tmpMags.Push(helmet.Mags[i]);
				}
				tmpMags.Push(helmet.Mags[0]);
				helmet.Mags.Move(tmpMags);
			}
		}
	}

	States
	{
		Ready:
			TNT1 A 1 A_HMReady();
			goto ReadyEnd; // idk why not including this slows you down
	}
}
