#include "modding.h"
#include "global.h"
#include "recomputils.h"
#include "recompconfig.h"

RECOMP_CALLBACK("*", recomp_on_play_update)
void on_play_update(void) {
    if (INV_CONTENT(ITEM_BOMB) == ITEM_BOMB) {
        AMMO(ITEM_BOMB) = CUR_CAPACITY(UPG_BOMB_BAG);
    }

    if (INV_CONTENT(ITEM_BOMBCHU) == ITEM_BOMBCHU) {
        AMMO(ITEM_BOMBCHU) = CUR_CAPACITY(UPG_BOMB_BAG);
    }

    if (INV_CONTENT(ITEM_POWDER_KEG) == ITEM_POWDER_KEG) {
        AMMO(ITEM_POWDER_KEG) = 1;
    }
}
