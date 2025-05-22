#include "modding.h"
#include "global.h"
#include "recomputils.h"
#include "recompconfig.h"

RECOMP_HOOK("Player_ProcessItemButtons")
void process_item_buttons_hook(Player* this, PlayState* play) {
    this->blastMaskTimer = 0;
}
