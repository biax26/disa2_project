#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h> 

int main(void)
{
    uint32_t val; 
    uint32_t cost = 16777216;
    FILE *file = fopen("lut.txt", "w");
    
    if (file == NULL)
    {
        printf("Errore nell'apertura del file!\n");
        return 1;
    }
    
    for (int i = 0; i < 32; i++)
    {
        val = (uint32_t)round(pow(2, (double)i/32)* cost); // con double non perdiamo la parte frazionaria e con round arrotondiamo al numero successivo più vicino 
        fprintf(file, "%08X   %d\n", val, val);
    }
    
    fclose(file);
    return 0;
}
