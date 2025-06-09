#include "modding.h"
#include "global.h"
#include "recomputils.h"
#include "recompconfig.h"

#include "overlays/actors/ovl_En_Boom/z_en_boom.h"

static Actor* arg_thisx;
static PlayState* arg_play;

// Implementation based on https://github.com/HarbourMasters/2ship2harkinian/blob/3221402a77079c2e316563bc032c23fd5c63876b/mm/2s2h/Enhancements/Equipment/InstantRecall.cpp.
static void return_boomerang(Actor* actor) {
    EnBoom* boomerang = (EnBoom*)actor;

    // Kill the boomerang as long as it is not carrying an actor
    if (boomerang->unk_1C8 == NULL) {
        Actor_Kill(&boomerang->actor);
    }
}

RECOMP_HOOK("EnBoom_Update") void boomerang_update_hook(Actor* thisx, PlayState* play) {
    arg_thisx = thisx;
    arg_play = play;
}

RECOMP_HOOK_RETURN("EnBoom_Update") void boomerang_update_return_hook() {
    if (recomp_get_config_u32("instant_recall")) {
        if (CHECK_BTN_ALL(arg_play->state.input->press.button, BTN_B)) {
            return_boomerang(arg_thisx);
        }
    }
}
