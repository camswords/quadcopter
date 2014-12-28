

#include <buffered_serial.h>
#include <serial_output.h>
#include <configuration.h>
#include <delay.h>

void InitialiseSerialBuffer() {
	InitialiseRingBuffer(&buffer);
	InitialiseSerialOutput();
}

void WriteToSerialBuffer(uint16_t value) {
	RingBufferPut(&buffer, value);
}

void FlushPortionOfSerialBuffer() {
	uint8_t charactersFlushed = 0;

	while(charactersFlushed < SERIAL_BUFFER_CHARACTERS_TO_SEND_PER_FLUSH && buffer.count > 0) {
		WriteData(RingBufferPop(&buffer));
		charactersFlushed++;
	}
}

void FlushEntireSerialBuffer() {
	while(buffer.count > 0) {
		WriteData(RingBufferPop(&buffer));
		WaitAFewMillis(10);
	}
}

