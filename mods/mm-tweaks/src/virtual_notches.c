#include "modding.h"
#include "global.h"
#include "recomputils.h"
#include "recompconfig.h"

#include "root.h"

static Input* arg_inputs;

RECOMP_HOOK("PadMgr_GetInput") void vn_get_input_hook(Input* inputs, s32 gameRequest) {
    arg_inputs = inputs;
}

RECOMP_HOOK_RETURN("PadMgr_GetInput") void vn_get_input_return_hook(void) {
    VirtualNotches_Apply(&arg_inputs[0], recomp_get_config_double("virtual_notch_degrees"));
}
