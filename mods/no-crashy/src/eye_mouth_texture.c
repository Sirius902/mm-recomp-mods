#include "modding.h"
#include "global.h"
#include "recomputils.h"
#include "recompconfig.h"

extern TexturePtr sPlayerEyesTextures[PLAYER_EYES_MAX];
extern TexturePtr sPlayerMouthTextures[PLAYER_MOUTH_MAX];

typedef struct PlayerFaceIndices {
    /* 0x0 */ u8 eyeIndex;
    /* 0x1 */ u8 mouthIndex;
} PlayerFaceIndices; // size = 0x2

extern PlayerFaceIndices sPlayerFaces[];

extern s32 D_801F59E0;
extern s32 sPlayerLod;

// Note the correct pointer to pass as the jointTable is the jointTable pointer from the SkelAnime struct, not the
// buffer from the Player struct itself since that one may be misaligned.
RECOMP_PATCH
void Player_DrawImpl(PlayState* play, void** skeleton, Vec3s* jointTable, s32 dListCount, s32 lod,
                     PlayerTransformation playerForm, s32 boots, s32 face, OverrideLimbDrawFlex overrideLimbDraw,
                     PostLimbDrawFlex postLimbDraw, Actor* actor) {
    s32 eyeIndex = GET_EYE_INDEX_FROM_JOINT_TABLE(jointTable);
    s32 mouthIndex = GET_MOUTH_INDEX_FROM_JOINT_TABLE(jointTable);
    Gfx* gfx;

    OPEN_DISPS(play->state.gfxCtx);

    gfx = POLY_OPA_DISP;

    if (eyeIndex >= PLAYER_EYES_MAX) {
        recomp_printf("Avoiding OoB eye texture access: %d\n", eyeIndex);
        eyeIndex = 0;
    }

    if (eyeIndex < 0) {
        eyeIndex = sPlayerFaces[face].eyeIndex;
    }

    if (playerForm == PLAYER_FORM_GORON) {
        if ((eyeIndex >= PLAYER_EYES_ROLL_RIGHT) && (eyeIndex <= PLAYER_EYES_ROLL_DOWN)) {
            eyeIndex = PLAYER_EYES_OPEN;
        } else if (eyeIndex == PLAYER_EYES_7) {
            eyeIndex = PLAYER_EYES_ROLL_RIGHT;
        }
    }

    gSPSegment(&gfx[0], 0x08, Lib_SegmentedToVirtual(sPlayerEyesTextures[eyeIndex]));

    if (mouthIndex >= PLAYER_MOUTH_MAX) {
        recomp_printf("Avoiding OoB mouth texture access: %d\n", mouthIndex);
        mouthIndex = 0;
    }

    if (mouthIndex < 0) {
        mouthIndex = sPlayerFaces[face].mouthIndex;
    }

    gSPSegment(&gfx[1], 0x09, Lib_SegmentedToVirtual(sPlayerMouthTextures[mouthIndex]));

    POLY_OPA_DISP = &gfx[2];

    D_801F59E0 = playerForm * 2;
    sPlayerLod = lod;
    SkelAnime_DrawFlexLod(play, skeleton, jointTable, dListCount, overrideLimbDraw, postLimbDraw, actor, lod);

    CLOSE_DISPS(play->state.gfxCtx);
}
