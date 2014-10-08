
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
	/* removed because it looked wrong. will replace when I need the magnetometer. */
}
