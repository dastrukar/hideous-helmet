// this is a dumb attempt to make the helmet draw on a different layer
// the draw function is actually called in hudelements/HHDrawHelmet.zs

class HHHelmetOverride : HCItemOverride
{
	override void Init(HCStatusbar sb)
	{
		Priority = 0;
		OverrideType = HCOVERRIDETYPE_ITEM;
	}

	override bool CheckItem(Inventory item)
	{
		return (item is "HHelmetWorn");
	}
}
