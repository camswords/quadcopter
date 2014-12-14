#ifndef ANALYTICS_H_
#define ANALYTICS_H_

#include <stdint.h>
#include <ring_buffer.h>

RingBuffer metricsRingBuffer;

/* how often the processing should be triggered */
int32_t analyticsFlushFrequency;

/* how many characters to send per flush */
uint32_t charactersToSendPerFlush;

void InitialiseAnalytics();

/* Note that the name is designed to be 9 characters: xxxx.xxxx */
void RecordMetric(char* name, uint32_t timeInSeconds, float value);

void RecordMessage(char *message);

void FlushMetrics();

#endif
