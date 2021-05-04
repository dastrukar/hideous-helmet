class HHelmetSkins:EventHandler {
    // Set the skin stuff
    override void WorldTick() {
        PlayerInfo player = players[consoleplayer];
        if (player) {
            string noskin = CVar.GetCVar("hh_nohelmskin", player).GetString();
            string skin   = CVar.GetCVar("hh_helmetskin", player).GetString();
            HDArmourWorn helmet = HDArmourWorn(player.mo.findinventory("HHelmetWorn"));

            if (helmet && skin != "") CVar.GetCVar("hd_skin", player).SetString(skin);
            else if (noskin != "") CVar.GetCVar("hd_skin", player).SetString(noskin);
        }
    }
}
