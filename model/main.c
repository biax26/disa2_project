#include "header.h"

// Funzione per stampare un float come esadecimale (utile per visualizzare
// l'input IEEE 754 in formato hex)
uint32_t f2u(float f) { return *((uint32_t *)&f); }

int main(void) {

  FILE *file = fopen("Inputs_and_Outputs(HEX)", "w");
  if (file == NULL) {
    printf("Errore nell'apertura del file!\n");
    return 1;
  }

  fprintf(file, "# Input (Hex) -> Output (Hex) | Commento\n");

  // Array di 10 casi speciali
  float special_cases[10] = {
      0.0f,      // Zero
      -0.0f,     // Zero negativo
      INFINITY,  // Infinito positivo
      -INFINITY, // Infinito negativo
      NAN,       // Not a Number
      90.0f,     // Overflow (maggiore del limite 88.72)
      -105.0f,   // Underflow (minore del limite -103.97)
      1.0f,      // exp(1) = numero di Nepero (e)
      -1.0f,     // exp(-1) = 1/e
      6.5f       // Numero di test
  };

  for (int i = 0; i < 10; i++) {
    float input = special_cases[i];

    uint32_t hw_output = golden_model(input);

    fprintf(file, "%08X %08X\n", f2u(input), hw_output);
  }
  // generazione 90 float casuali
  srand((unsigned int)time(NULL));

  for (int i = 0; i < 90; i++) {
    float random_input = ((float)rand() / (float)RAND_MAX) * 40.0f - 20.0f;

    uint32_t hw_output = golden_model(random_input);

    fprintf(file, "%08X %08X\n", f2u(random_input), hw_output);
  }

  fclose(file);
  printf("\n>>> Test vectors generati con successo nel file "
         "'Inputs_and_Outputs(HEX).txt'!\n");

  return 0;
}
