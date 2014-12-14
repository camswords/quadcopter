

#include <panic.h>
#include <analytics.h>
#include <on_board_leds.h>

void panic(char* message) {
	TurnOn(RED_LED);
	RecordMessage(message);
}
