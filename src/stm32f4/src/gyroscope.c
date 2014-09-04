

#include <gyroscope.h>

/* Note: could PEC positioning help ensure correctness? */
/* Note: The 9DOF sensor has internal resistors */
/* Note: the power (SDA, SCL, VDD) lines on the i2c bus should be checked for random voltage spikes. I have heard reports a tantalum cap might be needed */

void InitialiseGyroscope() {
	/* wait until the line is not busy */
	while(I2C_GetFlagStatus(I2C1, I2C_FLAG_BUSY));

	/* Reset the Gyro.
	 * Note that 0xD0 is the address of the Gyro on the bus.
	 */
	SendStart();
	SendAddress(0xD0, I2C_Direction_Transmitter);
	SendData(0x3E);
	SendData(0x80);
	SendStop();

	/* Setup:
	 * the full scale range of the gyro should be +/-2000 degrees / second
	 * digital low pass filter bandwidth is 42Hz, internal sample rate is 1kHz.
	 * Note: we could adjust the low pass filter in future to see the impact.
	 */
	SendStart();
	SendAddress(0xD0, I2C_Direction_Transmitter);
	SendData(0x16);
	SendData(0x1B);
	SendStop();

	/* Set the sample rate
	 * Sample rate = internal sample rate / (divider + 1)
	 * Setting divider to 4 to give a sample rate of 200Hz.
	 * The gyro values will update every 5ms.
	 */
	SendStart();
	SendAddress(0xD0, I2C_Direction_Transmitter);
	SendData(0x15);
	SendData(0x04);
	SendStop();

	/* Set the clock source to PLL with Z Gyro as the reference.
	 * This should be more stable / accurate than an internal oscillator (which would be greatly affected by temperature)
	 * Probably not as good as an external oscillator though.
	 */
	SendStart();
	SendAddress(0xD0, I2C_Direction_Transmitter);
	SendData(0x3E);
	SendData(0x03);
	SendStop();
};

struct GyroscopeReading CreateGyroscopeReading() {
	struct GyroscopeReading gyroscopeReading;
	gyroscopeReading.gyroscopeTemperature = 0;
	gyroscopeReading.x = 0;
	gyroscopeReading.y = 0;
	gyroscopeReading.z = 0;
	return gyroscopeReading;
}

void ReadGyroscope(struct GyroscopeReading* gyroscopeReading) {
	/* Start reading from the high temperature register */
	SendStart();
	SendAddress(0xD0, I2C_Direction_Transmitter);
	SendData(0x1B);
	SendStart();
	SendAddress(0xD0, I2C_Direction_Receiver);

	/* Read the data and ACK on response. This will cause the peripheral to get ready
	 * to return the next register's data
	 * Note that the multibyte read strategy should minimise (prevent?) the sensor updating
	 * half of the values in between a read.
	 */
	uint8_t temperatureHigh = ReadDataExpectingMore();
	uint8_t temperatureLow = ReadDataExpectingMore();
	uint8_t xHigh = ReadDataExpectingMore();
	uint8_t xLow = ReadDataExpectingMore();
	uint8_t yHigh = ReadDataExpectingMore();
	uint8_t yLow = ReadDataExpectingMore();
	uint8_t zHigh = ReadDataExpectingMore();

	/* Finally read the data and NACK on response. This lets the peripheral know that we are finished reading */
	uint8_t zLow = ReadDataExpectingEnd();
	SendStop();

	/* To explain the crazy temperature calculation,
	 * see the comments by ErieRider at https://www.sparkfun.com/products/10724 */
	int16_t temperature = (((int16_t) temperatureHigh << 8) | temperatureLow);
	gyroscopeReading->gyroscopeTemperature = 35 + (temperature + 13200) / 280;
	gyroscopeReading->x = (((int16_t) xHigh << 8) | xLow);
	gyroscopeReading->y = (((int16_t) yHigh << 8) | yLow);
	gyroscopeReading->z = (((int16_t) zHigh << 8) | zLow);
}
