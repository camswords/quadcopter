#include <analytics.h>
#include <serial_output.h>
#include <delay.h>
#include <configuration.h>

void InitialiseAnalytics() {
	InitialiseRingBuffer(&metricsRingBuffer);
	InitialiseSerialOutput();
}

void WriteStringToBuffer(char* value) {
	char* letter = value;

	while(*letter) {
		RingBufferPut(&metricsRingBuffer, *letter++);
	}
}

void WriteCharacterToBuffer(uint16_t value) {
	RingBufferPut(&metricsRingBuffer, value);
}

void RecordWarningMessage(char *message) {
	WriteStringToBuffer("info.warn:W:");
	WriteStringToBuffer(message);
}

void RecordPanicMessage(char *message) {
	WriteStringToBuffer("info.err-:E:");
	WriteStringToBuffer(message);
}

void RecordMetric(uint8_t type, uint8_t loopReference, float value) {
	WriteCharacterToBuffer('S');
	WriteCharacterToBuffer(type);
	WriteCharacterToBuffer(loopReference);
	WriteCharacterToBuffer(type);

	int32_t roundedValue = (value * 1000000);
	uint8_t valueHighest = (roundedValue >> 24) & 0xFF;
	uint8_t valueHigh = (roundedValue >> 16) & 0xFF;
	uint8_t valueLow = (roundedValue >> 8) & 0xFF;
	uint8_t valueLowest = (roundedValue >> 0) & 0xFF;

	WriteCharacterToBuffer(valueHighest);
	WriteCharacterToBuffer(valueHigh);
	WriteCharacterToBuffer(valueLow);
	WriteCharacterToBuffer(valueLowest);
}

void FlushMetrics() {
	uint8_t metricsFlushed = 0;

	while(metricsFlushed < ANALYTICS_CHARACTERS_TO_SEND_PER_FLUSH && metricsRingBuffer.count > 0) {
		WriteData(RingBufferPop(&metricsRingBuffer));
		metricsFlushed++;
	}
}

void FlushAllMetrics() {
	while(metricsRingBuffer.count > 0) {
		WriteData(RingBufferPop(&metricsRingBuffer));
		WaitAFewMillis(10);
	}
}
