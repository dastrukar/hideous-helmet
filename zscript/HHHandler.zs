// Handles the "hh_strip" command
class HHHandler : EventHandler
{
	override void NetworkProcess(ConsoleEvent e)
	{
		let player = HDPlayerPawn(Players[e.Player].mo);
		if (!player) return;

		if (player.Health > 0 && e.Name ~== "hh_strip")
		{
			HHelmetWorn helmet = HHelmetWorn(HHFunc.FindHelmet(player));
			if (helmet) player.DropInventory(helmet);
			else if (player.FindInventory("HHelmet", true)) player.UseInventory(player.FindInventory("HHelmet", true));
		}
	}
}
