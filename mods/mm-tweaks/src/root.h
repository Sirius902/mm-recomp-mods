#pragma once

#include "global.h"
#include "libc/stddef.h"

void InputQueue_SetDelay(size_t frames);
void InputQueue_Push(const Input* input);
bool InputQueue_Pop(Input* out);

void VirtualNotches_Apply(Input* input, double degrees);
