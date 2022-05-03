// Handles all modules
class HHModuleStorage play
{
	Array< class<HHBaseModule> > Modules;
	Array<int> Durability;

	int GetPowerUsage()
	{
		int usage;
		for (int i = 0; i < PowerUsage; i++)
		{
			usage += PowerUsage[i];
		}
		return usage;
	}
}
