// UAC "Heads Up Display(HUD)" Helmet MKIV
// =======================================
// The UAC Helmet MKIV, unlike its previous models, was designed to be somewhat lightweight and versetile.
// While not as strong as its older counterparts, the helmet is still capable enough to stop most common bullets flying towards someone's head.
// Commonly dubbed "Heads Up Display(HUD) Helmet", the MKIV comes with a new advanced module system that allows it accept more modules than ever before.
// Also, the MKIV used to have more processing power in the past. However, due to budget constraints, only a few were ever made.
class HudHelmet : HHBaseHelmet
{
	Default
	{
		Tag "HUD Helmet";
		HDPickup.RefId "hdh";
		Inventory.Icon "HELMA0";
		Inventory.PickupMessage "Picked up the HUD Helmet.";
		HDMagammo.MaxPerUnit HHCONST_HUDHELMET; // Max durability
		HDMagammo.MagBulk ENC_HUDHELMET; // Weight per helmet
		HHBaseHelmet.WornHelmet "HudHelmetWorn"; // Which helmet to wear?
		HHBaseHelmet.ModuleLimit 20; // How much module points?
	}

	override string GetFlavourText()
	{
		return "This is a HUD Helmet.";
	}
}
