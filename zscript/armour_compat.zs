// this event handler only exists to create some thinkers
class HHCompatHandler : EventHandler {
	override void WorldLoaded(WorldEvent e) {
		let C = HHArmourType(New("HHCompat_HDArmourWorn"));
		C.armour_name = "HDArmour";
		C.armour_wornname = "HDArmourWorn";
		Destroy(); // don't waste memory on this single use eventhandler
	}
}

class HHCompat_HDArmourWorn : HHArmourType {
	override void DrawArmour(
		HDStatusBar sb,
		HDPickup hp,
		int hdflags,
		int gzflags
	) {
		HDArmourWorn arm = HDArmourWorn(hp);
		HDPlayerPawn hdp = HDPlayerPawn(arm.Owner);
		Vector2 coords =
			(hdflags & HDSB_AUTOMAP)? (4, 86) :
			(hdflags & HDSB_MUGSHOT)? (((sb.hudlevel == 1)? -85 : -55), -4) :
			(0, -sb.mIndexFont.mFont.GetHeight() * 2);
		string armoursprite = (arm.mega)? "ARMCA0" : "ARMSA0";
		string armourback = (arm.mega)? "ARMER1" : "ARMER0";
		sb.DrawBar(
			armoursprite, armourback,
			arm.durability, (arm.mega)? HDCONST_BATTLEARMOUR : HDCONST_GARRISONARMOUR,
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
