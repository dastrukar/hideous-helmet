# Hideous Helmet
> An addon for [Hideous Destructor](https://codeberg.org/mc776/hideousdestructor) [*(Forum link)*](https://forum.zdoom.org/viewtopic.php?f=43&t=12973). Adds a helmet that shows the HUD, with some additional stuff.
> This addon is meant to work with the [latest main(unstable) of Hideous Destructor.](https://codeberg.org/mc776/hideousdestructor/archive/main.zip)\
> *(unless i forgot to update it to work with latest)*

![image](https://user-images.githubusercontent.com/32709291/129836058-2d2113c3-da37-4f06-9ac8-6fad363a06d4.png)


## What?
Hideous Helmet adds a new "armour" piece called `HUD Helmet`.

Some of the HUD is hidden without the helmet.\
*Note: You may toggle which part of the HUD gets hidden when not wearing the helmet.*

### Loadout codes:
* `hdh` hud helmet (spare)
* `hhw` hud helmet


## Balancing features
> All the features listed below are toggleable

### Armour Nerf
Due to the introduction of helmets, any armour's head protection has been reduced. This affects enemies too.

### Enemies wear helmets
Enemies that spawn/drop helmets can also wear them, allowing them to benefit from it. (only applies if they actually have one)\
However, it does mean that rapidly shooting them in the head will make them drop a more broken helmet.

Also, I don't recommend using this feature with "Armour Nerf" disabled. And no, you can't tell if the enemy has a helmet or not.


## Info about the helmet
### When worn:
* Shows all of the HUD when you wear it, with some extra stuff. *(extra stuff is toggleable)*
* Provides some defense, mostly for the head.
* Can be worn without removing armour first.
* *Should be noted that you can use medikit with the helmet on.*
* Can be removed with `hh_strip`.
* Will take damage and break like any armour.
* Shows a *"bleed indicator"*, with a *"wound counter"*. *(both are toggleable)*

### Spawn info:
Has a chance to spawn at any armour.\
Marines or jackboots with helmets should also drop them on death.\
*(You can tweak the spawn rate)*


## Releases
You should only use the release versions if you're using a [release version of Hideous Destructor](https://codeberg.org/mc776/hideousdestructor/releases).\
Otherwise, just [clone the latest master](https://github.com/dastrukar/hideous-helmet/archive/refs/heads/master.zip) repo and pray that it works.


## Compatibility
It should work fine with other addons. *(if none of the overwriting stuff breaks anything)*

If some stuff don't work, located in `hh_patches` are patches made by me. They should be named after the mod it's meant to patch (if the mod uses a git repository, then it'll be named after that), so just load them and it should work with the mod :].
(and if they don't, just let me know and i'll consider fixing them)


## Why a helmet?
Well, I always wondered what if you could wear a helmet item in Hideous Destructor, then I thought about combining the HUD and helmet together.\
Then, a question came up.

> What if your helmet breaks from excessive damage, and your HUD is gone?

And here we are.


## Credits
```
Matt : Made Hideous Destructor (which i had to copy some code over to overwrite)
Accensus : Helped fixed HHSkinHandler
```
