#include "header.h"

int main(int argc, char** argv)
{
//log2e in virgola mobile IEEE 754 sarebbe float log2e = 1.44269504, vogliamo portarlo in formato virgola fissa (fixed point) Q8.24 per farlo moltiplichiamo 1.44269504*2^24 e abbiamo 24204615 in decimale
const int32_t log2e = 24204615;
/* 
Sezione per le flags

*/
for (int i =1; i<argc; i++)
{
	float x = atof(argv[i]);
	int32_t x_new = (int32_t)x*16777216; //2^24 è 16777216 facciamo cast a int32_t 
	int32_t y = x_new*log2e; //moltiplichiamo i due numeri a virgola fissa Q8.24 ottenendo un numero a virgola fissa Q16.48
	y = (y<<24);
}



	return 0;
}
