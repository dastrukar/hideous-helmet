// Base module class
class HHBaseModule : HDMagAmmo abstract
{
	// Mags = Durability
	int ModuleEnergy;

	property ModuleEnergy: ModuleEnergy;

	Default
	{
		HDMagAmmo.MagBulk ENC_MODULE;
		HDMagAmmo.MaxPerUnit 100; // Max durability
		HHBaseModule.ModuleEnergy 1; // Energy required for this module to function
	}

	override void Consolidate() {}

	clearscope int GetDurability()
	{
		return Mags[Mags.Size() - 1];
	}

	// Flavour text :]
	clearscope virtual string GetDurabilityStatus()
	{
		int durability = GetDurability();
		if (durability <= 25) return "Unstable";
		else if (durability <= 50) return "Damaged";
		else if (durability <= 75) return "Okay";
		else if (durability <= 95) return "Stable";
		else return "Perfect";
	}

	// This is handled here because customisability
	virtual void TryLoadModule(HHModuleStorage moduleStorage, HDPlayerPawn hdp)
	{
		SyncAmount();
		int durability = GetDurability();
		int breakChance = 100 - (durability * durability / 100);
		if (breakChance >= Random(1, 100))
		{
			BreakSelf(hdp);
			return;
		}

		// Insert the module
		moduleStorage.Modules.Push(GetClass());
		moduleStorage.Durability.Push(durability);
		TakeMag(false);
	}

	// This should only be called by HHManager
	virtual void TryUnloadModule(HHModuleStorage moduleStorage, int index, HDPlayerPawn hdp)
	{
		int durability = moduleStorage.Durability[index];
		int breakChance = 100 - (durability * durability / 100);
		if (breakChance >= Random(1, 100))
		{
			BreakSelf(hdp);
			return;
		}

		// Return the module to the player
		hdp.GiveInventory(moduleStorage.Modules[index], 1);
		let module = HHBaseModule(hdp.FindInventory(moduleStorage.Modules[index]));
		module.SyncAmount();
		moduleStorage.Modules.Delete(index);
		moduleStorage.Durability.Delete(index);
		// some stuff to prevent duping
		module.Mags.Insert(0, durability);
		module.Mags.Pop();
	}

	// Used for destroying the module with some effects
	virtual void BreakSelf(HDPlayerPawn hdp)
	{
		int rng = Random(0, 10);
		hdp.A_Log(Stringtable.Localize("$Module_BreakMsg"..rng));
		TakeMag(false);
	}

	// Special effects for those who want to draw stuff
	virtual void DoModuleEffect(Actor actor) {}

	// Generic draw stuff
	ui virtual void DoHUDStuff(HDStatusBar sb, HDPlayerPawn hdp) {}
}
