#ifndef ANALYTICS_H_
#define ANALYTICS_H_

#include <stdint.h>
#include <ring_buffer.h>

RingBuffer metricsRingBuffer;

void InitialiseAnalytics();

/* Note that the name is designed to be 9 characters: xxxx.xxxx */
void RecordMetric(uint8_t type, uint8_t loopReference, float value);

void RecordPanicMessage(char *message);
void RecordWarningMessage(char *message);

void FlushMetrics();
void FlushAllMetrics();

#endif
