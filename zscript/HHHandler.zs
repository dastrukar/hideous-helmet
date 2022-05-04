// Handles the "hh_strip" command and gives the player a helmet manager
class HHHandler : EventHandler
{
	override void PlayerSpawned(PlayerEvent e)
	{
		let player = HDPlayerPawn(Players[e.PlayerNumber].mo);
		if (!player || player.FindInventory("HHHelmetManager")) return;

		player.GiveInventory("HHHelmetManager", 1);
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		let player = HDPlayerPawn(Players[e.Player].mo);
		if (!player) return;

		if (player.Health > 0 && e.Name ~== "hh_strip")
		{
			let helmet = HHBaseHelmetWorn(HHFunc.FindHelmet(player));
			if (helmet) player.DropInventory(helmet);
			//else if (player.FindInventory("HHelmet", true)) player.UseInventory(player.FindInventory("HHelmet", true));
		}
	}
}