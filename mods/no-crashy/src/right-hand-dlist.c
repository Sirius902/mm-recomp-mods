#include "modding.h"
#include "global.h"
#include "recomputils.h"
#include "recompconfig.h"

extern s32 D_801F59E0;
extern s32 sPlayerLod;

extern PlayerModelType sPlayerLeftHandType;
extern PlayerModelType sPlayerRightHandType;

extern Gfx* gPlayerLeftHandOpenDLs[2 * PLAYER_FORM_MAX]; 
extern Gfx* gPlayerLeftHandClosedDLs[2 * PLAYER_FORM_MAX];

extern Gfx* D_801C018C[];

extern Gfx** D_801C095C[];
extern Gfx** D_801C0964[];

extern AnimationHeader gPlayerAnim_pg_punchA;
extern AnimationHeader gPlayerAnim_pg_punchB;

extern struct_80124618 D_801C0750[];
extern struct_80124618 D_801C0538[];
extern struct_80124618 D_801C0560[];
extern struct_80124618 D_801C0784[];

extern Gfx* gLinkZoraLeftHandOpenDL[];
extern Gfx* gPlayerAnim_pz_gakkistart[];
extern Gfx* gPlayerAnim_pz_gakkiplay[];
extern Gfx* object_link_zora_DL_00E2A0[];
extern Gfx* gLinkZoraRightHandOpenDL[];
extern Gfx* gPlayerHandHoldingShields[2 * (PLAYER_SHIELD_MAX - 1)];
extern Gfx* gPlayerRightHandClosedDLs[2 * PLAYER_FORM_MAX];
extern Gfx* gPlayerSheathedSwords[];
extern Gfx* gPlayerSwordSheaths[];

extern s32 Player_OverrideLimbDrawGameplayCommon(PlayState* play, s32 limbIndex, Gfx** dList, Vec3f* pos, Vec3s* rot,
                                          Actor* thisx);

extern void func_80125CE0(Player* player, struct_80124618* arg1, Vec3f* pos, Vec3s* rot);

RECOMP_PATCH
s32 Player_OverrideLimbDrawGameplayDefault(PlayState* play, s32 limbIndex, Gfx** dList, Vec3f* pos, Vec3s* rot,
                                           Actor* actor) {
    Player* player = (Player*)actor;

    if (!Player_OverrideLimbDrawGameplayCommon(play, limbIndex, dList, pos, rot, &player->actor)) {
        if (limbIndex == PLAYER_LIMB_LEFT_HAND) {
            Gfx** leftHandDLists = player->leftHandDLists;
            EquipValueSword swordEquipValue;

            if (player->stateFlags3 & PLAYER_STATE3_2000) {
                rot->z -= player->unk_B8C;
            } else if ((sPlayerLeftHandType == PLAYER_MODELTYPE_LH_4) &&
                       (player->stateFlags1 & PLAYER_STATE1_ZORA_BOOMERANG_THROWN)) {
                leftHandDLists = &gPlayerLeftHandOpenDLs[D_801F59E0];
                sPlayerLeftHandType = PLAYER_MODELTYPE_LH_OPEN;
            } else if ((player->leftHandType == PLAYER_MODELTYPE_LH_OPEN) && (player->actor.speed > 2.0f) &&
                       !(player->stateFlags1 & PLAYER_STATE1_8000000)) {
                leftHandDLists = &gPlayerLeftHandClosedDLs[D_801F59E0];
                sPlayerLeftHandType = PLAYER_MODELTYPE_LH_CLOSED;
            } else if ((player->leftHandType == PLAYER_MODELTYPE_LH_ONE_HAND_SWORD) &&
                       (player->transformation == PLAYER_FORM_HUMAN) &&
                       ((swordEquipValue = GET_CUR_EQUIP_VALUE(EQUIP_TYPE_SWORD),
                         swordEquipValue != EQUIP_VALUE_SWORD_NONE))) {
                leftHandDLists = &D_801C018C[2 * ((swordEquipValue - 1) ^ 0)];
            } else {
                s32 handIndex = GET_LEFT_HAND_INDEX_FROM_JOINT_TABLE(player->skelAnime.jointTable);

                if (handIndex != 0) {
                    handIndex = (handIndex >> 12) - 1;
                    if (handIndex >= 2) {
                        handIndex = 0;
                    }
                    leftHandDLists = &D_801C095C[handIndex][D_801F59E0];
                }
            }

            *dList = leftHandDLists[sPlayerLod];

            if (player->transformation == PLAYER_FORM_GORON) {
                if (player->skelAnime.animation == &gPlayerAnim_pg_punchA) {
                    func_80125CE0(player, D_801C0750, pos, rot);
                }
            } else if (player->transformation == PLAYER_FORM_ZORA) {
                if ((player->stateFlags1 & PLAYER_STATE1_2) || (player->stateFlags1 & PLAYER_STATE1_400) ||
                    func_801242B4(player)) {
                    *dList = gLinkZoraLeftHandOpenDL;
                } else {
                    s32 phi_a1 = (player->skelAnime.animation == &gPlayerAnim_pz_gakkistart) &&
                                 (player->skelAnime.curFrame >= 6.0f);

                    if (phi_a1 || (player->skelAnime.animation == &gPlayerAnim_pz_gakkiplay)) {
                        *dList = object_link_zora_DL_00E2A0;
                        func_80125CE0(player, phi_a1 ? D_801C0538 : D_801C0560, pos, rot);
                    }
                }
            }
        } else if (limbIndex == PLAYER_LIMB_RIGHT_HAND) {
            if ((player->transformation == PLAYER_FORM_ZORA) &&
                (((player->stateFlags1 & PLAYER_STATE1_2)) || (player->stateFlags1 & PLAYER_STATE1_400) ||
                 func_801242B4(player))) {
                *dList = gLinkZoraRightHandOpenDL;
            } else {
                Gfx** rightHandDLists = player->rightHandDLists;

                if (player->stateFlags3 & PLAYER_STATE3_2000) {
                    rot->z -= player->unk_B8C;
                }

                if (sPlayerRightHandType == PLAYER_MODELTYPE_RH_SHIELD) {
                    if (player->transformation == PLAYER_FORM_HUMAN) {
                        if (player->currentShield != PLAYER_SHIELD_NONE) {
                            //! FAKE:
                            rightHandDLists = &gPlayerHandHoldingShields[2 * ((player->currentShield - 1) ^ 0)];
                        }
                    }
                } else if ((player->rightHandType == PLAYER_MODELTYPE_RH_OPEN) && (player->actor.speed > 2.0f) &&
                           !(player->stateFlags1 & PLAYER_STATE1_8000000)) {
                    rightHandDLists = &gPlayerRightHandClosedDLs[D_801F59E0];
                    sPlayerRightHandType = PLAYER_MODELTYPE_RH_CLOSED;
                } else {
                    s32 handIndex = GET_RIGHT_HAND_INDEX_FROM_JOINT_TABLE(player->skelAnime.jointTable);

                    if (handIndex != 0) {
                        handIndex = (handIndex >> 8) - 1;
                        if (handIndex >= 2) {
                            recomp_printf("Avoiding OoB right hand dlist access: %d\n", handIndex);
                            handIndex = 0;
                        }
                        rightHandDLists = &D_801C0964[handIndex][D_801F59E0];
                    }
                }

                *dList = rightHandDLists[sPlayerLod];
                if (player->skelAnime.animation == &gPlayerAnim_pg_punchB) {
                    func_80125CE0(player, D_801C0784, pos, rot);
                }
            }
        } else if (limbIndex == PLAYER_LIMB_SHEATH) {
            Gfx** sheathDLists = player->sheathDLists;

            if (player->transformation == PLAYER_FORM_HUMAN) {
                EquipValueSword swordEquipValue = GET_CUR_EQUIP_VALUE(EQUIP_TYPE_SWORD);

                if (swordEquipValue != EQUIP_VALUE_SWORD_NONE) {
                    if ((player->sheathType == PLAYER_MODELTYPE_SHEATH_14) ||
                        (player->sheathType == PLAYER_MODELTYPE_SHEATH_12)) {
                        sheathDLists = &gPlayerSheathedSwords[2 * ((swordEquipValue - 1) ^ 0)];
                    } else {
                        sheathDLists = &gPlayerSwordSheaths[2 * ((swordEquipValue - 1) ^ 0)];
                    }
                }
            }

            *dList = sheathDLists[sPlayerLod];
        } else if (limbIndex == PLAYER_LIMB_WAIST) {
            *dList = player->waistDLists[sPlayerLod];
        } else if (limbIndex == PLAYER_LIMB_HAT) {
            if (player->transformation == PLAYER_FORM_ZORA) {
                Matrix_Scale((player->unk_B10[0] * 1) + 1.0f, 1.0f, 1.0f, MTXMODE_APPLY);
            }
        }
    }

    return false;
}
