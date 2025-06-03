#include "modding.h"
#include "global.h"
#include "recomputils.h"
#include "recompconfig.h"

#include "libc/string.h"

#include "root.h"

static s32 arg_game_request;
static Input* arg_inputs;

static Input hook_prev_input;

RECOMP_HOOK("PadMgr_GetInput") void sid_get_input_hook(Input* inputs, s32 gameRequest) {
    if (!gameRequest) {
        return;
    }

    arg_inputs = inputs;
    arg_game_request = gameRequest;

    Lib_MemCpy(&hook_prev_input, &inputs[0], sizeof(Input));

    size_t num_frames = (size_t)recomp_get_config_double("input_delay_num_frames");
    InputQueue_SetDelay(num_frames);
}

RECOMP_HOOK_RETURN("PadMgr_GetInput") void sid_get_input_return_hook(void) {
    if (!arg_game_request) {
        return;
    }

    InputQueue_Push(&arg_inputs[0]);

    if (!InputQueue_Pop(&arg_inputs[0])) {
        Lib_MemCpy(&arg_inputs[0], &hook_prev_input, sizeof(Input));
    }
}
