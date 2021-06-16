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
        Tag "hud helmet";
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

        // Strip worn helmet on double click
        if (
            invoker.cooldown > 0 &&
            self.FindInventory("HHelmetWorn")
        ) {
            self.DropInventory(self.FindInventory("HHelmetWorn"));
            return;
        }
        if (HDPlayerPawn(self).striptime > 0) {
            return;
        }
        if (self.FindInventory("HHelmetWorn")) {
            invoker.cooldown = 10;
            return;
        }

        //and finally put on the actual armour
        HDArmour.ArmourChangeEffect(self);
        let worn = HHelmetWorn(GiveInventoryType("HHelmetWorn"));
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
            other.player && other.player.cmd.buttons & BT_USE &&
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

class HHelmetWorn : HDArmourWorn {
    int headshots;
    int bodyshots;
    int headdamage;
    int bodydamage;

    Default {
        HDPickup.refid "hhw";
        HDPickup.wornlayer 0;
        Tag "hud helmet";
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
        let hdp = HDPlayerPawn(Owner);
        if (hdp.striptime > 0) {
            return null;
        }

        PrintHelmetDebug();

        //armour sometimes crumbles into dust
        if (durability < random(1,5)) {
            for (int i = 0; i < 10; i++) {
                Actor aaa = Spawn("WallChunk", Owner.pos + (0, 0, Owner.height - 24), ALLOW_REPLACE);
                Vector3 offspos = (FRandom(-12, 12), FRandom(-12, 12), FRandom(-16, 4));
                aaa.setorigin(aaa.pos + offspos, false);
                aaa.vel = Owner.vel + offspos * FRandom(0.3, 0.6);
                aaa.scale *= FRandom(0.8 ,2.);
            }
            BreakSelf();
            return null;
        }

        //finally actually take off the armour
        HDArmour.ArmourChangeEffect(Owner);
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

    // For convenience
    void BreakSelf() {
        PrintHelmetDebug();
        Owner.A_StartSound("helmet/break", CHAN_BODY);
        HDArmour.ArmourChangeEffect(Owner);
        Destroy();
    }

    // Handle damage
    override int,name,int,int,int,int,int HandleDamage(
        int damage,
        name mod,
        int flags,
        actor inflictor,
        actor source,
        int towound,
        int toburn,
        int tostun,
        int tobreak
    ) {
        // "I don't really know how to get this working with the damage system here,
        //  so I'll just do it the really dumb and simple way."
        bool damagetaken;
        let dmgdiff = durability;

        float h_defense = 1.3;
        float durability_dmg = max(0, damage>>random(3,5));

        // I don't think I need this for now.
        /*if(
            mod=="teeth"||
            mod=="claws"||
            mod=="bite"||
            mod=="scratch"||
            mod=="nails"||
            mod=="natural"
        ){
            damage/=h_defense;
            helmet.durability -= durability_dmg;
            damagetaken = true;
        }else*/ if (
            mod == "thermal" ||
            mod == "fire"    ||
            mod == "ice"     ||
            mod == "heat"    ||
            mod == "cold"    ||
            mod == "plasma"  ||
            mod == "burning"
        ) {
            // ngl, i don't actually know how this works.
            // but i'm including it anyways, just in case
            if(random(0,5)){
                damage-=10;
                durability -= durability_dmg;
                damagetaken = true;
            }
        }else if(
            mod == "cutting"  ||
            mod == "slashing" ||
            mod == "piercing"
        ){
            // Stuff that armour shouldn't block, but also take damage from
            durability -= durability_dmg;
            damagetaken = true;
        }else if(
            mod != "bleedout"          &&
            mod != "internal"          &&
            mod != "invisiblebleedout" &&
            mod != "maxhpdrain"        &&
            mod != "electro"           &&
            mod != "electrical"        &&
            mod != "lightning"         &&
            mod != "bolt"              &&
            mod != "balefire"          &&
            mod != "hellfire"          &&
            mod != "unholy"            &&
            mod != "staples"           &&
            mod != "falling"           &&
            mod != "drowning"          &&
            mod != "slime"             &&
            mod != "bashing"           &&
            mod != "Melee"
        ){
            // Basically any other damage type that armour should block
            //damage/=h_defense;
            durability -= durability_dmg;
            damagetaken = true;
        }
        //if (damagetaken && hd_debug) { DoHelmetDebug(dmgdiff-durability, mod); }
        if (durability < 1) {
            BreakSelf();
        }
        return damage, mod, flags, towound, toburn, tostun, tobreak;
    }

    override double, double OnBulletImpact(
        HDBulletActor bullet,
        double pen,
        double penshell,
        double hitangle,
        double deemedwidth,
        vector3 hitpos,
        vector3 vu,
        bool hitactoristall
    ) {
        let hitactor = Owner;
        if (!hitactor) {
            return 0, 0;
        }

        let hdmb = HDMobBase(hitactor);
        let hdp = HDPlayerPawn(hitactor);
        double hitheight = hitactoristall? ((hitpos.z - hitactor.pos.z) / hitactor.height) : 0.5;

        // If standing right over an incap'd victim, bypass armour
        if (
            bullet.pitch > 80 &&
            (
                (hdp && hdp.incapacitated) ||
                (
                    hdmb &&
                    hdmb.frame >= hdmb.downedframe &&
                    hdmb.InStateSequence(hdmb.curstate, hdmb.ResolveState("falldown"))
                )
            )
        ) {
            return pen, penshell;
        }

        // i mean, do you really expect a damaged helmet to block damage as well as it should?
        // Note: Helmet can still fail even at max durability, though you'd have to be REALLY unlucky for that to happen.
        float sucks = durability * FRandom(0.4, 1.8);
        if (hd_debug) {
            Console.PrintF(hitactor.GetClassName().."  helmet sucks:  "..sucks);
        }

        float helmetshell = (sucks > 25)? FRandom(15, 20) : FRandom(5, 10);
        bool headshot = (hitheight > 0.8);
        bool legshot  = (hitheight < 0.5);
        if (legshot) {
            // don't protect the legs
            helmetshell = 0;
        } else if (!headshot) {
            // imagine that the helmet has a magical net
            // also, enemies don't always aim for your "head" anyways, so it's kind of pointless for it to just protect the "head"
            helmetshell *= 0.7;
        }

        string debug_text;
        if (hd_debug && headshot) {
            debug_text = "HEADSHOT.";
        } else if (hd_debug && legshot) {
            debug_text = "leg shot.";
        } else if (hd_debug) {
            debug_text = "body shot.";
        }

        if (debug_text) {
            Console.PrintF(""..debug_text);
        }

        // durability stuff
        if (helmetshell > 0) {
            // helmet takes some damage
            int ddd = Random(-1, (int(Min(pen, helmetshell) * bullet.stamina) >> 12));

            if (hd_debug) {
                Console.PrintF("Random(Min("..pen..", "..helmetshell..") * "..bullet.stamina.." >> 12) = "..ddd);
            }

            if (ddd < 1) {
                bool penetrated = (pen > helmetshell);
                if (headshot) {
                    if (
                        penetrated ||
                        FRandom(0, 1) <= 0.25
                    ) {
                        // 25% chance to damage the helmet if shot in the face
                        ddd = 1;
                    }
                } else if (
                    penetrated &&
                    FRandom(0, 1) <= 0.50
                ) {
                    // 50% chance to not damage the helmet if you got hit in the chest
                    ddd = 1;
                }
            }
            if (ddd > 0) {
                durability -= ddd;
                if (hd_debug) {
                    Console.PrintF("helmet took "..ddd.." damage");
                }

                if (headshot) {
                    headdamage += ddd;
                } else {
                    bodydamage += ddd;
                }
            }

            // For debugging
            if (headshot) {
                headshots++;
            } else {
                bodyshots++;
            }
        } else if (hd_debug) {
            Console.PrintF("missed the helmet!");
        }

        if (hd_debug) {
            Console.PrintF(hitactor.getclassname().."  helmet resistance:  "..helmetshell);
        }
        penshell += helmetshell;

        // Helmet can't take it anymore :[
        if (durability < 1) {
            BreakSelf();
        }

        if (
            penshell > pen &&
            hitactor.health > 0 &&
            hitactoristall
        ) {
            hitactor.vel+=vu*0.001*hitheight*mass;
            if (
                hdp &&
                !hdp.incapacitated
            ) {
                hdp.hudbobrecoil2 += (FRandom(-5., 5.),FRandom(2.5, 4.)) * 0.01 * hitheight * mass;
                hdp.PlayRunning();
            } else if (Random(0, 255) < hitactor.painchance) {
                HDMobBase.ForcePain(hitactor);
            }
        }

        return pen, penshell;
    }

    // Sometimes, reading through the debug log is not worth it
    void PrintHelmetDebug() {
        if (hd_debug) {
            Console.PrintF("Helmet stats:\n Headshots: "..headshots.."("..headdamage..")\n Bodyshots: "..bodyshots.."("..bodydamage..")");
        }
    }

    void DoHelmetDebug(
        int actualdamage,
        name mod
    ) {
        A_Log("damage before: "..damage);
        A_Log("helmet took "..actualdamage.." "..mod.." damage");
        A_Log(string.format("damage %d", damage));
    }
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
