class HHelmetSkins:EventHandler {
	// Set the skin stuff
	// (Thanks Ace.)
	override void WorldTick() {
		for (int i = 0; i < MAXPLAYERS; i++) {
			// Don't null
			PlayerPawn p = players[i].mo;
			if (!p) {
				continue;
			}

			bool hh_changeskin = CVar.GetCVar("hh_changeskin", p.player).GetBool();
			if (hh_changeskin) {
				string noskin = CVar.GetCVar("hh_nohelmskin", p.player).GetString();
				string skin   = CVar.GetCVar("hh_helmetskin", p.player).GetString();
				CVar hd_skin  = CVar.GetCVar("hd_skin", p.player);

				if (HHFunc.FindHelmet(p)) {
					hd_skin.SetString(skin);
				} else {
					hd_skin.SetString(noskin);
				}
			}
		}
	}
}
