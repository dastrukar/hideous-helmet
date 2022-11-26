// Shows your HUD
class HUDModule : HHBaseModule
{
	int number;
	Default
	{
		HHBaseModule.ModuleEnergy 5;
		Tag "$HUDModule_Name";
	}

	override void DoModuleEffect(Actor actor)
	{
		HHBaseHelmetWorn helmet = HHFunc.FindHelmet(actor);
		if (helmet)
			helmet.ShowHUD = 2;
	}
}

// debug stuff
class HHDebug : CustomInventory
{
	Default
	{
		+Inventory.AUTOACTIVATE;
	}

	States
	{
		Use:
			TNT1 A 0
			{
				A_GiveInventory("mod1", 1);
				A_GiveInventory("mod2", 1);
				A_GiveInventory("mod3", 1);
				A_GiveInventory("mod4", 1);
			}
			stop;
	}
}

class mod1 : HUDModule
{
	Default
	{
		Tag "First mod";
	}
}
class mod2 : HUDModule
{
	Default
	{
		Tag "Second mod";
	}
}
class mod3 : HUDModule
{
	Default
	{
		Tag "Third mod";
	}
}
class mod4 : HUDModule
{
	Default
	{
		Tag "Forth mod";
	}
}
