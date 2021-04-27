// ------------------------------------------------------------
// Because HD weapons aren't complicated enough.
// ------------------------------------------------------------
extend class HDStatusBar{
	virtual void drawweaponstatus(weapon w){
		let hdw=hdweapon(w);
		if(hdw&&CheckWeaponStuff(w)){
			if(hdw)hdw.DrawHUDStuff(self,hdw,hpl);else{
				if(cplayer.readyweapon.ammotype1)drawwepnum(
					hpl.countinv(cplayer.readyweapon.ammotype1),
					getdefaultbytype(w.ammotype1).maxamount
				);
				if(cplayer.readyweapon.ammotype2)drawwepnum(
					hpl.countinv(cplayer.readyweapon.ammotype2),
					getdefaultbytype(w.ammotype2).maxamount,
					posy:-10
				);
			}
		}else if(hdw){
			GetWeaponFiremode(hdw);
		}
	}
	void drawwepnum(int value,double mxval,int posx=-16,int posy=-6,bool alwaysprecise=false){
		int maxvalue=int(mxval);
		if(!maxvalue)return;
			//the only purpose for this not being int is so I can enter double constants
			//into this argument and not get truncation warnings that I have no need for here
		hdplayerpawn cp=hdplayerpawn(cplayer.mo);if(!cp)return;
		double valx=
			!alwaysprecise&&(
				hudlevel==1
				||cplayer.buttons&BT_ATTACK
				||cplayer.buttons&BT_ALTATTACK
			)
			?max(((value*6/maxvalue)<<2),(value>0)):
			(value*24/maxvalue)
		;
		drawrect(
			posx,posy,
			max(-24,-valx),-2
		);
		if(valx>24)fill(
			color(255,240,230,40),
			posx-24,posy,
			-1,-2,
			DI_SCREEN_CENTER_BOTTOM|DI_ITEM_RIGHT
		);
	}
	//"" means ignore this value and move on to the next check.
	//"blank" means stop here and render nothing.
	//(do we really need 6???)
	void drawwepcounter(
		int input,
		int posx,int posy,
		string zero="",string one="",string two="",string three="",
		string four="",string five="",string six="",
		bool binary=false
	){
		string types[7];types[0]=zero;types[1]=one;types[2]=two;
		types[3]=three;types[4]=four;types[5]=five;types[6]=six;
		input=min(input,6);
		string result="";
		for(int i=input;i>=0;i--){
			if(input==i){
				if(types[i]=="blank")break;
				else if(types[i]=="")input--;
				else result=types[i];
			}
		}
		if(result!="")drawimage(
			result,
			(posx,posy),
			DI_SCREEN_CENTER_BOTTOM|DI_TRANSLATABLE|DI_ITEM_RIGHT
		);
	}
	//return value of the mag that would be selected on reload
	int GetNextLoadMag(hdmagammo maggg){
		if(!maggg||maggg.mags.size()<1)return -1;
		int maxperunit=maggg.maxperunit;
		int maxindex=maggg.mags.find(maxperunit);
		if(maxindex==maggg.mags.size())return maggg.mags[0];
		return maxperunit;
	}

	bool CheckWeaponStuff(weapon w){
		if(w&&w!=WP_NOCHANGE){
			let helmet=HDArmourWorn(cplayer.mo.findinventory("HHelmetWorn"));
			bool is_gun = (
				(hh_hideslot1.getbool() && w.slotnumber == 1) ||
				(hh_hideslot2.getbool() && w.slotnumber == 2) ||
				(hh_hideslot3.getbool() && w.slotnumber == 3) ||
				(hh_hideslot4.getbool() && w.slotnumber == 4) ||
				(hh_hideslot5.getbool() && w.slotnumber == 5) ||
				(hh_hideslot6.getbool() && w.slotnumber == 6) ||
				(hh_hideslot7.getbool() && w.slotnumber == 7) ||
				(hh_hideslot8.getbool() && w.slotnumber == 8) ||
				(hh_hideslot9.getbool() && w.slotnumber == 9) ||
				(hh_hideslot0.getbool() && w.slotnumber == 0)
			);
			if (helmet||!is_gun) return true;
		}
		return false;
	}

	// I can't determine what int the weapon uses for its firemode,
	// so it's better to just let the user handle it.
	//
	// If you wish to add your own stuff,
	// just add a text file starting with: hh_firemodecodes
	// ending with whatever suffix you desire.
	//
	// Please don't name your text file "hh_firemodecodes.txt",
	// or you'll end up overwriting the default settings.
	// Please always use a suffix of your own choice, thanks.
	void GetWeaponFiremode(hdweapon hdw){
		string fm=Wads.ReadLump(Wads.CheckNumForName("hh_firemodecodes",0));
		array<string> text;text.clear();
		array<string> img;img.clear();
		int id;
		int check;
		fm.split(text,";");

		// Get the segments
		for(int i=0;i<text.size();i++){
			array<string> temp;temp.clear();
			text[i].split(temp,":");
			if(temp[0].length()>3) temp[0].remove(0,temp[0].length()-3);

			if(temp[0]==hdw.refid){
				id=temp[1].toint(10);
				temp[2].split(img,",");
				break;
			}
		}

		string types[7];
		if(img.size()<=7) for(int i=0;i<img.size();i++){types[i]=img[i];}
		else for(int i=0;i<=6;i++){types[i]=img[i];}
		drawwepcounter(
			hdw.weaponstatus[id],
			-22,-10,
			types[0], types[1], types[2], types[3], types[4], types[5], types[6]
		);
	}
}
