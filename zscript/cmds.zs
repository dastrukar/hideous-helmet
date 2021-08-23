class HHHandlers:EventHandler {
	override void NetworkProcess(ConsoleEvent e) {
		let player = HDPlayerPawn(players[e.player].mo);
		if (!player) return;

		bool alive = player.health > 0;

		if (alive && e.name ~== "hh_strip") {
			HHelmetWorn helmet = HHelmetWorn(HHFunc.FindHelmet(player));
			if (helmet) {
				player.DropInventory(helmet);
			} else if (player.FindInventory("HHelmet", true)) {
				player.UseInventory(player.FindInventory("HHelmet", true));
			}
		}
	}
}
