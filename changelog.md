All changes are sorted from top to bottom, Latest to Oldest.
Date format: DD/MM/YYYY
---
**10/05/2021**
> Here's the long overdue "Hide weapon status" rework, and some other minor additions/fixes.

* Reworked "Hide weapon status", with a brand new whitelist system. *(and pray that it works)*
* Fixed strip message showing up for every player.
* Fixed strip cooldown not being applied.
* Fixed helmet skin not working in multiplayer. *(hopefully)*
* Added some options to adjust the helmet's position on the HUD.
* "hh_strip" will now also equip helmet.
* Helmet skin change is now toggleable. *(Turned off by default)*
* Default skin now works with helmet skin change.
---
**4/05/2021**
* You can now change your skin based on whether you have a helmet or not. *(Change with CVar "hh_nohelmskin" and "hh_helmetskin")*
* Added better menu info.
---
**2/05/2021**
* Increased bulk of helmet when not worn.
* Decreased bulk of helmet when worn.
---
**30/04/2021**
* Undo helmet durability buff.
* Added weapons from PB's Weapon Addon, and Icarus' weapons to "hh_firemodecode". *(now you don't have to add it yourself :])*
---
**29/04/2021 [2]**
* Fixed an oversight where grenades would cause a VM abort.
---
**29/04/2021 [1]**
* Made the helmet a bit more durable. *(the defense nerf made it less durable)*
---
**28/04/2021**
> Weapon status rework coming soon...

* Fixed Radsuit and Blood Bag not displaying on the HUD without helmet.
* Fixed helmet sprite being broken for FreeDoom.
* Added options to tweak durability of helmets dropped from enemies.
* Added an option to show firemode. *(if you wish to add custom weapons into the list, please refer to hh_manual.md)*
* Improved spawning, helmets should drop from undead marines now, and not drop again from an enemy that has already tried.
* Reduced default durability of helmets dropped from enemies.
* Nerfed defense by a bit. *(might need some tweaking)*
* "Hide Weapon status" is now enabled by default.
---
**26/04/2021 [2]**
> Hope this doesn't break anything

* Updated to latest master of Hideous Destructor.
* Helmet should now show up in the automap, even though it's going to get blocked by the inventory...
* Added option for bleed indicator, "Hide indicator when not bleeding".
---
**26/04/2021 [1]**
* Fixed helmet changing to durability 50, when you had more than 1 helmet.
---
**23/04/2021 [3]**
> How did I miss this

* Reworked "Hide weapon status" options, mag manager should display fine now.
---
**23/04/2021 [2]**
* Removed unused option "Slot 4 shows weapon status"
---
**23/04/2021 [1]**
> I probably should've added more options for "Hide weapon status" early on

* Added helmet sprite for Freedoom.
* Added better options for "Hide weapon status"
---
**22/04/2021**
> The "decide your own RNG" update

* Fixed `give hhelmetworn` having 144 durability. *(hopefully)*
* Added options to tweak helmet spawn rate.
* Armour now spawns helmets more frequently. *(50% chance by default)*
* Helmet jackboots now drop helmets.
---
**18/04/2021 [2]**
> Maybe I should use a proper version scheme

* Fixed helmet not equipping when holding use on pickup.
* "Hide weapon status" shouldn't hide anything in slot 9 anymore...
* ...which fixes not being able to see what you have while incapacitated.
* Added option, "Slot 4 shows weapon status". Only takes effect when "Hide weapon status" is enabled. *(might change this)*
---
**18/04/2021 [1]**
> I hate bugs

* Fixed the backpack giving more than 1 helmet when you have 0 helmets in your inventory...
* ...which also fixes `summon hhelmet` spawning more than 1 helmet...
* ...and also fixes the bulk of the helmet being wrong while in the backpack.
* Wearing the helmet will now always display a message. *(unless hd_helptext is false)*
---
**16/04/2021**
> who needs to look at ground, when you can look at hud???? (am tired)

* Added a "bleed indicator", with a "wounds counter". *(both are toggleable)*
* Tweaked defense a bit.
---
**14/04/2021**
> TIL that bullets calculate damage on their own

* Hopefully fixed helmet spawning with 144 durability.
* Reworked defense, helmet now provides more defense to a headshot than a body/leg shot. *(might need some more work)*
* Helmet is now more durable due to the new defense rework...
* ...which also fixed helmet getting more durable depending on what armour type you were wearing.
---
**10/04/2021**
> Hopefully this fixes most of the major problems

* Fixed HUD not being hidden when using the automap.
* Helmet can only be stripped through `hh_strip`, or by attempting to equip another helmet while wearing one.
* You can now customize what gets hidden when the helmet isn't equipped. *(By default, only the player status is hidden.)*
* Removed whitelist overwriting from the options menu.
* Helmet now has a bit of defense. Only applies to certain damage types.
* Helmet will now only lose durability to certain types of damage. *(might need some tweaking)*
* Should spawn a bit more frequently now.
