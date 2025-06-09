#include "modding.h"
#include "global.h"
#include "recomputils.h"
#include "recompconfig.h"

RECOMP_HOOK("Player_UpdateInterface") void update_interface_hook(PlayState* play, Player* this) {
    if (recomp_get_config_u32("instant_putaway")) {
        this->putAwayCooldownTimer = 0;
    }
}
