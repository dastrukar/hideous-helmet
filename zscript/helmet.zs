// This code is very hacky, might be a bit messy -dastrukar
// Original code taken from Hideous Destructor

// HDMagAmmo is used, due to how backpacks handle icons for HDArmour

const HHCONST_HUDHELMET = 50;
const ENC_HUDHELMET = 200;

class HHelmet : HDMagAmmo{
    Default{
        +Inventory.INVBAR
        +HDPickup.CHEATNOGIVE
        +HDPickup.NOTINPOCKETS
        +Inventory.ISARMOR
        Inventory.amount 1;
        HDMagammo.maxperunit HHCONST_HUDHELMET;
        HDMagammo.magbulk ENC_HUDHELMET;
        Tag "helmet";
        Inventory.icon "HELMA0";
        Inventory.pickupmessage "Picked up the HUD helmet.";
    }
    int cooldown;

    override bool IsUsed() {
        return true;
    }

    override int GetSBarNum(int flags) {
        int ms = mags.size() - 1;
        if (ms<0) {
            return -1000000;
        } else {
            return mags[ms]%1000;
        }
    }

    override void AddAMag(int addamt) {
        if (addamt<0) {
            addamt=HHCONST_HUDHELMET;
        }
        mags.Push(addamt);
        amount = mags.Size();
    }

    override void MaxCheat(){
        SyncAmount();
        for (int i = 0; i < amount; i++) {
            mags[i] = HHCONST_HUDHELMET;
        }
    }

    action void A_WearArmour() {
        bool helptext = (!!player && CVar.GetCvar("hd_helptext", player).GetBool());
        invoker.SyncAmount();
        int dbl = invoker.mags[invoker.mags.Size() - 1];
        //if holding use, cycle to next armour
        if (!!player && player.cmd.buttons & BT_USE) {
            invoker.mags.Insert(0, dbl);
            invoker.mags.Pop();
            invoker.SyncAmount();
            return;
        }

        //strip intervening items on doubleclick
        if (
            invoker.cooldown < 1 &&
            self.FindInventory("HHelmetWorn")
        ){
            self.DropInventory(self.FindInventory("HHelmetWorn"));
            self.A_Log("Removing helmet first.", true);
            invoker.cooldown = 10;
            return;
        }
        if (
            self.FindInventory("HHelmetWorn") ||
            HDPlayerPawn(self).striptime > 0
        ) {
            return;
        }

        //and finally put on the actual armour
        HDArmour.ArmourChangeEffect(self);
        let worn=HHelmetWorn(GiveInventoryType("HHelmetWorn"));
        worn.durability = dbl;
        invoker.amount--;
        invoker.mags.Pop();

        if (helptext) {
            string blah = string.Format("You put on the helmet.");
            double qual = double(worn.durability) / HHCONST_HUDHELMET;
            if (qual < 0.2) A_Log(blah.." Just don't get hit.", true);
            else if (qual < 0.3) A_Log(blah.." Does this helmet even work?", true);
            else if (qual < 0.5) A_Log(blah.." It's better than nothing.", true);
            else if (qual < 0.7) A_Log(blah.." This helmet has definitely seen better days.", true);
            else if (qual < 0.9) A_Log(blah.." Seems to be fine.", true);
            else A_Log(blah, true);
        }

        invoker.SyncAmount();
    }

    override void DoEffect(){
        if (cooldown>0) {
            cooldown--;
        }
        if (!amount) {
            Destroy();
        }
    }

    override void ActualPickup(actor other,bool silent){
        cooldown = 0;
        if (!other) {
            return;
        }
        int durability = mags[mags.Size() - 1];
        //put on the armour right away
        if (
            other.player && other.player.cmd.buttons&BT_USE &&
            !other.FindInventory("HHelmetWorn") &&
            HDPlayerPawn(other).striptime == 0
        ) {
            HDArmour.ArmourChangeEffect(other);
            let worn = HDArmourWorn(other.GiveInventoryType("HHelmetWorn"));
            worn.durability = durability;
            Destroy();
            return;
        }
        if(!trypickup(other))return;
        HHelmet aaa = HHelmet(other.findinventory("HHelmet"));
        aaa.SyncAmount();
        aaa.mags.Insert(0, durability);
        aaa.mags.Pop();
        other.A_StartSound(pickupsound, CHAN_AUTO);
        other.A_Log(string.Format("\cg%s", PickupMessage()), true);
    }

    override void BeginPlay(){
        cooldown = 0;
        Super.BeginPlay();
    }

    override void Consolidate() {}

    override double GetBulk(){
        SyncAmount();
        double blk = 0;
        for (int i = 0; i < amount; i++) {
            blk += ENC_HUDHELMET;
        }
        return blk;
    }

    override void SyncAmount() {
        if (amount<1) {
            Destroy();
            return;
        }
        Super.SyncAmount();
        icon = TexMan.CheckForTexture("HELMA0", TexMan.Type_MiscPatch);
        for (int i = 0; i < amount; i++) {
            mags[i] = Min(mags[i], HHCONST_HUDHELMET);
        }
    }

    States {
        Spawn:
            HELM A -1;
            stop;
        Use:
            TNT1 A 0 A_WearArmour();
            fail;
    }
}

class HHelmetWorn:HDArmourWorn {
    Default {
        HDPickup.refid "hhw";
        Tag "helmet";
    }

    override void BeginPlay() {
        Super.BeginPlay();
        durability = HHCONST_HUDHELMET;
    }

    override void PostBeginPlay() {
        Super.PostBeginPlay();
    }

    override double GetBulk() {
        return ENC_HUDHELMET * 0.1;
    }

    override inventory CreateTossable(int amt) {
        let hdp = HDPlayerPawn(owner);
        if (hdp.striptime > 0) {
            return null;
        }

        //armour sometimes crumbles into dust
        if (durability < random(1,3)) {
            for (int i = 0; i < 10; i++) {
                Actor aaa = Spawn("WallChunk", Owner.pos + (0, 0, Owner.height - 24), ALLOW_REPLACE);
                Vector3 offspos = (FRandom(-12, 12), FRandom(-12, 12), FRandom(-16, 4));
                aaa.setorigin(aaa.pos + offspos, false);
                aaa.vel = Owner.vel + offspos * FRandom(0.3, 0.6);
                aaa.scale *= FRandom(0.8 ,2.);
            }
            Destroy();
            return null;
        }

        //finally actually take off the armour
        HDArmour.ArmourChangeEffect(owner);
        HDPlayerPawn(owner).striptime = 25;
        let tossed = HHelmet(Owner.Spawn("HHelmet",
            (Owner.pos.x, Owner.pos.y, Owner.pos.z + Owner.height - 20),
            ALLOW_REPLACE
        ));
        tossed.mags.Clear();
        tossed.mags.Push(durability);
        tossed.amount = 1;
        Owner.A_Log("Removing helmet first.", true);
        Destroy();
        return tossed;
    }

    // Handle damage
}

class HudHelmet:HDPickupGiver {
    Default {
        //$Category "Items/Hideous Destructor"
        //$Title "Hud Helmet"
        //$Sprite "ARMCA0"
        +HDPickup.FITSINBACKPACK
        +Inventory.ISARMOR
        Inventory.icon "HELMA0";
        HDPickupGiver.pickuptogive "HHelmet";
        HDPickup.bulk 100;
        HDPickup.refid "hdh";
        Tag "hud helmet (spare)";
        Inventory.pickupmessage "Picked up the HUD helmet.";
    }

    override void ConfigureActualPickup() {
        let aaa = HHelmet(actualitem);
        aaa.mags.Clear();
        aaa.mags.Push(HHCONST_HUDHELMET);
        aaa.SyncAmount();
    }
}

/*
class HudHelmetWorn:HDPickup{
    default{
        -hdpickup.fitsinbackpack
        +inventory.isarmor
        hdpickup.refid "hhw";
        tag "hud helmet";
        inventory.maxamount 1;
    }
    override void postbeginplay(){
        super.postbeginplay();
        if(owner){
            owner.A_GiveInventory("HHelmetWorn");
            let ga=HHelmetWorn(owner.findinventory("HHelmetWorn"));
            ga.durability=HHCONST_HUDHELMET;
        }
        Destroy();
    }
*/
}
