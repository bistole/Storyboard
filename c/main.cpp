#include <stdio.h>
#include "libBackend.h"

int main(int argc, char **argv) {
    char *path = (char *)"./Storyboard_backend_only";
    Backend_Start(path);

    while (true) {
        char c = getchar();
        if (c == 'q') break;
        putchar(c);
    }

    Backend_Stop();
    
    return 0;
}