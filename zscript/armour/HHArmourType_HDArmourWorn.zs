class HHArmourType_HDArmourWorn : HHArmourType
{
	override string GetName()
	{
		return "HDArmour";
	}

	override string GetWornName()
	{
		return "HDArmourWorn";
	}

	override void DrawArmour(
		HDStatusBar sb,
		HDPickup hp,
		int hdFlags,
		int gzFlags
	)
	{
		let arm = HDArmourWorn(hp);
		let hdp = HDPlayerPawn(arm.Owner);
		Vector2 coords =
			(hdFlags & HDSB_AUTOMAP)? (4, 86) :
			(hdFlags & HDSB_MUGSHOT)? (((sb.HudLevel == 1)? -85 : -55), -4) :
			(0, -sb.mIndexFont.mFont.GetHeight() * 2);
		string armourSprite = (arm.Mega)? "ARMCA0" : "ARMSA0";
		string armourBack = (arm.Mega)? "ARMER1" : "ARMER0";
		sb.DrawBar(
			armourSprite, armourBack,
			arm.Durability,
			(arm.Mega)? HDCONST_BATTLEARMOUR : HDCONST_GARRISONARMOUR,
			coords, -1, sb.SHADER_VERT,
			gzFlags
		);

		if (HHFunc.GetShowHUD(sb.hpl))
		{
			sb.DrawString(
				sb.pNewSmallFont,
				sb.FormatNumber(arm.Durability),
				coords + (10, -7),
				gzFlags | sb.DI_ITEM_CENTER | sb.DI_TEXT_ALIGN_RIGHT,
				Font.CR_DARKGRAY,
				scale: (0.5, 0.5)
			);
		}
	}
}
