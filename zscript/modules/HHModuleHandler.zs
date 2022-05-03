// stupid handler that gives internal modules to helmets
class HHModuleHandler : EventHandler
{
	override void WorldThingSpawned(WorldEvent e)
	{
		let helmet = HHBaseHelmet(e.Thing);
		if (!(helmet is "HHBaseHelmet")) return;
	}
}
