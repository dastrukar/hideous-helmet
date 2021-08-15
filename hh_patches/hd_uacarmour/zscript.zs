version "4.5"

class HHCompatHandler_HDCorporateArmour : EventHandler {
	override void WorldLoaded(WorldEvent e) {
		New("HHCompat_HDCorporateArmourWorn").armour_name = "HDCorporateArmourWorn";
		Destroy();
	}
}

class HHCompat_HDCorporateArmourWorn : HHArmourType {
	override void DrawArmour(
		HDStatusBar sb,
		HDPickup hp,
		int hdflags,
		int gzflags
	) {
		HDCorporateArmourWorn arm = HDCorporateArmourWorn(hp);
		HDPlayerPawn hdp = HDPlayerPawn(arm.Owner);
		Vector2 coords =
			(hdflags & HDSB_AUTOMAP)? (4, 86) :
			(hdflags & HDSB_MUGSHOT)? (((sb.hudlevel == 1)? -85 : -55), -4) :
			(0, -sb.mIndexFont.mFont.GetHeight() * 2);
		sb.DrawBar(
			"CARMA0", "CARMB0",
			arm.durability, HDCONST_CORPORATEARMOUR,
			coords, -1, sb.SHADER_VERT,
			gzflags
		);

		if (hdp.FindInventory("HHelmetWorn")) {
			sb.DrawString(
				sb.pNewSmallFont, sb.FormatNumber(arm.durability),
				coords + (10, -7),
				gzflags | sb.DI_ITEM_CENTER | sb.DI_TEXT_ALIGN_RIGHT,
				Font.CR_DARKGRAY, scale: (0.5, 0.5)
			);
		}
	}
}
