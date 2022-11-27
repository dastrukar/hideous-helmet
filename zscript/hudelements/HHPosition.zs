class HHPosition : HUDPosition
{
	private transient CVar _hh_hidecompass;

	override void Tick(HCStatusbar sb)
	{
		if (!_hh_hidecompass)
			_hh_hidecompass = CVar.GetCVar("hh_hidecompass", sb.CPlayer);
	}

	override void DrawHUDStuff(HCStatusbar sb, int state, double ticFrac)
	{
		if (!HHFunc.GetShowHUD(sb.hpl) && _hh_hidecompass.GetBool())
			return;

		Super.DrawHUDStuff(sb, state, ticFrac);
	}
}
