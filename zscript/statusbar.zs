#include "zscript/functions.zs"

// ------------------------------------------------------------
// HD HUD. HUD for HD. Hdhdhdhdhhdhdhhdhd
// ------------------------------------------------------------
class HDStatusBar:DoomStatusBar{
	int hudlevel;
	int hudusetimer;
	int healthbars[STB_BEATERSIZE];
	hudfont psmallfont;
	hudfont pnewsmallfont;
	hdplayerpawn hpl;
	bool blurred;
	string mug;
	int bigitemyofs;
	color sbcolour;
	hdarmourworn helmet;
	override void Init(){
		BaseStatusBar.Init();
		SetSize(0,320,200);

		//Create the font used for the fullscreen HUD
		Font fnt = "HUDFONT_DOOM";
		pSmallFont=HUDFont.Create(SmallFont);
		pNewSmallFont=HUDFont.Create(NewSmallFont);
		mHUDFont = HUDFont.Create(fnt,fnt.GetCharWidth("0"),true,1,1);
		fnt = "INDEXFONT_DOOM";
		mIndexFont = HUDFont.Create(fnt,fnt.GetCharWidth("0"),true);
		mAmountFont = HUDFont.Create("NUMFONT_DOOM");
		diparms = InventoryBarState.Create();

		//populate the list of ammo types for the ammo display
		ammotypes.clear();ammosprites.clear();ammoscales.clear();
		for(int i=0;i<allactorclasses.size();i++){
			let thisinv=(class<hdammo>)(allactorclasses[i]);
			if(thisinv){
				let thisinvd=getdefaultbytype(thisinv);
				if(thisinvd.binvbar)continue;
				let thisicon=thisinvd.icon;
				if(!thisicon.isvalid()){
					let dds=thisinvd.spawnstate;
					if(dds!=null)thisicon=dds.GetSpriteTexture(0);
				}
				if(thisicon.isvalid()){
					vector2 dds=texman.getscaledsize(thisicon);
					double ddv=0.7;
					if(max(dds.x,dds.y)<8.){
						ddv*=(8./min(dds.x,dds.y));
					}
					ammoscales.push(clamp(ddv,0.2,2.));
					ammosprites.push(texman.getname(thisicon));
					ammotypes.push(thisinv.getclassname());
				}
			}
		}
		bigitemyofs=-20;

		//build circle mask
		circleShape = new('Shape2D');
		scopeCircleShape = new('Shape2D');

		let angStep = 360. / circleVertCount;
		let ang = 0.;

		for(int i = 0; i < circleVertCount; i++){
			let vx = sin(ang)*0.5;
			let vy = cos(ang)*0.5;

			let vert = (vx, vy);

			circleVerts[i] = vert;

			circleShape.PushCoord(vert + (.5, .5));
			circleShape.PushVertex((vx, vy));

			scopeCircleShape.PushCoord(vert + (.5, .5));
			scopeCircleShape.PushVertex((vx, vy));

			if(i + 2 < circleVertCount){
				circleShape.PushTriangle(0, i + 1, i + 2);
				scopeCircleShape.PushTriangle(0, i + 1, i + 2);
			}

			ang += angStep;
		}
	}

	const circleVertCount = 24;

	Shape2D circleShape;
	vector2 circleVerts[circleVertCount];

	Shape2D scopeCircleShape; // circle with UVs scaled to match pixel ratio
	vector2 scopeCircleScale;
	bool didInitScopeShape;

	override void AttachToPlayer(PlayerInfo player){
		super.AttachToPlayer(player);
		didInitScopeShape = false;
	}

	enum HDStatBar{
		STB_COMPRAD=12,
		STB_BEATERSIZE=15,
		DI_TOPRIGHT=DI_SCREEN_RIGHT_TOP|DI_ITEM_RIGHT_TOP,
		DI_TOPLEFT=DI_SCREEN_LEFT_TOP|DI_ITEM_LEFT_TOP,
		DI_BOTTOMLEFT=DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT_BOTTOM,
		DI_BOTTOMRIGHT=DI_SCREEN_RIGHT_BOTTOM|DI_ITEM_RIGHT_BOTTOM,
	}

	//cache some cvars
	transient cvar hd_mugshot;
	transient cvar hd_hudstyle;
	transient cvar hd_hudusedelay;
	transient cvar hd_noscope;
	transient cvar hd_sightbob;
	transient cvar hd_crosshair;
	transient cvar hd_crosshairscale;
	transient cvar hd_weapondefaults; //TEMPORARY - TO DELETE LATER
	transient cvar hd_setweapondefault;
	transient cvar hud_aspectscale;

	transient cvar hh_facecam;
	transient cvar hh_hideammo;
	transient cvar hh_hidestatus;
	transient cvar hh_hidecompass;

	transient cvar hh_showbleed;
	transient cvar hh_woundcounter;
	transient cvar hh_showbleedwhenbleeding;

	transient cvar hh_hideslot1;
	transient cvar hh_hideslot2;
	transient cvar hh_hideslot3;
	transient cvar hh_hideslot4;
	transient cvar hh_hideslot5;
	transient cvar hh_hideslot6;
	transient cvar hh_hideslot7;
	transient cvar hh_hideslot8;
	transient cvar hh_hideslot9;
	transient cvar hh_hideslot0;
	transient cvar hh_hidefiremode;

	transient cvar hh_helmetoffsety;
	transient cvar hh_durabilitytop;

	void PushCircleUVCoords(Shape2D circle, vector2 scale = (1, 1)){
		circle.Clear(Shape2D.C_Coords);
		for(int i = 0; i < circleVertCount; i++){
			let vert = circleVerts[i];
			let newVert = (vert.x * scale.x, vert.y * scale.y);
			circle.PushCoord(newVert + (.5, .5));
		}
	}

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

			hh_facecam=cvar.getcvar("hh_bigbrotheriswatchingyou", cplayer);
			hh_hideammo=cvar.getcvar("hh_hideammo", cplayer);
			hh_hidestatus=cvar.getcvar("hh_hidestatus", cplayer);
			hh_hidecompass=cvar.getcvar("hh_hidecompass", cplayer);

			hh_showbleed=cvar.getcvar("hh_showbleed", cplayer);
			hh_woundcounter=cvar.getcvar("hh_woundcounter", cplayer);
			hh_showbleedwhenbleeding=cvar.getcvar("hh_showbleedwhenbleeding", cplayer);

			hh_hideslot1=cvar.getcvar("hh_hideslot1", cplayer);
			hh_hideslot2=cvar.getcvar("hh_hideslot2", cplayer);
			hh_hideslot3=cvar.getcvar("hh_hideslot3", cplayer);
			hh_hideslot4=cvar.getcvar("hh_hideslot4", cplayer);
			hh_hideslot5=cvar.getcvar("hh_hideslot5", cplayer);
			hh_hideslot6=cvar.getcvar("hh_hideslot6", cplayer);
			hh_hideslot7=cvar.getcvar("hh_hideslot7", cplayer);
			hh_hideslot8=cvar.getcvar("hh_hideslot8", cplayer);
			hh_hideslot9=cvar.getcvar("hh_hideslot9", cplayer);
			hh_hideslot0=cvar.getcvar("hh_hideslot0", cplayer);
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
				[wpsp,wpscl]=witem.getpickupsprite();
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
			DrawAutomapHUD(ticfrac);
			DrawAutomapStuff();
		}else if(cplayer.mo==cplayer.camera){
			DrawAlwaysStuff();
			if(hpl.health>0){
				BeginHUD(forcescaled:false);

				bool usemughud=(
					hd_hudstyle.getint()==1
					||(
						state==HUD_Fullscreen
						&&!hd_hudstyle.getint()
					)
				);

				if(state<=HUD_Fullscreen){
					if(hudlevel>0){
						DrawCommonStuff(usemughud);
						if(usemughud)DrawFullScreenStuff();
					}
				}
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
	void DrawAutomapStuff(){
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
		DrawItemHUDAdditions(HDSB_AUTOMAP,DI_TOPLEFT);

		//inventory selector
		DrawInvSel(6,100,10,109,DI_TOPLEFT);

		//guns
		if(helmet||!hh_hideammo.getbool()) drawselectedweapon(-80,-60,DI_BOTTOMRIGHT);

		drawammocounters(-18);
		drawweaponstash(true,-48);

		if(helmet||!hh_hidecompass.getbool()) drawmypos(10);
	}

	void DrawMyPos(int downpos=(STB_COMPRAD<<2)){
		//permanent mypos
		drawstring(
			psmallfont,string.format("%i  x",hpl.pos.x),
			(-4,downpos+10),DI_TEXT_ALIGN_RIGHT|DI_SCREEN_RIGHT_TOP,
			Font.CR_OLIVE
		);
		drawstring(
			psmallfont,string.format("%i  y",hpl.pos.y),
			(-4,downpos+18),DI_TEXT_ALIGN_RIGHT|DI_SCREEN_RIGHT_TOP,
			Font.CR_OLIVE
		);
		drawstring(
			psmallfont,string.format("%i  z",hpl.pos.z),
			(-4,downpos+26),DI_TEXT_ALIGN_RIGHT|DI_SCREEN_RIGHT_TOP,
			Font.CR_OLIVE
		);
	}
	void DrawFullScreenStuff(){
		if (helmet || !hh_facecam.getbool())
		DrawTexture(
			GetMugShot(5,Mugshot.CUSTOM,getmug(hpl.mugshot)),(0,-14),
			DI_ITEM_CENTER_BOTTOM|DI_SCREEN_CENTER_BOTTOM,
			alpha:blurred?0.2:1.
		);
	}
	string getmug(string mugshot){
		if(mugshot==HDMUGSHOT_DEFAULT)switch(cplayer.getgender()){
			case 0:return "STF";
			case 1:return "SFF";
			default:return "STC";
		}else return mugshot;
	}
	void DrawAlwaysStuff(){
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
		hudfont pSmallFont=HUDFont.Create("SmallFont");
		let hdw=HDWeapon(cplayer.readyweapon);
		if(hdw&&hdw.msgtimer>0)drawstrings(psmallfont,hdw.wepmsg,
			(0,48),DI_SCREEN_HCENTER|DI_TEXT_ALIGN_CENTER,
			wrapwidth:300
		);
	}
	void DrawCommonStuff(bool usemughud){
		let cp=HDPlayerPawn(CPlayer.mo);
		if(!cp)return;
		//DrawHelmetOverlay((0,0));

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
		DrawItemHUDAdditions(
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
					hpl.overloaded<1.2?Font.CR_OLIVE:hpl.overloaded>2.?Font.CR_RED:Font.CR_GOLD,scale:(0.5,0.5)
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
			!hh_facecam
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
	void drawtip(){
		double spectipalpha=hpl.specialtipalpha;
		if(spectipalpha>0.){
			if(spectipalpha>1000)spectipalpha=1.-(spectipalpha-1000);
			string s=hpl.specialtip;
			screen.DrawText(NewSmallFont,OptionMenuSettings.mFontColorValue,
				2,
				450-NewSmallFont.GetHeight()*5,
				s,
				DTA_VirtualWidth,600,
				DTA_VirtualHeight,450,
				DTA_Alpha,spectipalpha
			);
		}
	}
	void drawrect(
		double posx,double posy,
		double width,double height,
		int flags=DI_SCREEN_CENTER_BOTTOM
	){
		fill(color(255,sbcolour.r,sbcolour.g,sbcolour.b),posx,posy,width,height,flags);
	}
	//deprecated, please use drawrect instead
	void drawwepdot(int posx,int posy,vector2 dotscale=(3.,3.)){
		drawrect(posx-dotscale.x,posy-dotscale.y,dotscale.x,dotscale.y);
	}
	void drawnum(
		int num,double xpos,double ypos,
		int flags=DI_SCREEN_RIGHT_BOTTOM,
		int fnt=Font.CR_OLIVE,
		double alpha=1.
	){
		drawstring(
			pnewsmallfont,formatnumber(num),
			(xpos,ypos),flags|DI_TEXT_ALIGN_RIGHT,
			fnt,alpha,scale:(0.5,0.5)
		);
	}
	void DrawStrings(
		HUDFont font,
		String brokenstring,
		Vector2 pos,
		int flags=0,
		int translation=Font.CR_DARKGRAY,
		double Alpha=1.,
		int wrapwidth=-1,
		int linespacing=0
	){
		double breakspace=linespacing+smallfont.getheight();
		string stringpiece="";

		while(brokenstring.length()>0){
			int nextbreakindex=brokenstring.indexof("\n");
			if(nextbreakindex<0){
				stringpiece=brokenstring;
				brokenstring="";
			}else{
				stringpiece=brokenstring.left(nextbreakindex);
				brokenstring=brokenstring.mid(nextbreakindex+1,brokenstring.length());
			}
			DrawString(font,stringpiece,pos,flags,translation,Alpha,wrapwidth,linespacing);
			pos.y+=breakspace;
		}
	}
	void DrawHealthTicker(
		vector2 drawpos=(-3,-7),
		int flags=DI_SCREEN_CENTER_BOTTOM
	){
		let cp=hdplayerpawn(cplayer.mo);
		if(!hpl.beatcount){
			for(int i=0;i<(STB_BEATERSIZE-2);i++){
				healthbars[i]=healthbars[i+2];
			}
			int err=max(0,((100-hpl.health)>>3));
			err=random[heart](0,err);
			healthbars[STB_BEATERSIZE-2]=clamp(18-(hpl.bloodloss>>7)-(err>>2),1,18);
			healthbars[STB_BEATERSIZE-1]=(hpl.inpain?random[heart](1,7):1)+err+random[heart](0,(hpl.bloodpressure>>3));
		}
		for(int i=0;i<STB_BEATERSIZE;i++){
			int alf=(i&1)?128:255;
			fill(
				(
					cp.health>70?color(alf,sbcolour.r,sbcolour.g,sbcolour.b)
					:cp.health>33?color(alf,240,210,10)
					:color(alf,220,0,0)
				),
				drawpos.x+i-(STB_BEATERSIZE>>2),drawpos.y-healthbars[i]*0.3,
				0.8,healthbars[i]*0.6,
				flags|DI_ITEM_CENTER|(cp.health>70?DI_TRANSLATABLE:0)
			);
		}
	}
	void drawambar(
		string ongfx,string offgfx,
		class<inventory> type,
		vector2 coords,
		int flags=DI_SCREEN_RIGHT_BOTTOM|DI_ITEM_RIGHT_BOTTOM
	){
		inventory inv=cplayer.mo.findinventory(type);
		if(!inv||!inv.amount){
			drawimage(offgfx,coords,flags);
		}else{
			int arbitrarymax=inv.maxamount;
			drawbar(
				ongfx,offgfx,
				min(arbitrarymax,inv.amount),arbitrarymax,
				coords,-1,
				SHADER_VERT,flags
			);
		}
	}
	void DrawItemHUDAdditions(int hdflags,int gzflags){
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
	color savedcolour;
	void DrawInvSel(int posx,int posy,int numposx,int numposy,int flags){
		if(CPlayer.mo.InvSel){
			inventory ivs=cplayer.mo.invsel;
			let ivsh=hdpickup(ivs);
			let ivsw=hdweapon(ivs);
			drawinventoryicon(ivs,(posx,posy),
				flags|DI_ITEM_CENTER
				|((
					(ivsh&&ivsh.bdroptranslation)
					||(ivsw&&ivsw.bdroptranslation)
				)?DI_TRANSLATABLE:0)
			);

			let pivs=HDPickup(ivs);
			let piws=HDWeapon(ivs);
			savedcolour=Font.CR_SAPPHIRE;
			if(pivs){
				int pivsi=pivs.getsbarnum();
				if(pivsi!=-1000000)drawstring(
					pnewsmallfont,FormatNumber(pivsi),
					(numposx,numposy-7),flags|DI_TEXT_ALIGN_RIGHT,savedcolour,scale:(0.5,0.5)
				);
			}else if(piws){
				int piwsi=piws.getsbarnum();
				if(piwsi!=-1000000)drawstring(
					pnewsmallfont,FormatNumber(piwsi),
					(numposx,numposy-7),flags|DI_TEXT_ALIGN_RIGHT,savedcolour,scale:(0.5,0.5)
				);
			}

			savedcolour=Font.CR_OLIVE;
			int invamt=
				hdweapon(ivs)?hdweapon(ivs).displayamount():
				hdpickup(ivs)?hdpickup(ivs).displayamount():
				ivs.amount
			;
			drawstring(pnewsmallfont,FormatNumber(invamt),
				(numposx,numposy),flags|DI_TEXT_ALIGN_RIGHT,savedcolour,scale:(0.5,0.5)
			);
		}
	}
	void DrawSurroundingInv(int posx,int posy,int numposx,int numposy,int flags,int drawfull=true){
		int i=0;
		int thisindex=-1;
		inventory item;
		array<inventory> items;items.clear();
		for(item=cplayer.mo.inv;item!=NULL;item=item.inv){
			if(
				!item
				||(
					!item.binvbar
					&&item!=cplayer.mo.invsel
				)
			)continue;
			items.push(item);
			if(item==cplayer.mo.invsel)thisindex=i;

			if(drawfull&&hudlevel==2){
				textureid icon;vector2 applyscale;
				[icon,applyscale]=geticon(item,0);
				int xoffs=(i%5)*20;
				bool isthis=i==thisindex;
				let ivsh=hdpickup(item);
				let ivsw=hdweapon(item);
				drawtexture(icon,
					(-18-xoffs,bigitemyofs-20*(i/5)),
					DI_ITEM_CENTER_BOTTOM|DI_SCREEN_RIGHT_BOTTOM
					|((
						(ivsh&&ivsh.bdroptranslation)
						||(ivsw&&ivsw.bdroptranslation)
					)?DI_TRANSLATABLE:0),
					alpha:isthis?1.:0.6,scale:applyscale*(isthis?1.:0.6)
				);
			}

			i++;
		}
		if(thisindex<0||items.size()<2)return;
		int lastindex=items.size()-1;
		int previndex=thisindex?thisindex-1:lastindex;
		int nextindex=thisindex==lastindex?0:thisindex+1;
		inventory drawitems[2];
		if(items.size()>2)drawitems[0]=items[previndex];
		drawitems[1]=items[nextindex];
		for(i=0;i<2;i++){
			let thisitem=drawitems[i];
			if(!thisitem)continue;
			textureid icon;vector2 applyscale;
			[icon,applyscale]=geticon(thisitem,0);
			int xoffs=!i?-10:10;
			let ivsh=hdpickup(thisitem);
			let ivsw=hdweapon(thisitem);
			drawtexture(icon,
				(posx+xoffs,posy-17),
				flags|DI_ITEM_CENTER_BOTTOM
					|((
						(ivsh&&ivsh.bdroptranslation)
						||(ivsw&&ivsw.bdroptranslation)
					)?DI_TRANSLATABLE:0),
				alpha:0.6,scale:applyscale*0.6
			);
		}
	}
	void drawselectedweapon(int posx,int posy,int flags){
		let w=hdweapon(cplayer.readyweapon);
		if(!w)return;
		string wx;double ws=1.;
		[wx,ws]=w.getpickupsprite();
		if(wx!="")drawimage(wx,(posx,posy),flags,scale:ws?(ws,ws):(1.,1.));
	}
	array<string> wepsprites;
	array<double> wepspritescales;
	array<int> wepspriteofs;
	array<int> wepspritecounts;
	void drawweaponstash(bool rt=false,int yofs=0){
		for(int i=wepsprites.size()-1;i>=0;i--){
			double scl=wepspritescales[i];
			int xofs=rt?-8:8;
			int yofsfinal=yofs-wepspriteofs[i];
			drawimage(wepsprites[i],(xofs,yofsfinal),
				(rt?DI_SCREEN_RIGHT_BOTTOM:DI_SCREEN_LEFT_BOTTOM)|
				(rt?DI_ITEM_RIGHT:DI_ITEM_LEFT)|DI_ITEM_BOTTOM,
				scale:(scl,scl)
			);
			int count=wepspritecounts[i];
			if(count>1)drawstring(
				psmallfont,count.."x",
				(xofs-(rt?10:2),yofsfinal-3),
				(rt?DI_SCREEN_RIGHT_BOTTOM:DI_SCREEN_LEFT_BOTTOM)|
				(rt?DI_ITEM_RIGHT:DI_ITEM_LEFT)|DI_ITEM_BOTTOM|DI_TEXT_ALIGN_LEFT,
				Font.CR_DARKGRAY
			);
		}
	}
	array<string> ammosprites;
	array<string> ammotypes;
	array<double> ammoscales;
	void drawammocounters(int mxht){
		actor cp=cplayer.mo;
		int ii=0;
		for(int i=0;i<ammosprites.size();i++){
			let count=cp.countinv(ammotypes[i]);
			if(!count)continue;
			drawimage(ammosprites[i],
				(-8-(ii%SBAR_MAXAMMOCOLS)*16,mxht-(ii/SBAR_MAXAMMOCOLS)*SBAR_AMMOROW),
				DI_SCREEN_RIGHT_BOTTOM|DI_ITEM_RIGHT_BOTTOM,
				//alpha:count?1.:0.2,
				scale:(ammoscales[i],ammoscales[i])
			);
			drawstring(
				pnewsmallfont,""..count,
				(-6-(ii%SBAR_MAXAMMOCOLS)*16,mxht-(ii/SBAR_MAXAMMOCOLS)*SBAR_AMMOROW),
				DI_SCREEN_RIGHT_BOTTOM|DI_ITEM_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT,
				Font.CR_OLIVE,scale:(0.5,0.5)
			);
			ii++;
		}
		bigitemyofs=-((ii-1)/SBAR_MAXAMMOCOLS)*SBAR_AMMOROW-26;
	}
	void drawbattery(int posx,int posy,int flags=0,bool reloadorder=false){
		let hpl=hdplayerpawn(cplayer.mo);
		string cellsprite="CELLA0";
		let bttc=HDBattery(hpl.findinventory("HDBattery"));
		if(bttc&&bttc.mags.size()>0){
			if(bttc.chargemode){
				if(bttc.chargemode==HDBattery.BATT_CHARGEMAX)drawimage("CELPA0",(posx+2,posy+6),flags:flags,scale:(0.3,0.3));
				else if(bttc.chargemode==HDBattery.BATT_CHARGESELECTED)drawimage("CELPA0",(posx,posy+4),flags:flags,scale:(0.3,0.3));
			}
			int amt;
			if(reloadorder){
				amt=GetNextLoadMag(bttc);
			}else amt=bttc.mags[bttc.mags.size()-1];
			if(amt<1)cellsprite="CELLD0";
			else if(amt<=6)cellsprite="CELLC0";
			else if(amt<=13)cellsprite="CELLB0";
		}else cellsprite="CELLD0";
		drawimage(cellsprite,(posx,posy),flags:flags,alpha:bttc?1.:0.3);
	}

	void DrawCircle(TextureID tex, vector2 pos, double scale = 1, vector2 uvOffset = (0, 0), double uvScale = 1, bool center = true, bool usePixelRatio = false){
		let shape = usePixelRatio? scopeCircleShape : circleShape;

		let hudScale = GetHUDScale();

		//convert sbar coords to screen coords
		pos.x *= hudScale.x;
		pos.y *= hudScale.y;

		if(center) pos += (screen.GetWidth(), screen.GetHeight()) / 2;

		int sx, sy;
		[sx, sy] = texman.GetSize(tex);

		//offset and scale UV coords
		bool uvDirty = false;
		if(uvOffset.x != 0 || uvOffset.y != 0 || uvScale != 1){
			uvScale /= scale;

			uvOffset *= -1;

			uvOffset.x /= sx;
			uvOffset.y /= sy;

			PushCircleUVCoords(shape, (usePixelRatio? scopeCircleScale : (1, 1)) / uvScale);

			uvDirty = true;
		}

		let trans = new('Shape2DTransform');

		trans.Scale((sx * hudScale.x, sy * hudScale.y) * scale);
		trans.Translate(pos);

		shape.SetTransform(trans);
		screen.DrawShape(tex, false, shape);

		trans.Destroy();

		//reset to original UV coords
		if(uvDirty)PushCircleUVCoords(shape, usePixelRatio? scopeCircleScale : (1, 1));
	}

	enum HDSBarNums{
		SBAR_MAXAMMOCOLS=7,
		SBAR_AMMOROW=14,
	}

	// NOTE(dastrukar): please finish this :]
	void DrawHelmetOverlay(Vector2 overlaycoords){
		let helmet=HDArmourWorn(cplayer.mo.findinventory("HHelmetWorn"));
		if(helmet){
			string overlaysprite="STBAR";
			drawimage(
				overlaysprite,
				overlaycoords
			);
		}
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
	){
		ThinkerIterator ti = ThinkerIterator.Create("HHArmourType");

		Thinker T;
		while (T=ti.next()) {
			HHArmourType hhat = HHArmourType(T);
			if (hhat.armour_wornname == hp.GetClassName()) {
				hhat.DrawArmour(self, hp, hdflags, gzflags);
			}
		}
	}
}

enum HDSBarItemFlags{
	HDSB_AUTOMAP=1,
	HDSB_MUGSHOT=2,
}


//all for the blackout effect
//because A_SetBlend keeps getting overridden by other crap
extend class HDPlayerPawn{
	int blackout;
	int blackoutfull;
	int blackoutrateup;
	int blackoutratedown;
	int blackoutfulltime;
	void UpdateBlackout(){
		if(blackoutfull<1)return;

		if(blackout>=blackoutfull){
			if(blackoutfulltime>0){
				blackoutfulltime--;
				return;
			}
			blackoutrateup=blackoutratedown;
		}

		blackout+=blackoutrateup;

		if(
			blackoutrateup<0
			&&blackout<1
		){
			blackoutfull=0;
			blackoutfulltime=0;
			blackoutrateup=1;
		}
	}
	void AddBlackout(
		int bof,
		int bor,
		int bord=0,
		int boft=0
	){
		blackoutfull=clamp(abs(bof),0,256);
		blackoutrateup=max(blackoutrateup,abs(bor));
		if(!bord)bord=bor;
		blackoutratedown=-abs(bord);
		blackoutfulltime=boft;
	}
}
mixin class HDInventoryBlackoutWrapper{
	void AddBlackout(
		int bof,
		int bor,
		int bord=0,
		int boft=0
	){
		if(!owner)return;
		if(hdplayerpawn(owner))hdplayerpawn(owner).AddBlackout(bof,bor,bord,boft);
		else owner.A_SetBlend("01 00 00",0.9,256/bor);
	}
	action void A_AddBlackout(int bof,int bor,int bord=0,int boft=0){
		invoker.AddBlackout(bof,bor,bord,boft);
	}
}
extend class HDPickup{
	mixin HDInventoryBlackoutWrapper;
}
extend class HDWeapon{
	mixin HDInventoryBlackoutWrapper;
}


