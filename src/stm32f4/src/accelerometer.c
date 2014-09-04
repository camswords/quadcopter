
#include <accelerometer.h>

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
};

struct AccelerometerReading CreateAccelerometerReading() {
	struct AccelerometerReading accelerometerReading;
	return accelerometerReading;
}

void ReadAccelerometer(struct AccelerometerReading* accelerometerReading) {
}
