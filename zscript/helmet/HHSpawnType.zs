// Generic spawn type definition class
class HHSpawnType : Thinker abstract
{
	// Used for checking if a helmet should spawn. If returns true, SpawnHelmet() will be called.
	virtual bool CheckConditions(Actor T, int time)
	{
		return false;
	}

	virtual void SpawnHelmet(Actor T) {}
}
