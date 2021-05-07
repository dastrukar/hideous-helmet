class HHHandlers:EventHandler {
	override void NetworkProcess(ConsoleEvent e) {
		let player = HDPlayerPawn(players[e.player].mo);
		if (!player) return;

		bool alive = player.health > 0;

		if (alive&&e.name~=="hh_strip") {
			if (player.FindInventory("HHelmetWorn")) {
				player.DropInventory(HHelmetWorn(player.findinventory("HHelmetWorn")));
				player.A_Log("Removing helmet first.");
			} else if (player.FindInventory("HHelmet")) player.UseInventory(player.FindInventory("HHelmet"));
		}
	}
}
