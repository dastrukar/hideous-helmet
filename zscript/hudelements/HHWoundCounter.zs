class HHWoundCounter : HUDElement
{
	private transient CVar _hh_showbleed;
	private transient CVar _hh_showbleedwhenbleeding;
	private transient CVar _hh_woundcounter;
	private transient CVar _hh_onlyshowopenwounds;
	private transient CVar _hh_wc_usedynamiccol;
	private string _WoundCounter;

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
			_hh_onlyshowopenwounds = CVar.GetCVar("hh_onlyshowopenwounds", sb.CPlayer);
			_hh_wc_usedynamiccol = CVar.GetCVar("hh_wc_usedynamiccol", sb.CPlayer);
		}

		if (!sb.hpl)
			return;

		int openWounds = 0;
		int patchedWounds = 0;
		int sealedWounds = 0;
		let ti = ThinkerIterator.Create("HDBleedingWound", Thinker.STAT_DEFAULT);
		HDBleedingWound wound;
		while (wound = HDBleedingWound(ti.Next()))
		{
			if (wound.Bleeder != sb.hpl)
				return;

			if (wound.Depth == 0 && wound.Patched == 0)
				++sealedWounds;

			else if (wound.Depth == 0)
				++patchedWounds;

			else
				++openWounds;
		}

		_WoundCounter = "";
		if (openWounds > 0)
			_WoundCounter = string.Format("\c[Red]%s \c-", sb.FormatNumber(openWounds, 3));

		if (patchedWounds > 0 && !_hh_onlyshowopenwounds.GetBool())
			_WoundCounter = string.Format("%s\c[Fire]%s \c-", _WoundCounter, sb.FormatNumber(patchedWounds, 3));

		if (sealedWounds > 0 && !_hh_onlyshowopenwounds.GetBool())
			_WoundCounter = string.Format("%s\c[Gray]%s \c-", _WoundCounter, sb.FormatNumber(sealedWounds, 3));

		if (openWounds == 0 && patchedWounds == 0 && sealedWounds == 0)
			_WoundCounter = "\c[Gray]  0\c-";
	}

	override void DrawHUDStuff(HCStatusbar sb, int state, double ticFrac)
	{
		if (!HHFunc.GetShowHUD(sb.hpl) || !_hh_showbleed.GetBool())
			return;

		Vector2 coords = (46, -30);
		int of = 0;
		HDBleedingWound biggestWound = HDBleedingWound.FindBiggest(sb.hpl);

		if (_hh_showbleedwhenbleeding.GetBool() && _WoundCounter == "\c[Gray]  0\c-")
			return;

		if (biggestWound)
		{
			sb.DrawImage(
				"BLUDC0",
				(coords.x, coords.y + 1),
				sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_ITEM_LEFT_TOP,
				0.6,
				scale: (0.5, 0.5)
			);
			of = Clamp(int(biggestWound.Depth * 0.2), 1, 3);

			if (sb.hpl.Flip)
				of = -of;
		}

		Color fillColour =
			(sb.hpl.Health > 70 || !_hh_wc_usedynamiccol.GetBool())? Color(255, sb.SBColour.R, sb.SBColour.G, sb.SBColour.B) :
			(sb.hpl.Health > 33)? Color(255, 240, 210, 10) :
			Color(255, 220, 0, 0);

		int fillFlags = sb.DI_SCREEN_CENTER_BOTTOM;
		sb.Fill(
			fillColour,
			coords.x + 2,
			coords.y + of,
			2,
			6,
			fillFlags
		);
		sb.Fill(
			fillColour,
			coords.x,
			coords.y + 2 + of,
			6,
			2,
			fillFlags
		);

		if (_hh_woundcounter.GetBool())
		{
			sb.DrawString(
				sb.mIndexFont,
				_WoundCounter,
				coords + (8, 1),
				sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_LEFT
			);
		}
	}
}
