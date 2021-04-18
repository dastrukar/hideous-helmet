// This code is very hacky, might be a bit messy -dastrukar
// Original code taken from Hideous Destructor

class HHelmet:HDMagAmmo{
	default{
		+inventory.invbar
		+hdpickup.cheatnogive
		+hdpickup.notinpockets
		+inventory.isarmor
		inventory.amount 1;
		hdmagammo.maxperunit 50;
		hdmagammo.magbulk 100;
		tag "helmet";
		inventory.icon "HELMA0";
		inventory.pickupmessage "Picked up the HUD helmet.";
	}
	int cooldown;

	override bool isused(){return true;}
	override int getsbarnum(int flags){
		int ms=mags.size()-1;
		if(ms<0)return -1000000;
		return mags[ms]%1000;
	}

	override void AddAMag(int addamt){
		if(addamt<0)addamt=50;
		mags.push(addamt);
		amount=mags.size();
	}

	override void MaxCheat(){
		syncamount();
		for(int i=0;i<amount;i++){
			mags[i]=50;
		}
	}

	action void A_WearArmour(){
		bool helptext=!!player&&cvar.getcvar("hd_helptext",player).getbool();
		invoker.syncamount();
		int dbl=invoker.mags[invoker.mags.size()-1];
		//if holding use, cycle to next armour
		if(!!player&&player.cmd.buttons&BT_USE){
			invoker.mags.insert(0,dbl);
			invoker.mags.pop();
			invoker.syncamount();
			return;
		}

		//strip intervening items on doubleclick
		if(
			invoker.cooldown<1
			&&self.findinventory("HHelmetWorn")
		){
			self.dropinventory(self.findinventory("HHelmetWorn"));
			self.A_Log("Removing helmet first.", true);
			invoker.cooldown=10;
			return;
		}
		if(self.findinventory("HHelmetWorn"))return;

		//and finally put on the actual armour
		HDArmour.ArmourChangeEffect(self);
		let worn=HHelmetWorn(GiveInventoryType("HHelmetWorn"));
		worn.durability=dbl;
		invoker.amount--;
		invoker.mags.pop();

		if(helptext){
			string blah=string.format("You put on the helmet.");
			double qual=double(worn.durability)/50;
			if(qual<0.1)A_Log(blah.." Just don't get hit.",true);
			else if(qual<0.3)A_Log(blah.." Does this helmet even work?",true);
			else if(qual<0.6)A_Log(blah.." It's better than nothing.",true);
			else if(qual<0.75)A_Log(blah.." This helmet has definitely seen better days.",true);
			else if(qual<0.95)A_Log(blah.." Seems to be fine.",true);
			else A_Log(blah,true);
		}

		invoker.syncamount();
	}

	override void doeffect(){
		if(cooldown>0)cooldown--;
		if(!amount)destroy();
	}

	override void actualpickup(actor other,bool silent){
		other.A_Log(string.format("magsize %d", mags.size()));
		other.A_Log(string.format("amount: %d", amount));
		cooldown=0;
		if(!other)return;
		int durability=mags[mags.size()-1];
		HHelmet aaa=HHelmet(other.findinventory("HHelmet"));
		//put on the armour right away
		if(
			other.player&&other.player.cmd.buttons&BT_USE
			&&!aaa
		){
			HDArmour.ArmourChangeEffect(other);
			let worn=HDArmourWorn(other.GiveInventoryType("HHelmetWorn"));
			worn.durability=durability;
			destroy();
			return;
		}
		if(!trypickup(other))return;
		aaa=HHelmet(other.findinventory("HHelmet"));
		aaa.syncamount();
		other.A_StartSound(pickupsound,CHAN_AUTO);
		other.A_Log(string.format("\cg%s",pickupmessage()),true);
	}
	override void beginplay(){
		cooldown=0;
		super.beginplay();
	}
	override void consolidate(){}
	override double getbulk(){
		syncamount();
		double blk=0;
		for(int i=0;i<amount;i++){
			blk+=100;
		}
		return blk;
	}
	override void syncamount(){
		if(amount<1){destroy();return;}
		super.syncamount();
		icon=texman.checkfortexture("HELMA0",TexMan.Type_MiscPatch);
		for(int i=0;i<amount;i++){
			mags[i]=min(mags[i],50);
		}
	}
	states{
	spawn:
		HELM A -1;
		stop;
	use:
		TNT1 A 0 A_WearArmour();
		fail;
	}
}

class HHelmetWorn:HDArmourWorn {
	default{
		tag "helmet";
	}

	override void beginplay(){
		durability=50;
		super.beginplay();
	}
	override void postbeginplay(){
		super.postbeginplay();
	}
	override double getbulk(){
		return 100;
	}
	override inventory CreateTossable(int amt){
		//if(HDPlayerPawn.CheckStrip(owner,STRIP_ARMOUR))return null;

		//armour sometimes crumbles into dust
		if(durability<random(1,3)){
			for(int i=0;i<10;i++){
				actor aaa=spawn("WallChunk",owner.pos+(0,0,owner.height-24),ALLOW_REPLACE);
				vector3 offspos=(frandom(-12,12),frandom(-12,12),frandom(-16,4));
				aaa.setorigin(aaa.pos+offspos,false);
				aaa.vel=owner.vel+offspos*frandom(0.3,0.6);
				aaa.scale*=frandom(0.8,2.);
			}
			destroy();
			return null;
		}

		//finally actually take off the armour
		HDArmour.ArmourChangeEffect(owner);
		let tossed=HHelmet(owner.spawn("HHelmet",
			(owner.pos.x,owner.pos.y,owner.pos.z+owner.height-20),
			ALLOW_REPLACE
		));
		tossed.mags.clear();
		tossed.mags.push(durability);
		tossed.amount=1;
		destroy();
		return tossed;
	}
}

class HudHelmet:HDPickupGiver{
	default{
		//$Category "Items/Hideous Destructor"
		//$Title "Hud Helmet"
		//$Sprite "ARMCA0"
		+hdpickup.fitsinbackpack
		+inventory.isarmor
		inventory.icon "HELMA0";
		hdpickupgiver.pickuptogive "HHelmet";
		hdpickup.bulk 100;
		hdpickup.refid "hdh";
		tag "hud helmet (spare)";
		inventory.pickupmessage "Picked up the HUD helmet.";
	}
	override void configureactualpickup(){
		let aaa=HHelmet(actualitem);
		aaa.mags.clear();
		aaa.mags.push(50);
		aaa.syncamount();
	}
}

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
			ga.durability=50;
		}
		destroy();
	}
}
