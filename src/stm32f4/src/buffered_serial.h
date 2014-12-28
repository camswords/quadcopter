
#ifndef BUFFERED_SERIAL_H
#define BUFFERED_SERIAL_H

#include <ring_buffer.h>

RingBuffer buffer;

void InitialiseSerialBuffer();

void WriteToSerialBuffer(uint16_t value);

void FlushPortionOfSerialBuffer();
void FlushEntireSerialBuffer();

#endif
