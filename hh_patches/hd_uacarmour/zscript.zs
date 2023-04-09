version "4.7"

class HHArmourOverride_HDCorporateArmourWorn : HCItemOverride
{
	override void Init(HCStatusbar sb)
	{
		Priority = 0;
		OverrideType = HCOVERRIDETYPE_ITEM;
	}

	override bool CheckItem(Inventory item)
	{
		return (item.GetClassName() == "HDCorporateArmourWorn");
	}

	override void DrawHUDStuff(HCStatusbar sb, Inventory item, int hdFlags, int gzFlags)
	{
		let arm = HDCorporateArmourWorn(hp);
		let hdp = HDPlayerPawn(arm.Owner);
		Vector2 coords =
			(hdFlags & HDSB_AUTOMAP)? (4, 86) :
			(hdFlags & HDSB_MUGSHOT)? (((sb.HudLevel == 1)? -85 : -55), -4) :
			(0, -sb.mIndexFont.mFont.GetHeight() * 2);
		sb.DrawBar(
			"CARMA0", "CARMB0",
			arm.Durability, HDCONST_CORPORATEARMOUR,
			coords, -1, sb.SHADER_VERT,
			gzFlags
		);

		if (HHFunc.FindHelmet(hdp))
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
