class HHDrawHelmet : HUDElement
{
	private HHelmetWorn _Helmet;

	override void Init(HCStatusbar sb)
	{
		ZLayer = 0;
		Namespace = "HHDrawHelmet";
	}

	override void Tick(HCStatusbar sb)
	{
		if (!sb.hpl || HDSpectator(sb.hpl))
			return;

		_Helmet = HHFunc.FindHelmet(sb.hpl);
	}

	override void DrawHUDStuff(HCStatusbar sb, int state, double ticFrac)
	{
		if (HDSpectator(sb.hpl) || !_Helmet)
			return;

		if (AutomapActive)
			_Helmet.DrawHUDStuff(sb, sb.hpl, HDSB_AUTOMAP, sb.DI_TOPLEFT);

		else if (CheckCommonStuff(sb, state, ticFrac))
			_Helmet.DrawHUDStuff(
				sb,
				sb.hpl,
				(sb.UseMugHUD)? HDSB_MUGSHOT : 0,
				sb.DI_SCREEN_CENTER_BOTTOM
			);
	}
}
