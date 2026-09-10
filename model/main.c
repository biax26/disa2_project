#include "header.h"

// Funzione helper per stampare un float come esadecimale (utile per
// visualizzare l'input IEEE 754 in formato hex)
uint32_t f2u(float f) { return *((uint32_t *)&f); }

int main(void) {
  // Apriamo il file in cui salveremo i risultati per poterli caricare in
  // ModelSim / Vivado
  FILE *file = fopen("outputs.txt", "w");
  if (file == NULL) {
    printf("Errore nell'apertura del file!\n");
    return 1;
  }

  printf("Inizio generazione dei 100 test vectors per ModelSim...\n\n");
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

  // =========================================================================
  // 1. ELABORAZIONE DEI 10 CASI SPECIALI
  // =========================================================================
  for (int i = 0; i < 10; i++) {
    float input = special_cases[i];

    // Passiamo il float al nostro golden model e riceviamo l'uscita a 32 bit
    // nuda e cruda
    uint32_t hw_output = golden_model(input);

    // Stampiamo su file le due stringhe esadecimali per ModelSim
    fprintf(file, "%08X %08X\n", f2u(input), hw_output);

    // Stampiamo a video per un feedback visivo immediato
    printf("Test Speciale %2d: Input = %8.3f (0x%08X) -> Output = 0x%08X\n",
           i + 1, input, f2u(input), hw_output);
  }

  // =========================================================================
  // 2. GENERAZIONE DI 90 CASI CASUALI (RANGE VALIDO)
  // =========================================================================
  srand((unsigned int)time(NULL));

  printf("\nGenerazione di 90 input random...\n");
  for (int i = 0; i < 90; i++) {
    // Generiamo un float casuale compreso in un range "sicuro" tra -20.0 e
    // +20.0
    float random_input = ((float)rand() / (float)RAND_MAX) * 40.0f - 20.0f;

    uint32_t hw_output = golden_model(random_input);

    // Scriviamo su file (Formato ideale per essere letto in VHDL tramite
    // textio)
    fprintf(file, "%08X %08X\n", f2u(random_input), hw_output);

    // Ne stampiamo solo un paio a video per non inondare il terminale
    if (i < 5) {
      printf("Test Random %2d: Input = %8.3f (0x%08X) -> Output = 0x%08X\n",
             i + 1, random_input, f2u(random_input), hw_output);
    }
  }

  fclose(file);
  printf("\n>>> Test vectors generati con successo nel file 'outputs.txt'!\n");

  return 0;
}
