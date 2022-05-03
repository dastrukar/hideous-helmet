// Base loaded module class
class HHBaseModuleLoaded play abstract
{
	int Durability;
	int ModuleEnergy; // Energy required for this module to function


	// Special effects for those who want to draw stuff
	virtual void DoModuleEffect(HDPlayerPawn hdp) {}

	// Generic draw stuff
	ui virtual void DrawHUDStuff(HDStatusBar sb) {}
}
