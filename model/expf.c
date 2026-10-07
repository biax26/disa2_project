#include <math.h>
#include <stdint.h>
#include <stdio.h>

int main() {
  uint32_t input_hex = 0xC13EA097;

  float f = *(float *)&input_hex;

  float ex = expf(f);

  uint32_t ex_hex = *(uint32_t *)&ex;

  printf("Input Float: %f\n", f);
  printf("expf() Float: %e\n", ex);
  printf("expf() Hex: %08X\n", ex_hex);

  return 0;
}