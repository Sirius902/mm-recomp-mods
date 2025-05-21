#include "modding.h"
#include "global.h"
#include "recomputils.h"
#include "recompconfig.h"

RECOMP_CALLBACK("*", recomp_on_play_update)
void on_play_update(void) {
    AMMO(ITEM_BOMB) = CUR_CAPACITY(UPG_BOMB_BAG);
    AMMO(ITEM_BOMBCHU) = CUR_CAPACITY(UPG_BOMB_BAG);
}
