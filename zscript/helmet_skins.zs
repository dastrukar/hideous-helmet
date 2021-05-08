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
            string noskin = CVar.GetCVar("hh_nohelmskin", players[p[i]]).GetString();
            string skin   = CVar.GetCVar("hh_helmetskin", players[p[i]]).GetString();
            HDArmourWorn helmet = HDArmourWorn(players[p[i]].mo.findinventory("HHelmetWorn"));

            if (helmet && skin != "") CVar.GetCVar("hd_skin", players[p[i]]).SetString(skin);
            else if (noskin != "") CVar.GetCVar("hd_skin", players[p[i]]).SetString(noskin);
        }
    }
}
