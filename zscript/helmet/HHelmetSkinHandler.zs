class HHelmetSkinHandler : EventHandler
{
	// Set the skin stuff
	// (Thanks Ace.)
	override void WorldTick()
	{
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			// Don't null
			let p = HDPlayerPawn(Players[i].mo);
			if (!p) continue;

			bool changeSkin = CVar.GetCVar("hh_changeskin", p.Player).GetBool();
			if (!changeSkin) continue;

			string noSkin = CVar.GetCVar("hh_nohelmskin", p.Player).GetString();
			string skin = CVar.GetCVar("hh_helmetskin", p.Player).GetString();
			CVar hd_skin = CVar.GetCVar("hd_skin", p.Player);

			if (HHFunc.FindHelmet(p)) hd_skin.SetString(skin);
			else hd_skin.SetString(noSkin);
		}
	}
}
