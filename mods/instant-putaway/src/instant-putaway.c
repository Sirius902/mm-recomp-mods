#include "modding.h"
#include "global.h"
#include "recomputils.h"
#include "recompconfig.h"

RECOMP_HOOK("Player_UpdateInterface")
void update_interface_hook(PlayState* play, Player* this) {
    this->putAwayCooldownTimer = 0;
}
