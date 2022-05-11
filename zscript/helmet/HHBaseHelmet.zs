// This code is very hacky, might be a bit messy -dastrukar
// Original code taken from Hideous Destructor

// HDMagAmmo is used, due to how backpacks handle icons for HDArmour
class HHBaseHelmet : HDMagAmmo abstract
{
	protected class<HHBaseHelmetWorn> _WornHelmet;

	int ModuleLimit;
	HHModuleStorage ModuleStorage;
	HHModuleStorage InternalModuleStorage;

	property WornHelmet: _WornHelmet;
	property ModuleLimit: ModuleLimit;

	Default
	{
		+Inventory.INVBAR;
		+HDPickup.CHEATNOGIVE;
		+HDPickup.NOTINPOCKETS;
		-HDPickup.FITSINBACKPACK; // Putting the helmet into a backpack will delete modules
		+Inventory.ISARMOR;
		Inventory.Amount 1;

		// set it yourself you lazy prick
		Tag "Helmet";
		HDPickup.RefId "";
		Inventory.Icon "HELMA0";
		Inventory.PickupMessage "Picked up a helmet.";
		HDMagammo.MaxPerUnit 0; // Max durability
		HDMagammo.MagBulk 0; // Weight per helmet
		HHBaseHelmet.WornHelmet ""; // Which helmet to wear?
		HHBaseHelmet.ModuleLimit 0; // How much module points?
	}

	// This is only called if hd_helptext is true
	virtual string GetFlavourText()
	{
		return "This helmet be looking real fine.";
	}

	override void BeginPlay()
	{
		Super.BeginPlay();
		ModuleStorage = HHModuleStorage(new("HHModuleStorage"));
		InternalModuleStorage = HHModuleStorage(new("HHModuleStorage"));

		// shit hack
		let m = HHBaseModule(Actor.Spawn("HUDModule", Pos));
		InternalModuleStorage.Modules.Push(m.GetClass());
		InternalModuleStorage.Durability.Push(100);
		m.Destroy();
	}

	override int GetSBarNum(int flags)
	{
		return Mags[Mags.Size() - 1];
	}

	override bool IsUsed()
	{
		return true;
	}

	override void AddAMag(int addAmt)
	{
		if (addAmt < 0) addAmt = MaxPerUnit;
		Mags.Push(addAmt);
		Amount = Mags.Size();
	}

	override void MaxCheat()
	{
		SyncAmount();
		for (int i = 0; i < Amount; i++) Mags[i] = MaxPerUnit;
	}

	override void ActualPickup(Actor other, bool silent)
	{
		if (!other) return;

		int durability = Mags[Mags.Size() - 1];
		// Put on the helmet right away?
		if (
			other.Player &&
			other.Player.Cmd.Buttons & BT_USE &&
			!other.FindInventory("HHBaseHelmetWorn", true) &&
			HDPlayerPawn(other).StripTime == 0
		)
		{
			HDArmour.ArmourChangeEffect(other);
			let worn = HHBaseHelmetWorn(other.GiveInventoryType(_wornHelmet));
			worn.Durability = durability;
			Destroy();
			return;
		}

		if (!TryPickup(other)) return;

		let helmet = HHBaseHelmet(other.FindInventory(self.GetClassName()));
		helmet.SyncAmount();
		helmet.Mags.Insert(0, durability);
		helmet.Mags.Pop();
		other.A_StartSound(PickupSound, CHAN_AUTO);
		other.A_Log(string.Format("\cg%s", PickupMessage(), true));
	}

	override void Consolidate() {} // Don't consolidate :]

	override double GetBulk()
	{
		SyncAmount();
		return MagBulk * Amount;
	}

	override void SyncAmount()
	{
		if (Amount < 1)
		{
			Destroy();
			return;
		}

		Super.SyncAmount();
		for (int i = 0; i < Amount; i++) Mags[i] = Min(Mags[i], MaxPerUnit);
	}

	virtual void TryWearHelmet()
	{
		let hdp = HDPlayerPawn(Owner);
		if (!hdp || hdp.StripTime > 0) return;

		// Remove any worn helmets
		let curWornHelm = HHBaseHelmetWorn(HHFunc.FindHelmet(hdp));
		if (curWornHelm)
		{
			hdp.DropInventory(curWornHelm);
			return;
		}

		// Put on the helmet
		HDArmour.ArmourChangeEffect(hdp);
		let wornHelm = HHBaseHelmetWorn(hdp.GiveInventoryType(_WornHelmet));
		wornHelm.Durability = Mags[Mags.Size() - 1];
		wornHelm.ModuleStorage = ModuleStorage;
		wornHelm.InternalModuleStorage = InternalModuleStorage;

		hdp.A_Log(string.Format("You put on the %s.", GetTag()));

		Amount--;
		Mags.Pop();

		SyncAmount();
	}

	States
	{
		Use:
			TNT1 A 0 { HHManager.ManageHelmet(Invoker); }
			fail;
	}
}
