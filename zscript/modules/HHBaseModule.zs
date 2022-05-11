// Base module class
class HHBaseModule : HDMagAmmo abstract
{
	// Mags = Durability
	int ModuleEnergy; // Energy required for this module to function

	property ModuleEnergy: ModuleEnergy;

	Default
	{
		HDMagAmmo.MagBulk ENC_MODULE;
		HHBaseModule.ModuleEnergy 1;
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
		if (durability <= 95) return "Stable";
		else if (durability <= 75) return "Okay";
		else if (durability <= 50) return "Damaged";
		else if (durability <= 25) return "Unstable";
		else return "Perfect";
	}

	// Special effects for those who want to draw stuff
	virtual void DoModuleEffect(Actor actor) {}

	// Generic draw stuff
	ui virtual void DoHUDStuff(HDStatusBar sb, HDPlayerPawn hdp) {}
}
