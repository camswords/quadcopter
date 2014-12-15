

#include <gyroscope.h>
#include <delay.h>
#include <systick.h>
#include <math.h>

/* Note: could PEC positioning help ensure correctness?
 * Note: The 9DOF sensor has internal resistors
 * Note: the power (SDA, SCL, VDD) lines on the i2c bus should be checked for random voltage spikes. I have heard reports a tantalum cap might be needed
 * Note that typically as you increase range sensitivity suffers causing reduced resolution.
 * Note that a gyro suffers from drift error. Note that temperature greatly affects the drift.
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
	 * digital low pass filter bandwidth is 5Hz, internal sample rate is 1kHz.
	 * Note: we could adjust the low pass filter in future to see the impact.
	 */
	SendStart();
	SendAddress(0xD0, I2C_Direction_Transmitter);
	SendData(0x16);
	SendData(0x1E);
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
	gyroscopeReading.gyroscopeTemperature = 0.0f;
	gyroscopeReading.x = 0.0f;
	gyroscopeReading.y = 0.0f;
	gyroscopeReading.z = 0.0f;
	gyroscopeReading.xOffset = 0.0f;
	gyroscopeReading.yOffset = 0.0f;
	gyroscopeReading.zOffset = 0.0f;
	gyroscopeReading.readings = 0;

	isReadingGyroscope = false;
};

void ReadGyroscope() {

	if (i2cInUse) {
		// intentionally allow the i2c interrupt routine time to complete
		return;
	}

	if (!isReadingGyroscope) {
		// kick off a new read of the gyroscope values
		ReadFromAddress(0xD0, 0x1B, 8);
		isReadingGyroscope = true;
		return;
	}

	uint8_t temperatureHigh = incoming[0];
	uint8_t temperatureLow = incoming[1];
	uint8_t xHigh = incoming[2];
	uint8_t xLow = incoming[3];
	uint8_t yHigh = incoming[4];
	uint8_t yLow = incoming[5];
	uint8_t zHigh = incoming[6];
	uint8_t zLow = incoming[7];

	/* Temperature offset: -13200 LSB
	 * Temperature sensitivity: 280 LSB / degrees celcius
	 */
	int16_t rawTemperature = (((int16_t) temperatureHigh << 8) | temperatureLow);
	gyroscopeReading.gyroscopeTemperature = 35 + (rawTemperature + 13200) / 280;

	int16_t rawX = (((int16_t) xHigh << 8) | xLow);
	int16_t rawY = (((int16_t) yHigh << 8) | yLow);
	int16_t rawZ = (((int16_t) zHigh << 8) | zLow);

	/* gyro sensitivity: 14.375 LSB / (degrees / second) */
	float xDegreesPerSecond = ((float) rawX / 14.375f) - gyroscopeReading.xOffset;
	float yDegreesPerSecond = ((float) rawY / 14.375f) - gyroscopeReading.yOffset;
	float zDegreesPerSecond = ((float) rawZ / 14.375f) - gyroscopeReading.zOffset;

	if (!isnan(xDegreesPerSecond) && !isnan(yDegreesPerSecond) && !isnan(zDegreesPerSecond)) {
		gyroscopeReading.x = xDegreesPerSecond;
		gyroscopeReading.y = yDegreesPerSecond;
		gyroscopeReading.z = zDegreesPerSecond;
		gyroscopeReading.readings++;
	}

	isReadingGyroscope = false;
}
