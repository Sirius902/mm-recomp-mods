#include "modding.h"
#include "global.h"
#include "recomputils.h"
#include "recompconfig.h"

RECOMP_HOOK("Player_UpdateInterface") void update_interface_hook(PlayState* play, Player* this) {
    // FUTURE(Sirius902) This implementation isn't ideal since it will still have 1 frame of delay.
    if (recomp_get_config_u32("instant_putaway")) {
        this->putAwayCooldownTimer = 0;
    }
}
