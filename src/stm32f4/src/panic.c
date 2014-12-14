

#include <panic.h>
#include <analytics.h>
#include <on_board_leds.h>
#include <stdio.h>
#include <inttypes.h>
#include <string.h>

void panic(char* message) {
	TurnOn(RED_LED);

	int bufferLength = strlen(message) + strlen("|") + 1;
	char buffer[bufferLength];
	snprintf(buffer, bufferLength, "%s|", message);

	FlushAllMetrics();
	RecordMessage(buffer);
	FlushAllMetrics();
}

void panicWithValue(char* message, uint32_t value) {
	TurnOn(RED_LED);

	const int translatedStringLength = snprintf(0, 0, " [0x%"PRIx32"]|", value);

	int bufferLength = strlen(message) + translatedStringLength + 1;
	char buffer[bufferLength];
	snprintf(buffer, bufferLength, "%s [0x%"PRIx32"]|", message, value);

	FlushAllMetrics();
	RecordMessage(buffer);
	FlushAllMetrics();
}
