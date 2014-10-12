#include <analytics.h>
#include <serial_output.h>

void InitialiseAnalytics() {
	InitialiseRingBuffer(&metricsRingBuffer);

	/* how often to flush the metrics (20 times per second) */
	analyticsFlushFrequency = 1000 / 20;
	charactersToSendPerFlush = 30;

	InitialiseSerialOutput();
}

void WriteStringToBuffer(char* value) {
	char* letter = value;

	while(*letter) {
		RingBufferPut(&metricsRingBuffer, *letter);
		*letter++;
	}
}

void WriteCharacterToBuffer(uint16_t value) {
	RingBufferPut(&metricsRingBuffer, value);
}

void RecordMetric(char* name, uint32_t timeInSeconds, float value) {
	WriteStringToBuffer(name);
	WriteStringToBuffer(":F:");

	uint8_t timeHighest = (timeInSeconds >> 24) & 0xFF;
	uint8_t timeHigh = (timeInSeconds >> 16) & 0xFF;
	uint8_t timeLow = (timeInSeconds >> 8) & 0xFF;
	uint8_t timeLowest = (timeInSeconds >> 0) & 0xFF;

	int32_t roundedValue = (value * 1000000);

	uint8_t valueHighest = (roundedValue >> 24) & 0xFF;
	uint8_t valueHigh = (roundedValue >> 16) & 0xFF;
	uint8_t valueLow = (roundedValue >> 8) & 0xFF;
	uint8_t valueLowest = (roundedValue >> 0) & 0xFF;

	WriteCharacterToBuffer(timeHighest);
	WriteCharacterToBuffer(timeHigh);
	WriteCharacterToBuffer(timeLow);
	WriteCharacterToBuffer(timeLowest);
	WriteCharacterToBuffer(valueHighest);
	WriteCharacterToBuffer(valueHigh);
	WriteCharacterToBuffer(valueLow);
	WriteCharacterToBuffer(valueLowest);
	WriteCharacterToBuffer('|');
}

void FlushMetrics() {
	uint8_t metricsFlushed = 0;

	while(metricsFlushed < charactersToSendPerFlush && metricsRingBuffer.count > 0) {
		WriteData(RingBufferPop(&metricsRingBuffer));
		metricsFlushed++;
	}
}
