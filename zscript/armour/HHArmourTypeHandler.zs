// this event handler only exists to create some thinkers
class HHArmourTypeHandler : EventHandler
{
	override void WorldLoaded(WorldEvent e)
	{
		New("HHArmourType_HDArmourWorn");
		Destroy(); // don't waste memory on this single use eventhandler
	}
}
