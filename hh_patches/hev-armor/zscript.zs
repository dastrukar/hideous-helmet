version "4.5"

class HHCompatHandler_HDHEVArmour : EventHandler {
	override void WorldLoaded(WorldEvent e) {
		let C = HHArmourType(New("HHCompat_HDHEVArmourWorn"));
		C.armour_name = "HDHEVArmour";
		C.armour_wornname = "HDHEVArmourWorn";
		Destroy();
	}
}

class HHCompat_HDHEVArmourWorn : HHArmourType {
	override void DrawArmour(
		HDStatusBar sb,
		HDPickup hp,
		int hdflags,
		int gzflags
	) {
		HDHEVArmourWorn arm = HDHEVArmourWorn(hp);
		HDPlayerPawn hdp = HDPlayerPawn(arm.Owner);
		Vector2 coords =
			(hdflags & HDSB_AUTOMAP)? (4, 86) :
			(hdflags & HDSB_MUGSHOT)? (((sb.hudlevel == 1)? -85 : -55), -4) :
			(0, -sb.mIndexFont.mFont.GetHeight() * 2);
		sb.DrawBar(
			"HEVAA0", "HEVAB0",
			arm.durability, HDCONST_HEVARMOUR,
			coords, -1, sb.SHADER_VERT,
			gzflags
		);

		if (HHFunc.FindHelmet(hdp)) {
			sb.DrawString(
				sb.pNewSmallFont, sb.FormatNumber(arm.durability),
				coords + (10, -7),
				gzflags | sb.DI_ITEM_CENTER | sb.DI_TEXT_ALIGN_RIGHT,
				Font.CR_DARKGRAY, scale: (0.5, 0.5)
			);
		}
	}
}
