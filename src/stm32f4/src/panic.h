
#ifndef PANIC_H
#define PANIC_H

#include <stdint.h>

uint32_t clearWarningsOnSecondsElapsed;

void InitialisePanicButton();
void ClearWarnings();

void panic(char* message);
void panicWithValue(char* message, uint32_t value);

void warning(char* message);
void warningWithValue(char* message, uint32_t value);


#endif
