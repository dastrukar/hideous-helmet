// Shows your HUD
class HUDModule : HHBaseModule
{
	Default
	{
		HHBaseModule.ModuleEnergy 5;
		Tag "$HUDModule_Name";
	}

	override void DoHUDStuff(HDStatusBar sb, HDPlayerPawn hdp)
	{
		sb.ShowHud = true;
	}
}
