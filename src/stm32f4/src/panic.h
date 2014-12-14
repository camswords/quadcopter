
#ifndef PANIC_H
#define PANIC_H

#include <stdint.h>

void panic(char* message);
void panicWithValue(char* message, uint32_t value);

#endif
