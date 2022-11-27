class HHEKG : HUDEKG
{
	private transient CVar _hh_hidestatus;

	override void Tick(HCStatusbar sb)
	{
		if (!_hh_hidestatus)
			_hh_hidestatus = CVar.GetCVar("hh_hidestatus", sb.CPlayer);
	}

	override void DrawHUDStuff(HCStatusbar sb, int state, double ticFrac)
	{
		if (!HHFunc.GetShowHUD(sb.hpl) && _hh_hidestatus.GetBool())
			return;

		Super.DrawHUDStuff(sb, state, ticFrac);
	}
}
