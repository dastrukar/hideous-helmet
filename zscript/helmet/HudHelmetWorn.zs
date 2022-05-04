// Worn version of the Hud Helmet
class HudHelmetWorn : HHBaseHelmetWorn
{
	Default
	{
		HHBaseHelmetWorn.MaxDurability HHCONST_HUDHELMET;
		HHBaseHelmetWorn.HelmetBulk ENC_HUDHELMET / 2;
		HHBaseHelmetWorn.TossHelmet "HudHelmet";
		HDPickup.RefId "hhw";
		Tag "$HudHelmet_Name";
	}

	override void DrawHUDStuff(
		HDStatusBar sb,
		HDPlayerPawn hpl,
		int hdFlags,
		int gzFlags
	)
	{
		string helmetSprite = "HELMA0";
		string helmetBack = "HELMB0";
		bool showOnTop = sb.hh_durabilitytop.GetBool();

		Vector2 pos =
			(hdFlags & HDSB_AUTOMAP)? (24, 86) :
			(hdFlags & HDSB_MUGSHOT)? (((sb.HudLevel == 1)? -85 : -55), -18) :
			(0, -sb.mIndexFont.mFont.GetHeight() * 2 - 14);
		Vector2 coords = (pos.x, pos.y + sb.hh_helmetoffsety.GetInt());

		sb.DrawBar(
			helmetSprite, helmetBack,
			Durability, MaxDurability,
			coords, -1, sb.SHADER_VERT,
			gzFlags
		);

		if (sb.showhud) sb.DrawString(
			sb.pNewSmallFont, sb.FormatNumber(Durability),
			coords + (10, (showOnTop)? -14 : -7),
			gzFlags | sb.DI_ITEM_CENTER | sb.DI_TEXT_ALIGN_RIGHT,
			Font.CR_DARKGRAY,
			scale: (0.5, 0.5)
		);
	}
}