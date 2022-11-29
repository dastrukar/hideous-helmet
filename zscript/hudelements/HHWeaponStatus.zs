class HHWeaponStatus : HUDWeaponStatus
{
	private Service _HHFunc;
	private transient CVar _hh_hidefiremode;

	override void Tick(HCStatusbar sb)
	{
		if (!_HHFunc)
			_HHFunc = ServiceIterator.Find("HHFunc").Next();

		if (!_hh_hidefiremode)
			_hh_hidefiremode = CVar.GetCVar("hh_hidefiremode", sb.CPlayer);
	}

	override void DrawHUDStuff(HCStatusbar sb, int state, double ticFrac)
	{
		if (!HDWeapon(sb.CPlayer.ReadyWeapon))
			return;

		if (_HHFunc.GetIntUI("CheckWeaponStuff", objectArg: sb))
		{
			Super.DrawHUDStuff(sb, state, ticFrac);
			return;
		}
		else if (!_hh_hidefiremode.GetBool())
			_HHFunc.GetIntUI("GetWeaponFiremode", objectArg: sb);
	}
}
