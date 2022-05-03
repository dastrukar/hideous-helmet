// Used for checking if someone has a helmet
class HasHelmet : InventoryFlag
{
	override void Tick()
	{
		// Drop helmet if dead
		if (!Owner && Owner.health >= 1) return;

		// If has helmet, use that for durability
		int durability;
		let helm = HHFunc.FindHelmet(Owner);
		if (helm) durability = helm.Durability;

		if (durability > 0)
		{
			Vector3 tPos = (Owner.Pos.x, Owner.Pos.y, Owner.Pos.z + 5);
			HHHelmetSpawner.SummonHelmet(durability, tPos);
		}

		Destroy();
	}
}
