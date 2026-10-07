#ifndef HEADER_H
#define HEADER_H

#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define C0 16777216 // 1.0 * 2^24
#define C1 11629080 // ln(2) * 2^24
#define C2 4030331  // (ln(2))^2 / 2 * 2^24

// Lookup Table (LUT)

static const int32_t LUT_EXP[32] = {
    16777216, 17144589, 17520007, 17903645, 18295684, 18696307, 19105703,
    19524063, 19951585, 20388467, 20834917, 21291142, 21757357, 22233781,
    22720638, 23218155, 23726566, 24246111, 24777031, 25319578, 25874004,
    26440571, 27019544, 27611195, 28215802, 28833647, 29465022, 30110222,
    30769550, 31443315, 32131834, 32835430};

uint32_t golden_model(float val);

#endif
