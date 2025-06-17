#include "modding.h"
#include "global.h"
#include "recomputils.h"
#include "recompconfig.h"

extern s32 func_8083C62C(Player* this, s32 arg1);
extern bool func_8082EF20(Player* this);

RECOMP_PATCH s32 func_8083E404(Player* this, f32 arg1, s16 arg2) {
    f32 sp1C = BINANG_SUB(arg2, this->actor.shape.rot.y);
    f32 temp_fv1;

    if (this->focusActor != NULL) {
        func_8083C62C(this, func_800B7128(this) || func_8082EF20(this));
    }

    // Based on https://github.com/HarbourMasters/2ship2harkinian/blob/620859447c6bddcdf1dded50a7a4110f825536bf/mm/2s2h/Enhancements/Fixes/FierceDeityZTargetMovement.cpp#L17-L22.
    if (recomp_get_config_u32("fd_speed_fix")) {
        // If the player is Fierce Deity and targeting,
        if (this->focusActor != NULL && this->transformation == PLAYER_FORM_FIERCE_DEITY) {
            // 6.0f is the maximum speed of Zora/Goron/Deku link, whereas FD can be up to 10
            // Clamping to 6.0 keeps z target movement similar to other transformations
            arg1 = CLAMP_MAX(arg1, 6.0f);
        }
    }

    temp_fv1 = fabsf(sp1C) / 0x8000;
    if (((SQ(temp_fv1) * 50.0f) + 6.0f) < arg1) {
        return 1;
    }

    if ((((1.0f - temp_fv1) * 10.0f) + 6.8f) < arg1) {
        return -1;
    }
    return 0;
}
