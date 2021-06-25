All changes are sorted from top to bottom, Latest to Oldest.
Date format: DD/MM/YYYY
---
**25/06/2021**
> Armour nerf might need to be tweaked a lot. Hope it doesn't make armour too shit (p.s: i haven't tested battle armour yet)

Tweaks:
* Marines/Jackboots now get determined whether they have a helmet on spawning, instead of on death.

Additions:
* Added an option to nerf vanilla HDest armour's head protection, this affects enemies too. *(enabled by default)*
* Added an option to allow enemies to wear helmets, this will affect their head protection. *(enabled by default)*
---
**19/06/2021**
> Note to self: Add a new operator for "hh_firemodecodes"'s parser thing

Compat:
* ZM69 should now display its firemode when not wearing a helmet.

Misc:
* Sorted `hh_firemodecodes` into different files
---
**17/06/2021**

Compat:
* Updated to latest main of Hideous Destructor

Tweaks:
* Changed the default min and max durability of helmets from foes

Additions:
* Added a way to reset options back to default
* Added some weapons from addons to the "whitelist"
---
**16/06/2021 [2]**
> Hopefully the tweaks don't make the helmet too good

Compat:
* Weapons from Peppergrinder should now display its firemode when not wearing a helmet. *(only applies if Hide Weapon Status is enabled)*

Tweaks:
* Tweaked how the helmet takes damage. *(should last a bit longer now)*
* Adjusted helmet max durability to 72. *(which is half of the Garrison armour's max durability)*

Added:
* Added `hh_debug` for.. well, debugging helmet stuff. *(also because hd_debug displays a lot of stuff)*
---
**16/06/2021 [1]**

Compat:
* Updated to latest main of Hideous Destructor.
---
**8/06/2021**

Fixes:
* "Hide Weapon Status" should now actually unhide weapon status when disabled.
* Whitelist editor should now properly save.
---
**7/06/2021**

Compat:
* Updated to latest main of Hideous Destructor.
* HUD Compass should now match the latest main's.
---
**6/06/2021**

Compat:
* Updated to latest main of Hideous Destructor.

Tweaks:
* Helmet no longer protects your legs.

---
**31/05/2021**

Compat:
* Updated to latest main of Hideous Destructor.
---
**30/05/2021**

Compat:
* Updated to latest main of Hideous Destructor.
---
**29/05/2021**

Compat:
* Adapt to the new ArmourChangeEffect().

Fixes:
* Fixed ArmourChangeEffect() not passing the right pointer.
* Helmet now actually requires you to "double click" to remove it. *(does not apply to hh_strip)*

Tweaks:
* As a result of the ArmourChangeEffect() fix, you now get staggered when the helmet breaks while worn.
* The helmet is now actually called "HUD Helmet" in the backpack.
---
**27/05/2021 [2]**

Compat:
* Exclude helmet from the new CheckStrip() system.

Misc:
* No longer overwriting gadgets.zs
---
**27/05/2021 [1]**
> Hopefully nothing's horribly broken

Compat:
* Updated to latest main of Hideous Destructor.

Tweaks:
* Bullets now bypass helmet if enemy is standing right over you while incap'd.
* Helmet can now turn into dust, when attempting to take off with lower than 5 durability. *(originally was 3)*
* Helmet now makes a sound when breaking.

Misc:
* Less code overwriting.
* Sorted some code.
---
**21/05/2021**
> Thanks to [Ace](https://gitlab.com/Accensus) for the fix.

* Fixed an oversight that would cause a VM Abort if the player loaded a multiplayer save in singleplayer.
---
**20/05/2021**
* Fixed a bug that would cause a VM Abort if the player wasn't HDPlayerPawn.
---
**11/05/2021**
> Hopefully this doesn't break anything.

* Update to latest main of Hideous Destructor.
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

* Updated to latest main of Hideous Destructor.
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
