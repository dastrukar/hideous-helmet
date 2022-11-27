class HHMugshot : HUDMugshot
{
	private transient CVar _hh_bigbrotheriswatchingyou;

	override void Tick(HCStatusbar sb)
	{
		if (!_hh_bigbrotheriswatchingyou)
			_hh_bigbrotheriswatchingyou = CVar.GetCVar("hh_bigbrotheriswatchingyou", sb.CPlayer);
	}

	override void DrawHUDStuff(HCStatusbar sb, int state, double ticFrac)
	{
		if (!HHFunc.GetShowHUD(sb.hpl) && _hh_bigbrotheriswatchingyou.GetBool())
			return;

		Super.DrawHUDStuff(sb, state, ticFrac);
	}
}
