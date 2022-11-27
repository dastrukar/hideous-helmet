class HHWoundCounter : HUDElement
{
	private transient CVar _hh_showbleed;
	private transient CVar _hh_showbleedwhenbleeding;
	private transient CVar _hh_woundcounter;

	override void Init(HCStatusbar sb)
	{
		ZLayer = 0;

		Namespace = "woundcounter";
	}

	override void Tick(HCStatusbar sb)
	{
		if (!_hh_showbleed)
		{
			_hh_showbleed = CVar.GetCVar("hh_showbleed", sb.CPlayer);
			_hh_showbleedwhenbleeding = CVar.GetCVar("hh_showbleedwhenbleeding", sb.CPlayer);
			_hh_woundcounter = CVar.GetCVar("hh_woundcounter", sb.CPlayer);
		}
	}

	override void DrawHUDStuff(HCStatusbar sb, int state, double ticFrac)
	{
		if (!HHFunc.GetShowHUD(sb.hpl) || !_hh_showbleed.GetBool())
			return;

		Vector2 coords = (46, -30);
		int of = 0;
		int wounds = HDBleedingWound.WoundCount(sb.hpl);
		HDBleedingWound biggestWound = HDBleedingWound.FindBiggest(sb.hpl);

		if (_hh_showbleedwhenbleeding.GetBool() && !wounds)
			return;

		if (wounds)
		{
			sb.DrawImage(
				"BLUDC0",
				(coords.x, coords.y + 1),
				sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_LEFT_TOP,
				0.6,
				scale: (0.5, 0.5)
			);
			if (biggestWound && biggestWound.Depth)
				of = Clamp(int(biggestWound.Depth * 0.2), 1, 3);

			if (sb.hpl.Flip)
				of = -of;
		}

		sb.DrawRect(coords.x + 2, coords.y + of, 2, 6);
		sb.DrawRect(coords.x, coords.y + 2 + of, 6, 2);

		if (_hh_woundcounter.GetBool())
		{
			let wcol =
				(wounds < 1)? Font.CR_WHITE :
				(biggestWound && biggestWound.Depth)? Font.CR_RED :
				Font.CR_FIRE;

			sb.DrawString(
				sb.mIndexFont,
				sb.FormatNumber(wounds, 3),
				coords + (8, 1),
				sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_LEFT,
				wcol
			);
		}
	}
}
