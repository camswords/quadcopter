#ifndef ANALYTICS_H_
#define ANALYTICS_H_

#include <stdint.h>
#include <ring_buffer.h>

RingBuffer metricsRingBuffer;

void InitialiseAnalytics();

/* Note that the name is designed to be 9 characters: xxxx.xxxx */
void RecordMetric(char* name, uint32_t timeInSeconds, float value);

void RecordPanicMessage(char *message);
void RecordWarningMessage(char *message);

void FlushMetrics();
void FlushAllMetrics();

#endif
