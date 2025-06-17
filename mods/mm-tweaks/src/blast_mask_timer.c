#include "modding.h"
#include "global.h"
#include "recomputils.h"
#include "recompconfig.h"

RECOMP_HOOK("Player_ProcessItemButtons") void process_item_buttons_hook(Player* this, PlayState* play) {
    // FUTURE(Sirius902) This implementation isn't ideal since it will still have 1 frame of delay.
    if (recomp_get_config_u32("instant_blast_mask")) {
        this->blastMaskTimer = 0;
    }
}
