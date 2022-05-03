// less overriding?
class HHStatusBar : HDStatusBar
{
	private HHBaseHelmetWorn helmet;

	transient cvar hh_facecam;
	transient cvar hh_hideammo;
	transient cvar hh_hidestatus;
	transient cvar hh_hidecompass;

	transient cvar hh_showbleed;
	transient cvar hh_woundcounter;
	transient cvar hh_showbleedwhenbleeding;

	transient cvar hh_hidefiremode;

	transient cvar hh_helmetoffsety;
	transient cvar hh_durabilitytop;

	override void Tick(){
		if(!didInitScopeShape){
			scopeCircleScale = (1, 1);

			let aspect = level.pixelStretch;
			if(aspect >= 1)scopeCircleScale.y /= aspect;
			else scopeCircleScale.x = aspect;

			PushCircleUVCoords(scopeCircleShape, scopeCircleScale);

			didInitScopeShape = true;
		}

		if(!hd_mugshot){
			hd_mugshot=cvar.getcvar("hd_mugshot",cplayer);
			hd_hudstyle=cvar.getcvar("hd_hudstyle",cplayer);
			hd_hudusedelay=cvar.getcvar("hd_hudusedelay",cplayer);
			hd_noscope=cvar.getcvar("hd_noscope",cplayer);
			hd_sightbob=cvar.getcvar("hd_sightbob",cplayer);
			hd_crosshair=cvar.getcvar("hd_crosshair",cplayer);
			hd_crosshairscale=cvar.getcvar("hd_crosshairscale",cplayer);
			hd_weapondefaults=cvar.getcvar("hd_weapondefaults",cplayer); //TEMPORARY - TO DELETE LATER
			hd_setweapondefault=cvar.getcvar("hd_setweapondefault",cplayer);
			hud_aspectscale=cvar.getcvar("hud_aspectscale",cplayer);
			crosshaircolor=cvar.getcvar("crosshaircolor",cplayer);

			hh_facecam=cvar.getcvar("hh_bigbrotheriswatchingyou", cplayer);
			hh_hideammo=cvar.getcvar("hh_hideammo", cplayer);
			hh_hidestatus=cvar.getcvar("hh_hidestatus", cplayer);
			hh_hidecompass=cvar.getcvar("hh_hidecompass", cplayer);

			hh_showbleed=cvar.getcvar("hh_showbleed", cplayer);
			hh_woundcounter=cvar.getcvar("hh_woundcounter", cplayer);
			hh_showbleedwhenbleeding=cvar.getcvar("hh_showbleedwhenbleeding", cplayer);

			hh_hidefiremode=cvar.getcvar("hh_hidefiremode", cplayer);

			hh_helmetoffsety=cvar.getcvar("hh_helmetoffsety", cplayer);
			hh_durabilitytop=cvar.getcvar("hh_durabilitytop", cplayer);
		}
		super.tick();
		hpl=hdplayerpawn(cplayer.mo);
		if(
			!cplayer
			||!hpl
		)return;

		sbcolour=cplayer.GetDisplayColor();

		wepsprites.clear();wepspritescales.clear();wepspriteofs.clear();wepspritecounts.clear();
		for(inventory item=cplayer.mo.inv;item!=null;item=item.inv){
			let witem=hdweapon(item);
			if(
				witem
				&&!witem.bwimpy_weapon
			){
				string wpsp;double wpscl;
				[wpsp,wpscl]=witem.getpickupsprite(true);
				if(wpsp!=""){
					int sln=witem.slotnumber*24;
					for(int i=0;i<wepspriteofs.size();i++){
						if(wepspriteofs[i]==sln)sln-=7;
					}

					int amt=(witem==cplayer.readyweapon)?0:1;
					let spw=spareweapons(cplayer.mo.findinventory("spareweapons"));
					if(spw){
						for(int i=0;i<spw.weapontype.size();i++){
							if(spw.weapontype[i]==witem.getclassname())amt++;
						}
					}
					if(amt){
						wepspritecounts.push(amt);
						wepsprites.push(wpsp);
						wepspritescales.push(wpscl);
						wepspriteofs.push(sln);
					}
				}
			}
		}

		blurred=hpl.bshadow||hpl.binvisible;

		//all the hud use timer determinations go here
		if(cplayer.buttons&BT_USE)hudusetimer++;
		else hudusetimer=0;
		int hudthreshold1=max(12,hd_hudusedelay.getint());
		int hudthreshold2=hudthreshold1%100;
		if(hudusetimer>=hudthreshold2)hudlevel=2;
		else if(hudusetimer>=hudthreshold1/100)hudlevel=1;
		else hudlevel=0;
	}
	override void Draw(int state,double TicFrac){
		hpl=hdplayerpawn(cplayer.mo);
		if(
			!cplayer
			||!hpl
		)return;
		cplayer.inventorytics=0;
		helmet=HHFunc.FindHelmet(hpl);


		if(automapactive){
			HHDrawAutomapHUD(ticfrac);
			HHDrawAutomapStuff();
		}else if(cplayer.mo==cplayer.camera){
			HHDrawAlwaysStuff();
			if(hpl.health>0){
				HHBeginHUD(forcescaled:false);

				bool usemughud=(
					hd_hudstyle.getint()==1
					||(
						state==HUD_Fullscreen
						&&!hd_hudstyle.getint()
					)
				);

				if(
					state<=HUD_Fullscreen
					&&hudlevel>0
				)HHDrawCommonStuff(usemughud);
				else{
					let www=hdweapon(cplayer.readyweapon);
					if(www&&www.balwaysshowstatus)drawweaponstatus(www);
				}
			}
		}

		//blacking out
		if(hpl.blackout>0)fill(
			color(hpl.blackout,6,2,0),0,0,screen.getwidth(),screen.getheight()
		);


		if(hpl.health<1)drawtip();
		if(idmypos)drawmypos();
	}

	void HHDrawAutomapStuff(){
		SetSize(0,480,300);
		BeginHUD();

		//KEYS!
		if(hpl.countinv("BlueCard"))drawimage("BKEYB0",(10,24),DI_TOPLEFT);
		if(hpl.countinv("YellowCard"))drawimage("YKEYB0",(10,44),DI_TOPLEFT);
		if(hpl.countinv("RedCard"))drawimage("RKEYB0",(10,64),DI_TOPLEFT);
		if(hpl.countinv("BlueSkull"))drawimage("BSKUA0",(6,30),DI_TOPLEFT);
		if(hpl.countinv("YellowSkull"))drawimage("YSKUA0",(6,50),DI_TOPLEFT);
		if(hpl.countinv("RedSkull"))drawimage("RSKUB0",(6,70),DI_TOPLEFT);

		//frags
		if(deathmatch||fraglimit>0)drawstring(
			mHUDFont,FormatNumber(CPlayer.fragcount),
			(30,24),DI_TOPLEFT|DI_TEXT_ALIGN_LEFT,
			Font.CR_RED
		);

		//mugshot
		if(helmet || !hh_facecam.getbool())
		DrawTexture(GetMugShot(5,Mugshot.CUSTOM,getmug(hpl.mugshot)),(6,-14),DI_BOTTOMLEFT,alpha:blurred?0.2:1.);

		//heartbeat/playercolour tracker
		if(hpl && hpl.beatmax)
		if(helmet||!hh_hidestatus.getbool()) {
			float cpb=hpl.beatcount*1./hpl.beatmax;
			float ysc=-(4+hpl.bloodpressure*0.05);
			if(!hud_aspectscale.getbool())ysc*=1.2;
			fill(
				color(int(cpb*255),sbcolour.r,sbcolour.g,sbcolour.b),
				32,-24-cpb*3,
				4,ysc,
				DI_BOTTOMLEFT
			);
		}
		//health
		if(hd_debug)drawstring(
			pnewsmallfont,formatnumber(hpl.health),
			(34,-24),DI_BOTTOMLEFT|DI_TEXT_ALIGN_CENTER,
			hpl.health>70?Font.CR_OLIVE:(hpl.health>33?Font.CR_GOLD:Font.CR_RED),scale:(0.5,0.5)
		);else if(helmet||!hh_hidestatus.getbool()) DrawHealthTicker((40,-24),DI_BOTTOMLEFT);

		//items
		HHDrawItemHUDAdditions(HDSB_AUTOMAP,DI_TOPLEFT);

		//inventory selector
		DrawInvSel(6,100,10,109,DI_TOPLEFT);

		//guns
		if(helmet||!hh_hideammo.getbool()) drawselectedweapon(-80,-60,DI_BOTTOMRIGHT);

		drawammocounters(-18);
		drawweaponstash(true,-48);

		if(helmet||!hh_hidecompass.getbool()) drawmypos(10);
	}

	void HHDrawAlwaysStuff(){
		if(
			hpl.health>0&&(
				hpl.binvisible
				||hpl.alpha<=0
			)
		)return;

		//reads hd_setweapondefault and updates accordingly
		if(hd_setweapondefault.getstring()!=""){
			string wpdefs=cvar.getcvar("hd_weapondefaults",cplayer).getstring().makelower();
			string wpdlastchar=wpdefs.mid(wpdefs.length()-1,1);
			while(
				wpdlastchar==" "
				||wpdlastchar==","
			){
				wpdefs=wpdefs.left(wpdefs.length()-1);
				wpdlastchar=wpdefs.mid(wpdefs.length()-1,1);
			}
			string newdef=hd_setweapondefault.getstring().makelower();
			newdef.replace(",","");
			string newdefwep=newdef.left(3);
			newdefwep.replace(" ","");
			newdefwep.replace(",","");
			if(newdefwep.length()==3){
				int whereisold=wpdefs.rightindexof(newdefwep);
				if(whereisold<0){
					wpdefs=wpdefs..","..newdef;
				}else{
					string leftofdef=wpdefs.left(whereisold);
					wpdefs=wpdefs.mid(whereisold);
					int whereiscomma=wpdefs.indexof(",");
					if(whereiscomma<0){
						if(newdef==newdefwep)wpdefs="";
						else wpdefs=newdef;
					}else{
						if(newdef==newdefwep)wpdefs=wpdefs.mid(whereiscomma);
						else wpdefs=newdef..wpdefs.mid(whereiscomma);
					}
					if(leftofdef!=""){
						wpdlastchar=leftofdef.mid(leftofdef.length()-1,1);
						while(
							wpdlastchar==" "
							||wpdlastchar==","
						){
							leftofdef=leftofdef.left(leftofdef.length()-1);
							wpdlastchar=leftofdef.mid(leftofdef.length()-1,1);
						}
						wpdefs=leftofdef..","..wpdefs;
					}
				}
				wpdefs.replace(",,",",");
				wpdlastchar=wpdefs.mid(wpdefs.length()-1,1);
				while(
					wpdlastchar==" "
					||wpdlastchar==","
				){
					wpdefs=wpdefs.left(wpdefs.length()-1);
					wpdlastchar=wpdefs.mid(wpdefs.length()-1,1);
				}

				hd_setweapondefault.setstring("");
				cvar.findcvar("hd_weapondefaults").setstring(wpdefs);
			}
		}


		//update loadout1 based on old custom
		//delete once old custom is gone!
		let lomt=LoadoutMenuHackToken(ThinkerFlag.Find(cplayer.mo,"LoadoutMenuHackToken"));
		if(lomt)cvar.findcvar("hd_loadout1").setstring(lomt.loadout);



		//draw the crosshair
		if(
			!blurred
			&&hpl.health>0
		)DrawHDXHair(hpl);



		//draw item overlays
		for(int i=0;i<hpl.OverlayGivers.size();i++){
			let ppp=hpl.OverlayGivers[i];
			if(
				ppp
				&&ppp.owner==hpl
			)ppp.DisplayOverlay(self,hpl);
		}


		//draw information text for selected weapon
		SetSize(0,320,200);
		BeginHUD(forcescaled:true);
		let hdw=HDWeapon(cplayer.readyweapon);
		if(hdw&&hdw.msgtimer>0)DrawString(
			psmallfont,hdw.wepmsg,(0,48),
			DI_SCREEN_HCENTER|DI_TEXT_ALIGN_CENTER,
			translation:Font.CR_DARKGRAY,
			wrapwidth:smallfont.StringWidth("m")*80
		);
	}
	void HHDrawCommonStuff(bool usemughud){
		let cp=HDPlayerPawn(CPlayer.mo);
		if(!cp)return;

		int mxht=-4-mIndexFont.mFont.GetHeight();
		int mhht=-4-mHUDFont.mFont.getheight();

		//inventory
		DrawSurroundingInv(25,-4,42,mxht,DI_SCREEN_CENTER_BOTTOM);
		DrawInvSel(25,-14,42,mxht,DI_SCREEN_CENTER_BOTTOM);

		//keys
		string keytype="";
		if(hpl.countinv("BlueCard"))keytype="STKEYS0";
		if(hpl.countinv("BlueSkull")){
			if(keytype=="")keytype="STKEYS3";
			else keytype="STKEYS6";
		}
		if(keytype!="")drawimage(
			keytype,
			(50,-16),
			DI_SCREEN_CENTER_BOTTOM
		);
		keytype="";
		if(hpl.countinv("YellowCard"))keytype="STKEYS1";
		if(hpl.countinv("YellowSkull")){
			if(keytype=="")keytype="STKEYS4";
			else keytype="STKEYS7";
		}
		if(keytype!="")drawimage(
			keytype,
			(50,-10),
			DI_SCREEN_CENTER_BOTTOM
		);
		keytype="";
		if(hpl.countinv("RedCard"))keytype="STKEYS2";
		if(hpl.countinv("RedSkull")){
			if(keytype=="")keytype="STKEYS5";
			else keytype="STKEYS8";
		}
		if(keytype!="")drawimage(
			keytype,
			(50,-4),
			DI_SCREEN_CENTER_BOTTOM
		);

		//health
		if(hd_debug)drawstring(
			pnewsmallfont,FormatNumber(hpl.health),
			(0,mxht),DI_TEXT_ALIGN_CENTER|DI_SCREEN_CENTER_BOTTOM,
			hpl.health>70?Font.CR_OLIVE:(hpl.health>33?Font.CR_GOLD:Font.CR_RED),scale:(0.5,0.5)
		);else if(helmet || !hh_hidestatus.getbool()) DrawHealthTicker();


		//frags
		if(deathmatch||fraglimit>0)drawstring(
			mHUDFont,FormatNumber(CPlayer.fragcount),
			(74,mhht),DI_TEXT_ALIGN_LEFT|DI_SCREEN_CENTER_BOTTOM,
			Font.CR_RED
		);


		//heartbeat/playercolour tracker
		if(hpl.beatmax)
		if(helmet || !hh_hidestatus.getbool()){
			float cpb=hpl.beatcount*1./hpl.beatmax;
			float ysc=-(3+hpl.bloodpressure*0.05);
			if(!hud_aspectscale.getbool())ysc*=1.2;
			fill(
				color(int(cpb*255),sbcolour.r,sbcolour.g,sbcolour.b),
				-12,-6-cpb*2,3,ysc, DI_SCREEN_CENTER_BOTTOM
			);
		}

		//items
		HHDrawItemHUDAdditions(
			usemughud?HDSB_MUGSHOT:0
			,DI_SCREEN_CENTER_BOTTOM
		);

		if(helmet)DrawWoundCount((46,-30));

		//weapon readouts!
		if(cplayer.readyweapon&&cplayer.readyweapon!=WP_NOCHANGE)
			drawweaponstatus(cplayer.readyweapon);

		//weapon sprite
		if(
			hudlevel==2
			||cvar.getcvar("hd_hudsprite",cplayer).getbool()
			||!cvar.getcvar("r_drawplayersprites",cplayer).getbool()
		)
		drawselectedweapon(58,-6,DI_SCREEN_CENTER_BOTTOM|DI_ITEM_LEFT_BOTTOM);

		//full hud consequences
		if(hudlevel==2){
			drawweaponstash();
			drawammocounters(mxht);

			//encumbrance
			if(hpl.enc){
				double pocketenc=hpl.pocketenc;
				drawstring(
					pnewsmallfont,formatnumber(int(hpl.enc)),
					(8,mxht),DI_TEXT_ALIGN_LEFT|DI_SCREEN_LEFT_BOTTOM,
					hpl.overloaded<0.8?Font.CR_OLIVE:hpl.overloaded>1.6?Font.CR_RED:Font.CR_GOLD,scale:(0.5,0.5)
				);
				int encbarheight=mxht+5;
				fill(
					color(128,96,96,96),
					4,encbarheight,1,-1,
					DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT
				);
				fill(
					color(128,96,96,96),
					5,encbarheight,1,-20,
					DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT
				);
				fill(
					color(128,96,96,96),
					3,encbarheight,1,-20,
					DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT
				);
				encbarheight--;
				drawrect(
					4,encbarheight,1,
					-min(hpl.maxpocketspace,pocketenc)*19/hpl.maxpocketspace,
					DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT
				);
				bool overenc=hpl.flip&&pocketenc>hpl.maxpocketspace;
				fill(
					overenc?color(255,216,194,42):color(128,96,96,96),
					4,encbarheight-19,1,overenc?3:1,
					DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT
				);
			}

			int wephelpheight=NewSmallFont.GetHeight()*5;

			//compass
			if(helmet||!hh_hidecompass.getbool()){
				int STB_COMPRAD=12;vector2 compos=(-STB_COMPRAD,STB_COMPRAD)*2;
				double compangle=hpl.angle;

				double compangle2=hpl.deltaangle(0,compangle);
				if(abs(compangle2)<120)screen.DrawText(NewSmallFont,
					font.CR_GOLD,
					600+compangle2*32/cplayer.fov,
					wephelpheight,
					"E",
					DTA_VirtualWidth,640,DTA_VirtualHeight,480
				);
				compangle2=hpl.deltaangle(-90,compangle);
				if(abs(compangle2)<120)screen.DrawText(NewSmallFont,
					font.CR_BLACK,
					600+compangle2*32/cplayer.fov,
					wephelpheight,
					"S",
					DTA_VirtualWidth,640,DTA_VirtualHeight,480
				);
				compangle2=hpl.deltaangle(180,compangle);
				if(abs(compangle2)<120)screen.DrawText(NewSmallFont,
					font.CR_RED,
					600+compangle2*32/cplayer.fov,
					wephelpheight,
					"W",
					DTA_VirtualWidth,640,DTA_VirtualHeight,480
				);
				compangle2=hpl.deltaangle(90,compangle);
				if(abs(compangle2)<120)screen.DrawText(NewSmallFont,
					font.CR_WHITE,
					600+compangle2*32/cplayer.fov,
					wephelpheight,
					"N",
					DTA_VirtualWidth,640,DTA_VirtualHeight,480
				);

				let whh=wephelpheight+NewSmallFont.GetHeight();
				screen.DrawText(NewSmallFont,
					font.CR_OLIVE,
					600,
					whh,
					"^",
					DTA_VirtualWidth,640,DTA_VirtualHeight,480
				);
				string postxt=string.format("%i,%i,%i",hpl.pos.x,hpl.pos.y,hpl.pos.z);
				screen.DrawText(NewSmallFont,
					font.CR_OLIVE,
					600-(NewSmallFont.StringWidth(postxt)>>1),
					whh+6,
					postxt,
					DTA_VirtualWidth,640,DTA_VirtualHeight,480
				);
			}

			// Draw help text
			string s=hpl.wephelptext;
			if(s!="")screen.DrawText(NewSmallFont,OptionMenuSettings.mFontColorValue,
				8,
				wephelpheight,
				s,
				DTA_VirtualWidth,640,
				DTA_VirtualHeight,480,
				DTA_Alpha,0.8
			);
		}

		if(hd_debug>=3){
			double velspd=hpl.vel.length();
			string velspdout=velspd.."   "..(velspd*HDCONST_MPSTODUPT).."mps   "..(velspd*HDCONST_MPSTODUPT*HDCONST_MPSTOKPH).."km/h";
			screen.DrawText(NewSmallFont,
				font.CR_GRAY,
				600-(NewSmallFont.StringWidth(velspdout)>>1),
				NewSmallFont.GetHeight(),
				velspdout,
				DTA_VirtualWidth,640,DTA_VirtualHeight,480
			);
		}


		bool showmug = (
			helmet ||
			!hh_facecam.getbool()
		);
		if(usemughud&&showmug)DrawTexture(
			GetMugShot(5,Mugshot.CUSTOM,getmug(hpl.mugshot)),(0,-14),
			DI_ITEM_CENTER_BOTTOM|DI_SCREEN_CENTER_BOTTOM,
			alpha:blurred?0.2:1.
		);


		//object description
		drawstring(
			pnewsmallfont,hpl.viewstring,
			(0,20),DI_SCREEN_CENTER|DI_TEXT_ALIGN_CENTER,
			Font.CR_GREY,0.4,scale:(1,1)
		);


		drawtip();

		//debug centre line
		if(hd_debug)fill(color(96,24,96,18),-0.3,0,0.6,100, DI_SCREEN_CENTER);

	}

	void DrawWoundCount(Vector2 coords){
		if(hh_showbleed.getbool()){
			int of=0;
			let wounds=hpl.woundcount;
			if(hh_showbleedwhenbleeding.getbool()&&!wounds) return;
			if(wounds){
				drawimage(
					"BLUDC0",(coords.x,coords.y+1),
					DI_SCREEN_CENTER_BOTTOM|DI_ITEM_LEFT_TOP,
					0.6,
					scale:(0.5,0.5)
				);
				of=clamp(int(wounds*0.2),1,3);
				if(hpl.flip)of=-of;
			}
			drawrect(coords.x+2,coords.y+of,2,6);
			drawrect(coords.x,coords.y+2+of,6,2);

			if(hh_woundcounter.getbool()){
				let wcol=wounds<1? Font.CR_WHITE:Font.CR_RED;
				drawstring(
					mIndexFont,
					formatnumber(wounds,3),
					coords+(8,1),
					DI_SCREEN_CENTER_BOTTOM|DI_TEXT_ALIGN_LEFT,
					wcol
				);
			}
		}
	}

	void HandleDrawArmour(
		hdpickup hp,
		hdplayerpawn hpl,
		int hdflags,
		int gzflags
	)
	{
		ThinkerIterator ti = ThinkerIterator.Create("HHArmourType");

		Thinker T;
		while (T = ti.next())
		{
			HHArmourType hhat = HHArmourType(T);
			if (hhat.GetWornName() != hp.GetClassName()) continue;
			hhat.DrawArmour(self, hp, hdflags, gzflags);
		}
	}

	void HHDrawItemHUDAdditions(int hdflags,int gzflags){
		let hpl=HDPlayerPawn(cplayer.mo);
		if(!hpl)return;
		for(let item=hpl.inv;item!=NULL;item=item.inv){
			let hp=HDPickup(item);
			if(hp){
				if (HHFunc.IsWornArmour(hp.GetClassName())) HandleDrawArmour(hp,hpl,hdflags,gzflags);
				else hp.DrawHudStuff(self,hpl,hdflags,gzflags);
			}
		}
		//helmet stuff
		if(helmet){
			helmet.DrawHudStuff(self,hpl,hdflags,gzflags);
		}
	}
}
