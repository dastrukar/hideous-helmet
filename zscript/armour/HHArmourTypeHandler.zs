// this event handler only exists to create some thinkers
class HHArmourTypeHandler : EventHandler
{
	override void WorldLoaded(WorldEvent e)
	{
		let C = HHArmourType(New("HHArmourType_HDArmourWorn"));
		C.ArmourName = "HDArmour";
		C.ArmourWornName = "HDArmourWorn";
		Destroy(); // don't waste memory on this single use eventhandler
	}
}
