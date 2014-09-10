
#ifndef SERIAL_OUTPUT_H_
#define SERIAL_OUTPUT_H_

#include <stdint.h>

void InitialiseSerialOutput();

void WriteOut(char* value);

void RecordAnalytics(char* name, uint32_t timeInSeconds, uint16_t value);

#endif
