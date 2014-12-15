
#include <accelerometer.h>
#include <delay.h>
#include <math.h>

void InitialiseAccelerometer() {
	/* wait until the line is not busy */
	while(I2C_GetFlagStatus(I2C1, I2C_FLAG_BUSY));

	/* Turn off inactivity / activity interrupts for all axis */
	SendStart();
	SendAddress(0xA6, I2C_Direction_Transmitter);
	SendData(0x27);
	SendData(0x0);
	SendStop();

	/* Hmm: there are register offsets for each axis if required. See registers 0x1E, 0x1F, 0x20 */

	/* Turn off interrupts for tap detection */
	SendStart();
	SendAddress(0xA6, I2C_Direction_Transmitter);
	SendData(0x2A);
	SendData(0x0);
	SendStop();

	/* Select "Normal" power, this uses more power and has less noise (0x0.) */
	/* Select output data rate of 100kHz (0x.A) */
	/* Output data rate should match the bus frequency / sample rate. To make it 400kHz,
	 * change this value to (0x.C).
	 */
	SendStart();
	SendAddress(0xA6, I2C_Direction_Transmitter);
	SendData(0x2C);
	SendData(0x0A);
	SendStop();

	/* Put the accelerometer in "measurement" mode */
	/* Ensure the device will not sleep */
	SendStart();
	SendAddress(0xA6, I2C_Direction_Transmitter);
	SendData(0x2D);
	SendData(0x08);
	SendStop();

	/* Turn off all interrupts outputs */
	SendStart();
	SendAddress(0xA6, I2C_Direction_Transmitter);
	SendData(0x2E);
	SendData(0x0);
	SendStop();

	/* Turn self test off.
	 * Using three wire SPI mode (i2c?).
	 * Left justify mode (most significant bit).
	 * Full resolution, full range.
	 */
	SendStart();
	SendAddress(0xA6, I2C_Direction_Transmitter);
	SendData(0x31);
	SendData(0x4F);
	SendStop();

	/* initialise the accelerometer at zero position */
	accelerometerReading.x = 0.0f;
	accelerometerReading.y = 0.0f;
	accelerometerReading.z = 0.0f;
	accelerometerReading.xOffset = 0.0f;
	accelerometerReading.yOffset = 0.0f;
	accelerometerReading.zOffset = 0.0f;
	accelerometerReading.readings = 0;

	isReadingAccelerometer = false;
};

void ReadAccelerometer() {

	if (i2cInUse) {
		// intentionally allow the i2c interrupt routine time to complete
		return;
	}

	if (!isReadingAccelerometer) {
		// kick off a new read of the accelerometer values
		ReadFromAddress(0xA6, 0x32, 6);
		isReadingAccelerometer = true;
		return;
	}

	// done! convert the values to a reading
	uint8_t xLow = incoming[0];
	uint8_t xHigh = incoming[1];
	uint8_t yLow = incoming[2];
	uint8_t yHigh = incoming[3];
	uint8_t zLow = incoming[4];
	uint8_t zHigh = incoming[5];

	int16_t rawX = (((int16_t) xHigh << 8) | xLow);
	int16_t rawY = (((int16_t) yHigh << 8) | yLow);
	int16_t rawZ = (((int16_t) zHigh << 8) | zLow);

	float calibratedX = rawX - accelerometerReading.xOffset;
	float calibratedY = rawY - accelerometerReading.yOffset;
	float calibratedZ = rawZ - accelerometerReading.zOffset;

	/* calculate the squares */
	float xSquared = calibratedX * calibratedX;
	float ySquared = calibratedY * calibratedY;
	float zSquared = calibratedZ * calibratedZ;

	accelerometerReading.x = -atan(calibratedY / sqrt(xSquared + zSquared)) * 180.0f / 3.141592f;
	accelerometerReading.y = atan(calibratedX / sqrt(ySquared + zSquared)) * 180.0f / 3.141592f;
	accelerometerReading.z = 0.0f; // for now.
	accelerometerReading.readings++;
	isReadingAccelerometer = false;
}
