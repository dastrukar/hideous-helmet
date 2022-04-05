version "4.7"

class HHArmourTypeHandler_HDHEVArmour : EventHandler
{
	override void WorldLoaded(WorldEvent e)
	{
		let C = HHArmourType(New("HHArmourType_HDHEVArmourWorn"));
		C.ArmourName = "HDHEVArmour";
		C.ArmourWornName = "HDHEVArmourWorn";
		Destroy();
	}
}

class HHArmourType_HDHEVArmourWorn : HHArmourType
{
	override void DrawArmour(
		HDStatusBar sb,
		HDPickup hp,
		int hdFlags,
		int gzFlags
	)
	{
		let arm = HDHEVArmourWorn(hp);
		let hdp = HDPlayerPawn(arm.Owner);
		Vector2 coords =
			(hdFlags & HDSB_AUTOMAP)? (4, 86) :
			(hdFlags & HDSB_MUGSHOT)? (((sb.HudLevel == 1)? -85 : -55), -4) :
			(0, -sb.mIndexFont.mFont.GetHeight() * 2);
		sb.DrawBar(
			"HEVAA0", "HEVAB0",
			arm.Durability, HDCONST_HEVARMOUR,
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
