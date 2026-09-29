class HHArmourOverride_HDArmourWorn : HCItemOverride
{
	override void Init(HCStatusbar sb)
	{
		Priority = 0;
		OverrideType = HCOVERRIDETYPE_ITEM;
	}

	override bool CheckItem(Inventory item)
	{
		return (item.GetClassName() == "HDArmourWorn");
	}

	override void DrawHUDStuff(HCStatusbar sb, Inventory item, int hdFlags, int gzFlags)
	{
		let arm = HDArmourWorn(item);
		Vector2 coords =
			(hdFlags & HDSB_AUTOMAP)? (4, 86) :
			(hdFlags & HDSB_MUGSHOT)? (((sb.HudLevel == 1)? -85 : -55), -4) :
			(0, -sb.mIndexFont.mFont.GetHeight() * 2);
		sb.DrawBar(
			arm.armourSprite, arm.armourBack,
			arm.Durability, arm.default.durability,
			coords, -1, sb.SHADER_VERT,
			gzFlags | sb.DI_TRANSLATABLE
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
