// Ah yes, more item micro management
class HHManager : HDWeapon
{
	private Array<string> _Helmets;
	private Array<HHBaseModule> _Modules;
	private bool _HelmetMode;
	private int _ModuleIndex;
	private int _LoadedModuleIndex;

	string SelectedHelmet;

	Default
	{
		+Weapon.WIMPY_WEAPON;
		+Weapon.NO_AUTO_SWITCH;
		+NOINTERACTION;
		Weapon.SelectionOrder 1000;
		Tag "$HHManager_Name";
	}

	override void BeginPlay()
	{
		Super.BeginPlay();

		_HelmetMode = true;

		for (int i = 0; i < AllActorClasses.Size(); i++)
		{
			if (AllActorClasses[i] is "HHBaseHelmet")
				_Helmets.Push(GetDefaultByType(AllActorClasses[i]).GetClassName());
		}
	}

	override string GetHelpText()
	{
		return Stringtable.Localize("$HHManager_HelpText");
	}

	override Inventory CreateTossable(int amt)
	{
		if (Owner)
			Owner.A_DropInventory(SelectedHelmet, amt);

		return null;
	}

	private clearscope HHModuleStorage GetModuleStorage(HHBaseHelmet helmet)
	{
		return helmet.ModuleStorage[helmet.ModuleStorage.Size() - 1];
	}

	private ui void DrawModsList(
		HDStatusBar sb,
		Array<HHBaseModule> mods,
		int index,
		Vector2 pos,
		int flags,
		string selPrefix="",
		string selSuffix=""
	)
	{
		Vector2 charSize = (sb.pSmallFont.mFont.GetCharWidth("0"), sb.pSmallFont.mFont.GetHeight()) * hh_managerscale;

		int modListSize =
			(mods.Size() >= 5)? 5:
			(mods.Size() > 1)? 3:
			1;
		float modDrawOffset =
			(modListSize == 5)? charSize.y * -4:
			(modListSize == 3)? charSize.y * -2:
			0;

		for (int i = 0; i < modListSize; i++)
		{
			int offset = i - (modListSize >= 3) - (modListSize >= 5);
			int actualIndex = index + offset;

			if (actualIndex < 0) actualIndex = mods.Size() + offset;
			if (!mods[actualIndex]) return;

			string moduleName = mods[actualIndex].GetTag();
			if (offset == 0) moduleName = selPrefix..moduleName..selSuffix;

			sb.DrawString(
				sb.pSmallFont,
				moduleName,
				(pos.x, pos.y + modDrawOffset),
				flags
			);

			modDrawOffset += charSize.y * 2;
		}
	}

	override void DrawHUDStuff(HDStatusBar sb, HDWeapon wp, HDPlayerPawn hpl)
	{
		Vector2 charSize = (sb.pSmallFont.mFont.GetCharWidth("0"), sb.pSmallFont.mFont.GetHeight()) * hh_managerscale;
		Vector2 helmetsPos =
			(_helmetMode)?
			(0, 0):
			(0, charSize.y * -6);
		Vector2 modulesPos = (charSize.x * -4, 0);
		Vector2 lModulesPos = (-modulesPos.x, 0);
		Vector2 headerPos = (helmetsPos.x, helmetsPos.y + (charSize.y * -5));
		Vector2 hudScale = (hh_managerscale, hh_managerscale);

		int commonFlags = sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER | sb.DI_ITEM_CENTER_BOTTOM;
		int moduleFlags = sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_RIGHT | sb.DI_ITEM_CENTER;
		int lModuleFlags = sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_LEFT | sb.DI_ITEM_CENTER;

		HHBaseHelmet selHelmet = GetHelmet();

		// Header
		string headerText =
			(_helmetMode)?
			Stringtable.Localize("$HHManager_HMHeader"):
			Stringtable.Localize("$HHManager_MMHeader");
		sb.DrawString(
			sb.pSmallFont,
			headerText,
			headerPos,
			commonFlags,
			scale: hudScale
		);

		if (!GetHelmet())
		{
			sb.DrawString(
				sb.pSmallFont,
				Stringtable.Localize("$HHManager_NoHelmets"),
				(0, 0),
				commonFlags,
				scale: hudScale
			);
			return;
		}

		// Helmet position stuff
		Vector2 helmetSize = TexMan.GetScaledSize(selHelmet.Icon) * hh_managerscale;
		Vector2 helmetNamePos =
			(_helmetMode)?
			(helmetsPos.x, helmetsPos.y + (charSize.y * 3)):
			(helmetsPos.x, helmetsPos.y + (charSize.y * 1));

		// Draw current helmet
		sb.DrawString(
			sb.pSmallFont,
			selHelmet.GetTag(),
			helmetNamePos,
			commonFlags,
			Font.CR_WHITE,
			scale: hudScale
		);
		sb.DrawImage(
			TexMan.GetName(selHelmet.Icon),
			helmetsPos,
			commonFlags,
			scale: hudScale
		);
		sb.DrawString(
			sb.mIndexFont,
			string.Format("%d", selHelmet.Mags[selHelmet.Mags.Size() - 1]),
			(helmetsPos.x + (helmetSize.x / 2), helmetsPos.y),
			commonFlags,
			Font.CR_SAPPHIRE,
			scale: hudScale
		);

		// Count helmets?
		if (_HelmetMode)
		{
			sb.DrawString(
				sb.pSmallFont,
				string.Format("x%d", selHelmet.Amount),
				(helmetsPos.x, helmetsPos.y + (charSize.y * 4)),
				commonFlags,
				Font.CR_FIRE,
				scale: hudScale
			);
		}

		// Draw other helmets
		if (_HelmetMode)
		{
			if (selHelmet.Mags.Size() > 1)
			{
				int hSpacing = charSize.x * 6;
				// Left
				sb.DrawImage(
					TexMan.GetName(selHelmet.Icon),
					(helmetsPos.x - hSpacing, helmetsPos.y),
					commonFlags,
					0.50,
					scale: hudScale
				);
				sb.DrawString(
					sb.mIndexFont,
					string.Format("%d", selHelmet.Mags[selHelmet.Mags.Size() - 2]),
					(helmetsPos.x - hSpacing + (helmetSize.x / 2), helmetsPos.y),
					commonFlags,
					Font.CR_SAPPHIRE,
					0.50,
					scale: hudScale
				);

				// Right
				sb.DrawImage(
					TexMan.GetName(selHelmet.Icon),
					(helmetsPos.x + hSpacing, helmetsPos.y),
					commonFlags,
					0.50,
					scale: hudScale
				);
				sb.DrawString(
					sb.mIndexFont,
					string.Format("%d", selHelmet.Mags[0]),
					(helmetsPos.x + hSpacing + (helmetSize.x / 2), helmetsPos.y),
					commonFlags,
					Font.CR_SAPPHIRE,
					0.50,
					scale: hudScale
				);
			}

			// Draw other helmet types
			string nextHelm = GetNextHelmet();
			string prevHelm = GetNextHelmet(true);
			if (nextHelm != SelectedHelmet || prevHelm != SelectedHelmet)
			{
				if (nextHelm == SelectedHelmet)
					nextHelm = prevHelm;

				else if (prevHelm == SelectedHelmet)
					prevHelm = nextHelm;

				sb.DrawImage(
					TexMan.GetName(Owner.FindInventory(nextHelm).Icon),
					(helmetsPos.x, helmetsPos.y - (charSize.y * 2)),
					commonFlags,
					0.50,
					scale: hudScale
				);
				sb.DrawImage(
					TexMan.GetName(Owner.FindInventory(prevHelm).Icon),
					(helmetsPos.x, helmetsPos.y + (charSize.y * 2)),
					commonFlags,
					0.50,
					scale: hudScale
				);
			}
		}
		else if (selHelmet.ModuleLimit <= 0)
		{
			sb.DrawString(
				sb.pSmallFont,
				Stringtable.Localize("$HHManager_ModulesNotSupported"),
				(0, 0),
				commonFlags,
				scale: hudScale
			);
		}
		else
		{
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

			// Modules on person
			if (_Modules.Size() == 0)
			{
				sb.DrawString(
					sb.pSmallFont,
					Stringtable.Localize("$HHManager_NoModules"),
					modulesPos,
					moduleFlags,
					scale: hudScale
				);
			}
			else
			{
				int modListSize =
					(_Modules.Size() >= 5)? 5:
					(_Modules.Size() > 1)? 3:
					1;
				float modDrawOffset =
					(modListSize == 5)? charSize.y * -4:
					(modListSize == 3)? charSize.y * -2:
					0;

				for (int i = 0; i < modListSize; i++)
				{
					int offset = i - (modListSize >= 3) - (modListSize >= 5);
					int actualIndex = _ModuleIndex + offset;

					if (actualIndex < 0)
						actualIndex = _Modules.Size() + offset;

					if (!_Modules[actualIndex])
						return;

					string moduleName = _Modules[actualIndex].GetTag();
					if (offset == 0) moduleName = moduleName.." <";

					sb.DrawString(
						sb.pSmallFont,
						moduleName,
						(modulesPos.x, modulesPos.y + modDrawOffset),
						moduleFlags
					);

					modDrawOffset += charSize.y * 2;
				}
			}

			// Modules in helmet
			HHModuleStorage loadedModules = GetModuleStorage(selHelmet);
			if (loadedModules.Modules.Size() == 0)
			{
				sb.DrawString(
					sb.pSmallFont,
					Stringtable.Localize("$HHManager_NoModulesLoaded"),
					lModulesPos,
					lModuleFlags,
					scale: hudScale
				);
			}
			else
			{
				int modListSize =
					(loadedModules.Modules.Size() >= 5)? 5:
					(loadedModules.Modules.Size() > 1)? 3:
					1;
				float modDrawOffset =
					(modListSize == 5)? charSize.y * -4:
					(modListSize == 3)? charSize.y * -2:
					0;

				for (int i = 0; i < modListSize; i++)
				{
					int offset = i - (modListSize >= 3) - (modListSize >= 5);
					int actualIndex = _ModuleIndex + offset;

					if (actualIndex < 0)
						actualIndex = loadedModules.Modules.Size() + offset;

					if (!loadedModules.Modules[actualIndex])
						return;

					string moduleName = GetDefaultByType(loadedModules.Modules[actualIndex]).GetTag();
					if (offset == 0)
						moduleName = "> "..moduleName;

					sb.DrawString(
						sb.pSmallFont,
						moduleName,
						(lModulesPos.x, lModulesPos.y + modDrawOffset),
						lModuleFlags,
						scale: hudScale
					);

					modDrawOffset += charSize.y * 2;
				}
			}
		}
	}

	// Updates SelectedHelmet, in case that helmet is no longer valid
	private void UpdateHelmet()
	{
		if (Owner.FindInventory(SelectedHelmet))
			return;

		for (int i = 0; i < _Helmets.Size(); i++)
		{
			if (!Owner.FindInventory(_Helmets[i]))
				continue;

			SelectedHelmet = _Helmets[i];
			return;
		}
	}

	private clearscope HHBaseHelmet GetHelmet()
	{
		return HHBaseHelmet(Owner.FindInventory(SelectedHelmet));
	}

	private clearscope string GetNextHelmet(bool reverse=false)
	{
		// Get the current helmet pos
		int step = (reverse)? -1 : 1;
		int selIndex;
		for (selIndex = 0; selIndex < _Helmets.Size(); selIndex++)
		{
			if (_Helmets[selIndex] == SelectedHelmet)
				break;
		}

		// Now search for the next helmet
		for (int i = selIndex + step; i != selIndex; i += step)
		{
			// clamp
			if (i < 0)
				i = _Helmets.Size() - 1;

			else if (i >= _Helmets.Size())
				i = 0;

			if (Owner.FindInventory(_Helmets[i]))
				return _Helmets[i];
		}

		// Couldn't find another helmet, return the original
		return SelectedHelmet;
	}

	// Should only be called by Use state :]
	static void ManageHelmet(HHBaseHelmet helmetType)
	{
		let master = HDPlayerPawn(helmetType.Owner);
		if (!master)
			return;

		let manager = HHManager(master.FindInventory("HHManager"));
		if (!manager)
			return;

		manager.SelectedHelmet = helmetType.GetClassName();
		master.UseInventory(manager);
	}

	private void UpdateModuleList()
	{
		_Modules.Clear();

		Inventory next = Owner.Inv;
		while (next)
		{
			if (next is "HHBaseModule")
				_Modules.Push(HHBaseModule(next));

			next = next.Inv;
		}
	}

	private action void A_HMReady()
	{
		Invoker.UpdateHelmet();
		HHBaseHelmet helmet = Invoker.GetHelmet();

		if (helmet && !Invoker._HelmetMode) Invoker.UpdateModuleList();

		// Change modes
		if (JustPressed(BT_ZOOM))
		{
			Invoker._HelmetMode = !Invoker._HelmetMode;
			Invoker._ModuleIndex = 0;
			Invoker._LoadedModuleIndex = 0;
		}
		else if (PressingFiremode())
		{
			if (Invoker._helmetMode)
			{
				// Change helmet type
				if (JustPressed(BT_ATTACK))
					Invoker.SelectedHelmet = Invoker.GetNextHelmet();

				else if (JustPressed(BT_ALTATTACK))
					Invoker.SelectedHelmet = Invoker.GetNextHelmet(true);
			}
			else if (helmet)
			{
				// Cycle through loaded modules
				if (JustPressed(BT_ATTACK))
				{
					++Invoker._LoadedModuleIndex;
					if (Invoker._LoadedModuleIndex >= Invoker.GetModuleStorage(helmet).Modules.Size())
						Invoker._LoadedModuleIndex = 0;
				}
				else if (JustPressed(BT_ALTATTACK))
				{
					--Invoker._LoadedModuleIndex;
					if (Invoker._LoadedModuleIndex < 0)
						Invoker._LoadedModuleIndex = Invoker.GetModuleStorage(helmet).Modules.Size() - 1;
				}
			}
		}
		else if (JustPressed(BT_RELOAD) && helmet)
		{
			// Wear / Load
			if (Invoker._HelmetMode)
			{
				// Wear Helmet
				helmet.TryWearHelmet();
			}
			else
			{
				// Load Module
				HHModuleStorage moduleStorage = Invoker.GetModuleStorage(helmet);
				if (moduleStorage.Modules.Size() == 0)
					return;

				Invoker._Modules[Invoker._ModuleIndex].TryLoadModule(moduleStorage, HDPlayerPawn(Invoker.Owner));
			}
		}
		else if (JustPressed(BT_UNLOAD))
		{
			// Remove
			if (Invoker._HelmetMode)
			{
				// Helmet
				let wornHelm = HHBaseHelmetWorn(HHFunc.FindHelmet(Invoker.Owner));
				if (wornHelm)
					Invoker.Owner.DropInventory(wornHelm);

				else
					Invoker.Owner.A_Log(Stringtable.Localize("$HHManager_NotWearingHelmet"));
			}
			else if (helmet)
			{
				// Modules
				HHModuleStorage moduleStorage = Invoker.GetModuleStorage(helmet);
				if (moduleStorage.Modules.Size() == 0)
					return;

				let module = GetDefaultByType(moduleStorage.Modules[Invoker._LoadedModuleIndex]);
				module.TryUnloadModule(moduleStorage, Invoker._LoadedModuleIndex, HDPlayerPawn(Invoker.Owner));
			}
		}
		else if (JustPressed(BT_ATTACK))
		{
			// Cycle left
			if (Invoker._HelmetMode)
			{
				// Helmet
				if (!helmet)
					return;

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
			// Cycle right
			if (Invoker._HelmetMode)
			{
				// Helmet
				if (!helmet)
					return;

				Array<int> tmpMags;
				for (int i = 1; i < helmet.Mags.Size(); i++)
				{
					tmpMags.Push(helmet.Mags[i]);
				}
				tmpMags.Push(helmet.Mags[0]);
				helmet.Mags.Move(tmpMags);
			}
			else
			{
				// Modules
			}
		}
		else A_WeaponReady();
	}

	States
	{
		Ready:
			TNT1 A 1 A_HMReady();
			goto ReadyEnd; // prevents weapon slowing you down
	}
}
