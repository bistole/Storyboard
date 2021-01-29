#include <stdio.h>

FILE __iob[3];
__declspec(dllexport) FILE* __cdecl __iob_func(void) {
    __iob[0] = *stdin;
    __iob[1] = *stdout;
    __iob[2] = *stderr;
    return __iob;
}

