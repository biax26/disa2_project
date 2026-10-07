#include "header.h"

uint32_t float_to_bits(float f) { return *((uint32_t *)&f); }

uint32_t golden_model(float val) {
  // Casi speciali

  if (isnan(val)) {
    return 0x7FC00000;
  }

  if (val == INFINITY) {
    return 0x7F800000;
  }

  if (val == -INFINITY) {
    return 0x00000000;
  }

  if (val > 88.722839f) {
    return 0x7F800000;
  }

  if (val < -103.97f) {
    return 0x00000000;
  }

  const int32_t log2e = 24204406; // 1.442695 * 2^24

  // Moltiplichiamo il float in ingresso per 2^24 per farlo diventare un intero
  // a 32 bit (formato Q8.24).
  int32_t valq8_24 = (int32_t)(val * 16777216.0f);

  // Moltiplichiamo X * log2(e).
  // Usiamo int64_t perché Q8.24 * Q8.24 = Q16.48
  int64_t y = (int64_t)valq8_24 * log2e;

  // Shiftiamo a destra di 24 per ritornare al formato Q8.24 a 32
  // bit
  int32_t y_fixed = (int32_t)(y >> 24);

  int32_t y_int = (y_fixed >> 24);

  int32_t y_frac = (y_fixed & 0x00FFFFFF);

  int32_t lut_index = (y_frac >> 19);

  int32_t small_frac = (y_frac & 0x0007FFFF);

  // calcolo mantissa

  int32_t step1 = (int32_t)(((int64_t)small_frac * C2) >> 24);

  int32_t step2 = (int32_t)(((int64_t)small_frac * (C1 + step1)) >> 24);

  int32_t val_horner = C0 + step2;

  int32_t val_lut = LUT_EXP[lut_index];

  int32_t mantissa_completa = (int32_t)(((int64_t)val_lut * val_horner) >> 24);

  // final pack

  int32_t esponente_ieee = y_int + 127;

  int32_t mantissa_ieee = (mantissa_completa & 0x00FFFFFF) >> 1;

  uint32_t risultato_raw = (0 << 31) | (esponente_ieee << 23) | mantissa_ieee;

  return risultato_raw;
}
