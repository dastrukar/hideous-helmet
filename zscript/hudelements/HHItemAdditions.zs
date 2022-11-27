class HHItemAdditions : HUDItemAdditions
{
	private transient ThinkerIterator _HHArmourTypeIterator;
	private HHBaseHelmetWorn _Helmet;

	override void Tick(HCStatusbar sb)
	{
		if (!_HHArmourTypeIterator)
			_HHArmourTypeIterator = ThinkerIterator.Create("HHArmourType");

		if (sb.hpl)
			_Helmet = HHFunc.FindHelmet(sb.hpl);
	}

	override void DrawHUDStuff(HCStatusbar sb, int state, double ticFrac)
	{
		int hdFlags =
			(AutomapActive)? HDSB_AUTOMAP :
			(sb.UseMugHUD)?  HDSB_MUGSHOT :
			0;

		int gzFlags = (AutomapActive)? sb.DI_TOPLEFT : sb.DI_SCREEN_CENTER_BOTTOM;

		for (let item = sb.hpl.inv; item != NULL; item = item.inv)
		{
			let hp = HDPickup(item);
			if (!hp)
				continue;

			HHArmourType armourType = HHFunc.FindArmourType(hp.GetClassName());
			if (armourType)
				armourType.DrawArmour(sb, hp, hdFlags, gzFlags);

			else
				hp.DrawHUDStuff(sb, sb.hpl, hdFlags, gzFlags);
		}

		// Just draw the helmet again to ensure it's on top because I'm lazy
		if (_Helmet)
			_Helmet.DrawHUDStuff(sb, sb.hpl, hdFlags, gzFlags);
	}
}
