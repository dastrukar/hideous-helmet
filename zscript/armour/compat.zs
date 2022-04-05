// this event handler only exists to create some thinkers
class HHCompatHandler : EventHandler
{
	override void WorldLoaded(WorldEvent e)
	{
		let C = HHArmourType(New("HHCompat_HDArmourWorn"));
		C.ArmourName = "HDArmour";
		C.ArmourWornName = "HDArmourWorn";
		Destroy(); // don't waste memory on this single use eventhandler
	}
}

class HHCompat_HDArmourWorn : HHArmourType
{
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
		string armourSprite = (arm.mega)? "ARMCA0" : "ARMSA0";
		string armourBack = (arm.mega)? "ARMER1" : "ARMER0";
		sb.DrawBar(
			armourSprite, armourBack,
			arm.Durability,
			(arm.Mega)? HDCONST_BATTLEARMOUR : HDCONST_GARRISONARMOUR,
			coords, -1, sb.SHADER_VERT,
			gzFlags
		);

		if (HHFunc.FindHelmet(hdp))
		{
			sb.DrawString(
				sb.pNewSmallFont,
				sb.FormatNumber(arm.durability),
				coords + (10, -7),
				gzFlags | sb.DI_ITEM_CENTER | sb.DI_TEXT_ALIGN_RIGHT,
				Font.CR_DARKGRAY,
				scale: (0.5, 0.5)
			);
		}
	}
}
