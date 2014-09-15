
#ifndef SERIAL_OUTPUT_H_
#define SERIAL_OUTPUT_H_

#include <stdint.h>

void InitialiseSerialOutput();

void WriteOut(char* value);

/* Note that the name is designed to be 9 characters: xxxx.xxxx */
void RecordAnalytics(char* name, uint32_t timeInSeconds, uint16_t value);

/* Note that the name is designed to be 9 characters: xxxx.xxxx */
void RecordFloatAnalytics(char* name, uint32_t timeInSeconds, float value);

#endif
