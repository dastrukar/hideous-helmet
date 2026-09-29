// Automatically gives anything that inherits from "HDMobBase" HHArmourNerf
// Even if they have a helmet/don't have armour, as HHArmourNerf does some checks on its own
class HHArmourNerfHandler : EventHandler
{
	// Enemies must suffer as much as you
	override void WorldThingSpawned(WorldEvent e)
	{
		// TODO: define which HDArmourWorn Subclasses should be nerfed?
		if (hh_nerfarmour && (e.Thing is "GarrisonArmourWorn" || e.Thing is "BattleArmourWorn"))
		{
			HDArmourWorn T = HDArmourWorn(e.Thing);
			T.coverage = T.coverage&~(HDArmourWorn.ARMOUR_HEAD|HDArmourWorn.ARMOUR_FACE);
		}
	}
}
