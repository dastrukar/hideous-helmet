class HHHandlers:EventHandler {
	override void NetworkProcess(ConsoleEvent e) {
		let player=hdplayerpawn(players[e.player].mo);
		if (!player) return;

		bool alive = player.health > 0;

		if (alive&&e.name~=="hh_strip") {
			if(player.findinventory("HHelmetWorn")) {
				player.dropinventory(HHelmetWorn(player.findinventory("HHelmetWorn")));
				player.A_Log("Removing helmet first.");
			}
		}
	}
}
