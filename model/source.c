#include "header.h"

// Funzione di utilità per convertire float in bit (utile per i casi speciali)
uint32_t float_to_bits(float f) {
    return *((uint32_t*)&f);
}

uint32_t golden_model(float val)
{
    // =========================================================================
    // 1. GESTIONE CASI SPECIALI (FLAGS & ECCEZIONI)
    // =========================================================================
    
    // Se l'input è Not-a-Number (NaN), restituiamo NaN
    if (isnan(val)) {
        return 0x7FC00000; 
    }
    
    // Se l'input è +Infinito, e^inf = +Infinito
    if (val == INFINITY) {
        return 0x7F800000;
    }
    
    // Se l'input è -Infinito, e^-inf = +0
    if (val == -INFINITY) {
        return 0x00000000;
    }
    
    // OVERFLOW: Se val > 88.72, e^x supera il limite massimo rappresentabile dai float 32-bit.
    // L'hardware dovrà alzare la flag Overflow (OF) e restituire +Infinito.
    if (val > 88.722839f) {
        return 0x7F800000;
    }
    
    // UNDERFLOW: Se val < -103.97, e^x è così vicino a zero che il float 32-bit non ce la fa a rappresentarlo.
    // L'hardware dovrà alzare la flag Underflow (UF) e restituire +0.
    if (val < -103.97f) {
        return 0x00000000;
    }

    // =========================================================================
    // 2. CONVERSIONE INPUT IN VIRGOLA FISSA (Q8.24) E RIDUZIONE DEL RANGE
    // =========================================================================

    const int32_t log2e = 24204615; // 1.442695 * 2^24
    
    // Moltiplichiamo il float in ingresso per 2^24 per farlo diventare un intero a 32 bit (formato Q8.24).
    // In hardware questo corrisponde a estrarre la mantissa IEEE e shiftarla in base all'esponente.
    int32_t valq8_24 = (int32_t)(val * 16777216.0f); 
    
    // Moltiplichiamo X * log2(e).
    // Usiamo int64_t perché Q8.24 * Q8.24 = Q16.48 (serve un contenitore più grande per non perdere bit)
    int64_t y = (int64_t)valq8_24 * log2e;  
    
    // Shiftiamo a destra di 24 per ritornare al nostro comodo formato Q8.24 a 32 bit
    int32_t y_fixed = (int32_t)(y >> 24); 

    // =========================================================================
    // 3. SEPARAZIONE PARTE INTERA E FRAZIONARIA (LO SPLITTER)
    // =========================================================================

    // La parte intera (I) sono gli 8 bit più alti. Lo shift a destra aritmetico
    // in C mantiene magicamente intatti anche i numeri negativi (Complemento a due = Magia!).
    int32_t y_int = (y_fixed >> 24);
    
    // La parte frazionaria (F) sono i 24 bit più bassi. Mascheriamo via gli 8 bit alti.
    int32_t y_frac = (y_fixed & 0x00FFFFFF);
    
    // Per la LUT prendiamo i 5 bit più alti della frazione (da 23 a 19)
    int32_t lut_index = (y_frac >> 19);
    
    // Per Horner prendiamo i rimanenti 19 bit più bassi mascherandoli. 
    // NON facciamo nessuno shift a sinistra per non distruggere il loro valore decimale microscopico.
    int32_t small_frac = (y_frac & 0x0007FFFF);

    // =========================================================================
    // 4. CALCOLO DELLA MANTISSA (HORNER + LUT)
    // =========================================================================

    // ALGORITMO DI HORNER: 1 + F2 * (ln2 + F2 * (ln2^2 / 2))
    
    // Passo 1: small_frac * C2
    int32_t step1 = (int32_t)( ((int64_t)small_frac * C2) >> 24 );
    
    // Passo 2: Aggiungo C1 e moltiplico di nuovo per small_frac
    int32_t step2 = (int32_t)( ((int64_t)small_frac * (C1 + step1)) >> 24 );
    
    // Passo 3: Aggiungo 1.0 (C0). Questo è il risultato 2^(F2)
    int32_t val_horner = C0 + step2;

    // Lettura dalla ROM (LUT) per ottenere 2^(F1)
    int32_t val_lut = LUT_EXP[lut_index];
    
    // Moltiplicatore finale: 2^(F1) * 2^(F2) = 2^F. 
    // Questo numero è compreso tra 1.0 e 1.999..., ed è la nostra MANTISSA COMPLETA.
    int32_t mantissa_completa = (int32_t)( ((int64_t)val_lut * val_horner) >> 24 );

    // =========================================================================
    // 5. ASSEMBLAGGIO FINALE NEL FORMATO IEEE 754 (32-BIT BUS)
    // =========================================================================

    // L'esponente finale è la parte intera più il Bias (127) dell'IEEE 754
    int32_t esponente_ieee = y_int + 127;
    
    // La mantissa IEEE richiede solo 23 bit. Il nostro risultato ne ha 24 (l'1 nascosto è al 24esimo posto).
    // Mascheriamo l'1 iniziale (con 0x00FFFFFF) e shiftiamo a destra di 1 per ridurre da 24 a 23 bit.
    int32_t mantissa_ieee = (mantissa_completa & 0x00FFFFFF) >> 1;
    
    // Assembliamo i cavi sul bus di uscita: Segno (0, sempre positivo) | Esponente (8 bit) | Mantissa (23 bit)
    uint32_t risultato_raw = (0 << 31) | (esponente_ieee << 23) | mantissa_ieee;

    return risultato_raw;
}
