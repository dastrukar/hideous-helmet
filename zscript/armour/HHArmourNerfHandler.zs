// Automatically gives anything that inherits from "HDMobBase" HHArmourNerf
// Even if they have a helmet/don't have armour, as HHArmourNerf does some checks on its own
class HHArmourNerfHandler : EventHandler
{
	override void WorldTick()
	{
		if (!hh_nerfarmour) return;

		// Loop through all the players
		for (int i; i < MAXPLAYERS; i++)
		{
			let hdp = HDPlayerPawn(Players[i].mo);

			// Check for armour
			if (!(
				hdp &&
				!hdp.FindInventory("HHArmourNerf") &&
				HHFunc.CheckForArmour(hdp)
			)) continue;

			hdp.GiveInventory("HHArmourNerf", 1);
			if (hh_debug) Console.PrintF("Gave Nerf to "..CVar.GetCVar("name", players[i]).GetString());
		}
	}

	// Enemies must suffer as much as you
	override void WorldThingSpawned(WorldEvent e)
	{
		let T = e.Thing;

		if (hh_nerfarmour && T is "HDMobBase")
		{
			if (hh_debug) Console.PrintF("Gave Nerf to "..T.GetClassName());
			T.GiveInventory("HHArmourNerf", 1);
		}
	}
}
