# The Hideous Helmet customization manual
> note to self: maybe document better

## Defining armours
Hideous Destructor draws the armour HUD stuff from the armour itself, due to this, Hideous Helmet is unable to hide the armour's current durability.\
To overcome this problem, Hideous Helmet uses a lump called `hh_armourlist` to check if the armour is actually an armour. (there's actual coding reasons as to why this is done, but i'm lazy to explain it)\
If you wish to add your own armour into the list, create a new lump/file named `hh_armourlist`, and make sure you put your own suffix, else you'll end up overwriting the base definitions. (unless you intended to do that)

### Syntax
Syntax is simple, each name is split per line. That's it.

## Firemode/Fire indicator customization
> Note: This only applies if you use "Hide Weapon status"

Due to how the weapon HUD works, there's no actual way to find the firemode of the current weapon without editing the guns themselves.\
Instead, firemode indicators are defined through text files starting with `hh_firemodecodes`.\
If you wish to add firemode indicators for custom weapons, create a file named `hh_firemodecodes`.

Format:
```
Normal:
<refid>:<weaponstatusindex>:<icon0,icon1,icon2...>

Bitwise:
<refid>:<weaponstatusindex>:<icon0,icon1,icon2...>:<condition0,condition1,condition2...>
```
* `refid` : The loadout code of the weapon.
* `weaponstatusindex` : The index number that the weapon uses on the array `weaponstatus`.
* `iconX`(X=0,1,2...) : Determines what icon will be used.

* `conditionX`(X=0,1,2...) :\
If true in the following statement:\
`(HDWeapon.weaponstatus[weaponstatusindex] & condition)`\
Will use the icon with the same X as the condition that was true.

* `Bitwise` :\
Uses bitwise AND to compare with `weaponstatus`.\
Use Bitwise if the weapon uses it for determining firemode icons.

Here's some terrible art of how the Bitwise type works:\
*(i hope you're reading this with a monospace font)*
```
   X=0             X=1             X=2
condition0  ..  condition1  ..  condition2  ..

    |               |               |
    |               |               |      [uses]
   \|/             \|/             \|/

  icon0    ...    icon1    ...    icon2    ...
```

* `blank` : Self explanatory.

### Examples:
Normal:
```
hun:1:blank,RBRSA3A7,STFULAUT
sla:0:blank,STBURAUT
```

Bitwise:
```
s45:0:RBRSA3A7,STFULAUT:blank,2
cpt:0:blank,STBURAUT:blank,1
```
