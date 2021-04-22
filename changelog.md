All changes are sorted from top to bottom, Latest to Oldest.
Date format: DD/MM/YYYY

22/04/2021
> The "decide your own RNG" update

* Fixed `give hhelmetworn` having 144 durability. *(hopefully)*
* Added options to tweak helmet spawn rate.
* Armour now spawns helmets more frequently. *(50% chance by default)*
* Helmet jackboots now drop helmets.

18/04/2021[2]
> Maybe I should use a proper version scheme

* Fixed helmet not equipping when holding use on pickup.
* "Hide weapon status" shouldn't hide anything in slot 9 anymore...
* ...which fixes not being able to see what you have while incapacitated.
* Added option, "Slot 4 shows weapon status". Only takes effect when "Hide weapon status" is enabled. *(might change this)*

18/04/2021 [1]
> I hate bugs

* Fixed the backpack giving more than 1 helmet when you have 0 helmets in your inventory...
* ...which also fixes `summon hhelmet` spawning more than 1 helmet...
* ...and also fixes the bulk of the helmet being wrong while in the backpack.
* Wearing the helmet will now always display a message. *(unless hd_helptext is false)*

16/04/2021
> who needs to look at ground, when you can look at hud???? (am tired)

* Added a "bleed indicator", with a "wounds counter". *(both are toggleable)*
* Tweaked defense a bit.

14/04/2021
> TIL that bullets calculate damage on their own

* Hopefully fixed helmet spawning with 144 durability.
* Reworked defense, helmet now provides more defense to a headshot than a body/leg shot. *(might need some more work)*
* Helmet is now more durable due to the new defense rework...
* ...which also fixed helmet getting more durable depending on what armour type you were wearing.



10/04/2021
> Hopefully this fixes most of the major problems

* Fixed HUD not being hidden when using the automap.
* Helmet can only be stripped through `hh_strip`, or by attempting to equip another helmet while wearing one.
* You can now customize what gets hidden when the helmet isn't equipped. *(By default, only the player status is hidden.)*
* Removed whitelist overwriting from the options menu.
* Helmet now has a bit of defense. Only applies to certain damage types.
* Helmet will now only lose durability to certain types of damage. *(might need some tweaking)*
* Should spawn a bit more frequently now.
