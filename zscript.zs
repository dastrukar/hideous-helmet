version "4.7"

// [[ Armour Compatibility ]]
#include "zscript/armour/HHArmourNerf.zs"
#include "zscript/armour/HHArmourNerfHandler.zs"
//#include "zscript/armour/HHArmourType.zs" (in statusbar.zs)
#include "zscript/armour/HHArmourType_HDArmourWorn.zs"
#include "zscript/armour/HHArmourTypeHandler.zs"


// [[ Helmet/Module Manager ]]
#include "zscript/HHManager.zs"


// [[ Modules ]]
// [ Base ]
#include "zscript/modules/HHBaseModule.zs"
#include "zscript/modules/HHModuleHandler.zs"
#include "zscript/modules/HHModuleStorage.zs"

// [ Items ]
#include "zscript/modules/HUDModule.zs"


// [[ Helmets ]]
// [ Base ]
#include "zscript/helmet/HasHelmet.zs"
#include "zscript/helmet/HHBaseHelmet.zs"
#include "zscript/helmet/HHBaseHelmetWorn.zs"
#include "zscript/helmet/HHSkinHandler.zs"
#include "zscript/helmet/HHHelmetSpawner.zs"
#include "zscript/helmet/HHSpawnType.zs"
#include "zscript/helmet/HHSpawnType_Default.zs"

// [ Items ]
#include "zscript/helmet/HudHelmet.zs"
#include "zscript/helmet/HudHelmetWorn.zs"


// [[ ETC ]]
#include "zscript/HHConstants.zs"
//#include "zscript/HHFunc.zs" (in statusbar.zs)
//#include "zscript/FiremodeInfo.zs" (in statusbar.zs)
#include "zscript/HHHandler.zs"
#include "zscript/HHWhitelistMenu.zs"
