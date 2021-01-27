#include <stdio.h>
#include "libBackend.h"

int main(int argc, char **argv) {
    Backend_Start();

    while (true) {
        char c = getchar();
        if (c == EOF) break;
        putchar(c);
    }

    Backend_Stop();
    
    return 0;
}