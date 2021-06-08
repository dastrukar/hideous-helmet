// Basically the loadout menu, but worse
class HHWhitelistMenu : GenericMenu {
    array<string> refids;
    array<string> names;
    string new_wl;
    string whitelist;
    string undo;
    string loadoutcodes;
    string refidlist;
    string translatedlist;
    int cursorx;
    int cursory;
    int blinktimer;
    bool diff;
    bool viewlist;
    PlayerInfo cplayer;

    override void Init(menu parent) {
        Super.Init(parent);
        refids.clear();
        names.clear();
        cursorx    = 0;
        cursory    = 0;
        blinktimer = 0;
        cplayer    = players[consoleplayer];
        whitelist = CVar.GetCVar("hh_weaponwhitelist", cplayer).GetString();
        new_wl    = whitelist;
        undo      = whitelist;
        refidlist = "";
        diff     = false;
        viewlist = false;

        int jw = 0;
        for (int i = 0; i < AllActorClasses.size(); i++) {
            class<actor> a = AllActorClasses[i];
            if (a is "HDWeapon") {
                let r = GetDefaultByType((class<HDWeapon>)(a));
                if (r.refid != "") {
                    let id = r.refid.MakeLower();
                    refids.push(id);
                    names.push(r.GetTag());

                    if (!(jw % 5)) refidlist = "\n"..refidlist;
                    jw++;

                    // Coloour
                    string refidcol = "\n\c"..(r.bdebugonly? "u" : (r.bwimpy_weapon? "y" : "x"));

                    // Treat wimpy weapons as inventory items
                    if (r.bwimpy_weapon) {
                        refidlist = refidlist..refidcol..id.."\cj   "..r.GetTag();
                    } else {
                        refidlist = refidcol..id.."\cj   "..r.GetTag()..refidlist;
                    }
                }
            }
        }

        // Add some stuff that should be known
        for (int i=9; i >= 0; i--) {
            refids.push(string.format("%d", i));
            names.push(string.format("  Any weapon in slot %d", i));
            refidlist = string.format(
                "\cx%d\cj   Any weapon in slot %d\n%s",
                i, i,
                refidlist
            );
        }

        translatedlist = GetTranslatedList(new_wl);
    }

    override bool MenuEvent(int mkey, bool fromcontroller) {
        switch(mkey) {
            case MKEY_Left:
                cursorx = max(0, cursorx-1);
                break;

            case MKEY_Right:
                cursorx = min(new_wl.length(), cursorx+1);
                break;

            case MKEY_Clear: // Backspace
                if (cursorx > 0) {
                    new_wl = new_wl.left(cursorx-1)..new_wl.mid(cursorx);
                    cursorx--;
                    diff = CheckWhitelistDiff();
                }
                break;

            case MKEY_Back: // ESC
                if (diff) {
                    ReloadWhitelist();
                    diff = CheckWhitelistDiff();
                    return false;
                }
                break;

            case MKEY_PageUp:
            case MKEY_Up:
                cursory = max(0,cursory-1);
                break;

            case MKEY_PageDown:
            case MKEY_Down:
                cursory++;
                break;

            case MKEY_Enter:
                if (diff) SaveChanges();
                break;
        }

        diff = CheckWhitelistDiff();
        translatedlist = GetTranslatedList(new_wl);
        return Super.MenuEvent(mkey, fromcontroller);
    }

    override bool OnUIEvent(UIEvent ev) {
        if (ev.Type==UIEvent.Type_KeyDown) {
            switch (ev.KeyChar) {
                case UIEvent.Key_Home:
                    cursorx = 0;
                    break;

                case UIEvent.Key_End:
                    cursorx = new_wl.length();
                    break;

                default:
                    string input = string.format("%c", ev.KeyChar);
                    if (ev.IsCtrl) {
                        if (input ~== "f") {
                            if (viewlist) viewlist = false; else viewlist = true;
                            cursory = 0;
                        }
                    }
                    break;
            }
        } else if (ev.Type == UIEvent.Type_Char) { // Typing
            new_wl = new_wl.left(cursorx)..ev.KeyString..new_wl.mid(cursorx);
            cursorx++;
        }

        diff = CheckWhitelistDiff();
        translatedlist = GetTranslatedList(new_wl);
        return Super.OnUIEvent(ev);
    }

    override void Drawer() {
        Super.Drawer();
        int vcurs = 9;

        // Title
        string s = "Configure Whitelist";
        Screen.DrawText(
            BigFont,
            OptionMenuSettings.mTitleColor,
            (Screen.GetWidth() - BigFont.StringWidth(s) * CleanXfac_1) / 2,
            vcurs,
            s, DTA_CleanNoMove_1, true
        );

        // Info text
        vcurs += BigFont.GetHeight() + (NewSmallFont.GetHeight()>>1);
        s = "\cg     Syntax:   \cax yyy yyy yyy\n\ca x \cuSlot Number   \cayyy \cuLoadout Code\n\n              Note:\n    Don't use commas, please.\n\n\cdENTER \cusave   \cdESC \cuclear changes";
        Screen.DrawText(
            NewSmallFont,
            OptionMenuSettings.mFontColor,
            (Screen.GetWidth() - NewSmallFont.StringWidth(s) * CleanXfac_1) / 2,
            vcurs * CleanYfac_1,
            s, DTA_CleanNoMove_1, true
        );

        // Whitelist text editor
        vcurs += NewSmallFont.GetHeight() * 10;

        string wl = new_wl;
        int tempcursorx = cursorx;
        int maxwidth = (Screen.GetWidth() * 3 / 5) / (SmallFont.StringWidth("_") * CleanXfac_1);
        int halfmaxwidth = maxwidth / 2;
        int addarrows = 0;
        int textstart = 0;
        int textend = wl.length();
        if (wl.length() > maxwidth) {
            int len = wl.length();
            if (
                cursorx >= halfmaxwidth &&
                len - cursorx >= halfmaxwidth
            ) {
                //enough space on both sides of cursor
                tempcursorx = halfmaxwidth;
                wl = wl.mid(cursorx - halfmaxwidth, maxwidth);
                addarrows |= 1|2;
                textstart = cursorx - halfmaxwidth;
                textend = cursorx + halfmaxwidth;
            } else if (cursorx < halfmaxwidth) {
                //beginning
                wl = wl.left(maxwidth);
                addarrows |= 2;
                textend = maxwidth;
            } else {
                //end
                wl = wl.mid(len-maxwidth);
                tempcursorx -= new_wl.length() - wl.length();
                addarrows |= 1;
                textstart = textend - maxwidth;
            }
        }
        int wlline  = vcurs * CleanYfac_1;
        int wlwidth = NewSmallFont.StringWidth(wl) * CleanYfac_1;
        int wlxpos  = (Screen.GetWidth() - wlwidth) / 2;
        Screen.DrawText(
            NewSmallFont,
            diff? OptionMenuSettings.mFontColorHeader : OptionMenuSettings.mFontColorValue,
            wlxpos, wlline,
            wl, DTA_CleanNoMove_1, true
        );

        // Stuff that blinks in and out
        blinktimer++;

        // Caret/Cursor
        if (blinktimer > 3) {
            if (blinktimer > 6) blinktimer = 0;
            Screen.DrawText(
                NewSmallFont,
                OptionMenuSettings.mFontColorHighlight,
                wlxpos + NewSmallFont.StringWidth(wl.left(tempcursorx)) * CleanXfac_1,
                wlline,
                "_", DTA_CleanNoMove_1, true
            );
        }

        // Arrows
        if (addarrows && blinktimer > 2) {
            if (addarrows & 1) {
                Screen.DrawText(
                    NewSmallFont,
                    OptionMenuSettings.mFontColor,
                    wlxpos - NewSmallFont.StringWidth("<<  ") * CleanXfac_1,
                    wlline,
                    "<<  ", DTA_CleanNoMove_1, true
                );
            }
            if (addarrows & 2) {
                Screen.DrawText(
                    NewSmallFont,
                    OptionMenuSettings.mFontColor,
                    wlxpos + wlwidth,
                    wlline,
                    "  >>", DTA_CleanNoMove_1, true
                );
            }
        }
        vcurs += NewSmallFont.GetHeight();

        s = "Editing whitelist.";
        Screen.DrawText(
            SmallFont,
            OptionMenuSettings.mTitleColor,
            (Screen.GetWidth() - SmallFont.StringWidth(s) * CleanXfac_1) / 2,
            vcurs * CleanYfac_1,
            s, DTA_CleanNoMove_1, true
        );

        vcurs += SmallFont.GetHeight() * 2;
        s = translatedlist;
        Screen.DrawText(
            NewSmallFont,
            OptionMenuSettings.mFontColorValue,
            (Screen.GetWidth() - NewSmallFont.StringWidth(s) * CleanXfac_1) / 2,
            vcurs * CleanYfac_1,
            s, DTA_CleanNoMove_1, true
        );
    }

    bool CheckWhitelistDiff() {
        return (new_wl != whitelist);
    }

    void ReloadWhitelist() {
        new_wl = whitelist;
    }

    void SaveChanges() {
        CVar.FindCVar("hh_weaponwhitelist").SetString(new_wl);
        undo      = whitelist;
        whitelist = new_wl;
    }

    string GetTranslatedList(string input) {
        string list;
        if (viewlist) list = refidlist;
        else {
            array<string> items; items.clear();
            new_wl.split(items, " ");
            for (int i = 0; i < items.size(); i++) {
                string item = items[i];
                string i_name;

                int whichindex = refids.find(item);
                if (whichindex >= refids.size()) i_name = "\ca ? ? ?\cj";
                else i_name = names[whichindex];

                list = list.."\cd"..item.."\cj   "..i_name.."\n";
            }
        }

        int skiplines = cursory;
        while (skiplines > 0) {
            skiplines--;
            int brk = list.IndexOf("\n");
            if (brk < 0) {
                cursory -= skiplines + 1;
                break;
            } else {
                list = list.mid(brk+1);
            }
        }

        list = "\n\cu  Ctrl+F "..(viewlist? "preview" : "refID list").."   PgUp/PgDn scroll\cj\n"..list;
        list = (viewlist? "\cnC O D E   R E F E R E N C E   L I S T            " : "\ceW H I T E L I S T   P R E V I E W                ")..list;
        return list;
    }
}
