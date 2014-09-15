
#include <magnetometer.h>

void InitialiseMagnetometer() {
	/* wait until the line is not busy */
	while(I2C_GetFlagStatus(I2C1, I2C_FLAG_BUSY));

	/* Sample 8 samples per measurement.
	 * Data output rate of 75Hz.
	 * Normal measurement mode (no positive or negative bias).
	 * These are the maximum settings - too much?
	 */
	SendStart();
	SendAddress(0x3C, I2C_Direction_Transmitter);
	SendData(0x0);
	SendData(0x78);
	SendStop();

	/* This is the gain configuration.
	 * Currently configured to +/- 8.1 Ga
	 * This seems to be the largest range, though may mean higher standard deviation of output.
	 * May need to reconfigure this later.
	 */
	SendStart();
	SendAddress(0x3C, I2C_Direction_Transmitter);
	SendData(0x01);
	SendData(0xE0);
	SendStop();

	/* Set to continuous measurement mode */
	SendStart();
	SendAddress(0x3C, I2C_Direction_Transmitter);
	SendData(0x02);
	SendData(0x0);
	SendStop();
}

void ReadMagnetometer() {
	/* Start reading from the x high register */
	SendStart();
	SendAddress(0xA6, I2C_Direction_Transmitter);
	SendData(0x03);
	SendStart();
	SendAddress(0xA6, I2C_Direction_Receiver);

	/* Read the data and ACK on response. This will cause the peripheral to get ready to return the next register's data.
	 * Note that the multibyte read strategy will prevent the sensor updating half of the values in between a read.
	 */
	uint8_t xHigh = ReadDataExpectingMore();
	uint8_t xLow = ReadDataExpectingMore();
	uint8_t zHigh = ReadDataExpectingMore();
	uint8_t zLow = ReadDataExpectingMore();
	uint8_t yHigh = ReadDataExpectingMore();
	uint8_t yLow = ReadDataExpectingEnd();
	SendStop();

	/* Note that a read value of -4096 is used for math over/under flow for the channel / bias measurement */
	magnetometerReading.x = (((int16_t) xHigh << 8) | xLow);
	magnetometerReading.y = (((int16_t) yHigh << 8) | yLow);
	magnetometerReading.z = (((int16_t) zHigh << 8) | zLow);
}
