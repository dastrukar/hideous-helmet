class HHelmetSkins:EventHandler {
    array<int> p;
    // Yeah, not very good, but it works
    override void PlayerEntered(PlayerEvent e) { p.push(e.PlayerNumber); }
    override void PlayerDisconnected(PlayerEvent e) {
        for (int i; i < p.size(); i++) {
            if (p[i] == e.PlayerNumber) p.delete(i);
        }
    }

    // Set the skin stuff
    override void WorldTick() {
        for (int i; i < p.size(); i++) {
            PlayerInfo player = players[p[i]];

            bool hh_changeskin = CVar.GetCVar("hh_changeskin", player).GetBool()
            if (hh_changeskin) {
                string noskin = CVar.GetCVar("hh_nohelmskin", player).GetString();
                string skin   = CVar.GetCVar("hh_helmetskin", player).GetString();
                HHelmetWorn helmet = HHelmetWorn(player.mo.findinventory("HHelmetWorn"));

                if (helmet) CVar.GetCVar("hd_skin", player).SetString(skin);
                else CVar.GetCVar("hd_skin", player).SetString(noskin);
            }
        }
    }
}
