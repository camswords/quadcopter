

#include <gyroscope.h>
#include <delay.h>

/* Note: could PEC positioning help ensure correctness? */
/* Note: The 9DOF sensor has internal resistors */
/* Note: the power (SDA, SCL, VDD) lines on the i2c bus should be checked for random voltage spikes. I have heard reports a tantalum cap might be needed */
/* Note that typically as you increase range sensitivity suffers causing reduced resolution.
/* Note that a gyro suffers from drift error. Note that temperature greatly affects the drift.
 * One way to calibrate is whenever you know the quadcopter is stationary, zero out the current measured values.
 * Note: on startup, we should zero out what is measured. Apparently a "zero" position is a "stressful" position for the device,
 *   each individual sensor will have different readings. Just average the first few readings.
 * Note: I probably shouldn't be afraid of longish (seconds) startup time. It may lead to better bias averaging.
 * Initial ZRO Tolerance is + / - 40 degrees / second. This depends a lot on temperature.
 */
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
	 * In theory 2000 degrees / second means the quad would be completely rotating 5 times per second! Probably higher than required.
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
	 * Accuracy of internal gyro MEMS oscillators are +/- 2% over temperature.
	 */
	SendStart();
	SendAddress(0xD0, I2C_Direction_Transmitter);
	SendData(0x3E);
	SendData(0x03);
	SendStop();

	/* The gyro takes 50 milliseconds for zero settling */
	WaitAFewMillis(50);

	/* And will take a further (or is this included?) 20ms for register read / write warm up */
	WaitAFewMillis(20);

	/* initialise the gyroscope reading */
	gyroscopeReading.gyroscopeTemperature = 0;
	gyroscopeReading.x = 0;
	gyroscopeReading.y = 0;
	gyroscopeReading.z = 0;
	gyroscopeReading.xOffset = 0;
	gyroscopeReading.yOffset = 0;
	gyroscopeReading.zOffset = 0;

	/* calibrate:
	 * collect samples for two seconds while at a "zero" position
	 * average out reading, use this as an offset value.
	 * Note that I should really look at this again once the temperature has been visualised using analytics
	 */
	uint16_t samples = 2000;
	float summedX = 0.0;
	float summedY = 0.0;
	float summedZ = 0.0;

	for (uint16_t i = 0; i < samples; i++) {
		ReadGyroscope(&gyroscopeReading);

		summedX += gyroscopeReading.x;
		summedY += gyroscopeReading.y;
		summedZ += gyroscopeReading.z;
	}

	gyroscopeReading.xOffset = summedX / samples;
	gyroscopeReading.yOffset = summedY / samples;
	gyroscopeReading.zOffset = summedZ / samples;
};

void ReadGyroscope() {
	/* Start reading from the high temperature register */
	SendStart();
	SendAddress(0xD0, I2C_Direction_Transmitter);
	SendData(0x1B);
	SendStart();
	SendAddress(0xD0, I2C_Direction_Receiver);

	/* Read the data and ACK on response. This will cause the peripheral to get ready
	 * to return the next register's data
	 * Note that the multibyte read strategy will prevent the sensor updating
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

	/* Temperature offset: -13200 LSB
	 * Temperature sensitivity: 280 LSB / degrees celcius
	 */
	int16_t rawTemperature = (((int16_t) temperatureHigh << 8) | temperatureLow);
	gyroscopeReading.gyroscopeTemperature = 35 + (rawTemperature + 13200) / 280;

	int16_t rawX = (((int16_t) xHigh << 8) | xLow);
	int16_t rawY = (((int16_t) yHigh << 8) | yLow);
	int16_t rawZ = (((int16_t) zHigh << 8) | zLow);

	/* gyro sensitivity: 14.375 LSB / (degrees / second) */
	gyroscopeReading.x = (rawX - gyroscopeReading.xOffset) / 14.375;
	gyroscopeReading.y = (rawY - gyroscopeReading.yOffset) / 14.375;
	gyroscopeReading.z = (rawZ - gyroscopeReading.zOffset) / 14.375;
}
