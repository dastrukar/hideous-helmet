// Handles the "hh_strip" command and gives the player a helmet manager
class HHHandler : EventHandler
{
	override void WorldLoaded(WorldEvent e)
	{
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			let player = HDPlayerPawn(Players[i].mo);
			if (!player || player.FindInventory("HHManager")) return;

			player.GiveInventory("HHManager", 1);
		}
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		let player = HDPlayerPawn(Players[e.Player].mo);
		if (!player) return;

		if (player.Health > 0 && e.Name ~== "hh_strip")
		{
			let helmet = HHBaseHelmetWorn(HHFunc.FindHelmet(player));
			HHBaseHelmet spareHelm;
			if (helmet) player.DropInventory(helmet);
			else if (spareHelm = HHBaseHelmet(player.FindInventory("HHBaseHelmet", true))) spareHelm.TryWearHelmet();
		}
	}
}
