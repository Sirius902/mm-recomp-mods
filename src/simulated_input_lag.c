#include "modding.h"
#include "global.h"
#include "libc/string.h"
#include "recomputils.h"
#include "recompconfig.h"
#include "z64lib.h"

static Input* input_queue = NULL;
static unsigned long input_queue_cap = 0;
static unsigned long input_queue_len = 0;

static s32 arg_game_request;
static Input* arg_inputs;

static Input hook_prev_input;

RECOMP_HOOK("PadMgr_GetInput") void get_input_hook(Input* inputs, s32 gameRequest) {
    if (!gameRequest) {
        return;
    }

    arg_inputs = inputs;
    arg_game_request = gameRequest;

    memcpy(&hook_prev_input, &inputs[0], sizeof(Input));

    unsigned long num_frames = (unsigned long)recomp_get_config_double("num_frames");

    // TODO(Sirius902) Copy over queued inputs?
    if (input_queue != NULL && input_queue_cap != num_frames) {
        recomp_free(input_queue);

        input_queue = NULL;
        input_queue_cap = 0;
        input_queue_len = 0;
    }

    if (input_queue == NULL && num_frames > 0) {
        // TODO(Sirius902) Free this when the game is closing.
        input_queue = recomp_alloc(num_frames * sizeof(Input));
        input_queue_cap = num_frames;
    }
}

RECOMP_HOOK_RETURN("PadMgr_GetInput") void get_input_return_hook(void) {
    if (!arg_game_request) {
        return;
    }

    unsigned long num_frames = (unsigned long)recomp_get_config_double("num_frames");
    if (num_frames == 0) {
        return;
    }

    Input new_input;
    memcpy(&new_input, &arg_inputs[0], sizeof(Input));

    if (input_queue_len == input_queue_cap) {
        memcpy(&arg_inputs[0], &input_queue[input_queue_len - 1], sizeof(Input));
    } else {
        memcpy(&arg_inputs[0], &hook_prev_input, sizeof(Input));
    }

    if (input_queue_len > 0) {
        memmove(&input_queue[1], &input_queue[0], MIN(input_queue_len, input_queue_cap - 1) * sizeof(Input));
    }

    memcpy(&input_queue[0], &new_input, sizeof(Input));
    if (input_queue_len < input_queue_cap) {
        input_queue_len++;
    }
}
