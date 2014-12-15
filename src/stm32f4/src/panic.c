

#include <panic.h>
#include <analytics.h>
#include <on_board_leds.h>
#include <systick.h>
#include <stdio.h>
#include <inttypes.h>
#include <string.h>

void InitialisePanicButton() {
	clearWarningsOnSecondsElapsed = 0;
}

void panic(char* message) {
	TurnOn(RED_LED);

	int bufferLength = strlen(message) + strlen("|") + 1;
	char buffer[bufferLength];
	snprintf(buffer, bufferLength, "%s|", message);

	FlushAllMetrics();
	RecordPanicMessage(buffer);
	FlushAllMetrics();
}

void panicWithValue(char* message, uint32_t value) {
	TurnOn(RED_LED);

	const int translatedStringLength = snprintf(0, 0, " [0x%"PRIx32"]|", value);

	int bufferLength = strlen(message) + translatedStringLength + 1;
	char buffer[bufferLength];
	snprintf(buffer, bufferLength, "%s [0x%"PRIx32"]|", message, value);

	FlushAllMetrics();
	RecordPanicMessage(buffer);
	FlushAllMetrics();
}

void warning(char* message) {
	TurnOn(ORANGE_LED);
	clearWarningsOnSecondsElapsed = secondsElapsed + 5;

	int bufferLength = strlen(message) + strlen("|") + 1;
	char buffer[bufferLength];
	snprintf(buffer, bufferLength, "%s|", message);

	FlushAllMetrics();
	RecordWarningMessage(buffer);
	FlushAllMetrics();
}

void warningWithValue(char* message, uint32_t value) {
	TurnOn(ORANGE_LED);
	clearWarningsOnSecondsElapsed = secondsElapsed + 5;

	const int translatedStringLength = snprintf(0, 0, " [0x%"PRIx32"]|", value);

	int bufferLength = strlen(message) + translatedStringLength + 1;
	char buffer[bufferLength];
	snprintf(buffer, bufferLength, "%s [0x%"PRIx32"]|", message, value);

	FlushAllMetrics();
	RecordWarningMessage(buffer);
	FlushAllMetrics();
}

void ClearWarnings() {
	if (clearWarningsOnSecondsElapsed > 0 && secondsElapsed >= clearWarningsOnSecondsElapsed) {
		TurnOff(ORANGE_LED);
		clearWarningsOnSecondsElapsed = 0;
	}
}
