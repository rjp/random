#include <stdlib.h>
#include <stdio.h>

int main(void)
{
    char *x[] = {"2", "1e10", "0x42", "033", NULL};
    int i;

    for(i=0; x[i]; i++) {
        long y;
        char *out;
        y = strtol(x[i], &out, 0) + 1L;
        printf("%ld\n", y);
    }
}
