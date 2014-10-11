#ifndef RING_BUFFER_H_
#define RING_BUFFER_H_

#include <stdint.h>

#define RING_BUFFER_SIZE 512

typedef struct RingBuffer
{
	uint16_t buffer[RING_BUFFER_SIZE];
	int head;
	int tail;
	int count;
} RingBuffer;

void  InitialiseRingBuffer(RingBuffer *_this);
int RingBufferIsEmpty(RingBuffer *_this);
int RingBufferIsFull(RingBuffer *_this);
uint16_t RingBufferPop(RingBuffer *_this);
void RingBufferPut(RingBuffer *_this, uint16_t value);


#endif
