class HudHelmetGiver : HDPickupGiver
{
	Default
	{
		+HDPickup.FITSINBACKPACK
		+Inventory.ISARMOR
		Inventory.Icon "HELMA0";
		HDPickupGiver.PickupToGive "HHelmet";
		HDPickup.RefId "hdh";
		Tag "HUD Helmet (spare)";
		Inventory.PickupMessage "Picked up the HUD helmet.";
	}

	override void ConfigureActualPickup()
	{
		let helm = HudHelmet(ActualItem);
		helm.Mags.Clear();
		helm.Mags.Push(HHCONST_HUDHELMET);
		helm.SyncAmount();
	}
}
