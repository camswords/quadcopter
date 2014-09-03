#include <i2c.h>
#include <stm32f4xx_i2c.h>

/* Note: could PEC positioning help ensure correctness? */
/* Note: could improve speed by reading from multiple registers one after the other */
/* Note: The 9DOF sensor has internal resistors */
/* Note: should convert the while loops to not loop forever */
/* Note: the power (SDA, SCL, VDD) lines on the i2c bus should be checked for random voltage spikes. I have heard reports a tantalum cap might be needed */

void InitialiseI2C() {

	/* enable the clock to i2c1 */
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_I2C1, ENABLE);

	/* enable the clock to the pins that will be used */
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOB, ENABLE);

	/* setting the pins to open drain will ensure masters and slaves can only decide
	 * to pull the line low, or leave the line alone. In the case of leaving the line alone the pull up resistors
	 * will drive the input high.
	 *
	 * This allows for us to have multiple masters, or to allow slaves to stretch when they need more time.
	 * See http://www.i2c-bus.org/how-i2c-hardware-works/.
	 */
	GPIO_InitTypeDef GPIO_InitStruct;
	GPIO_InitStruct.GPIO_Pin = GPIO_Pin_8 | GPIO_Pin_9;
	GPIO_InitStruct.GPIO_Mode = GPIO_Mode_AF;
	GPIO_InitStruct.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_InitStruct.GPIO_OType = GPIO_OType_OD;
	GPIO_InitStruct.GPIO_PuPd = GPIO_PuPd_UP;
	GPIO_Init(GPIOB, &GPIO_InitStruct);

	/* PB.08 is SCL: the clock for the i2c protocol
	 * PB.09 is SDA: the data line for the i2c protocol
	 */
	GPIO_PinAFConfig(GPIOB, GPIO_PinSource8, GPIO_AF_I2C1);
	GPIO_PinAFConfig(GPIOB, GPIO_PinSource9, GPIO_AF_I2C1);

	I2C_InitTypeDef I2C_InitStruct;
	/* note that the clock speed should be able to go up to 400kHz */
	I2C_InitStruct.I2C_ClockSpeed = 100000; 		// 100kHz

	/* Use I2c (alternative is an SMBus device) */
	I2C_InitStruct.I2C_Mode = I2C_Mode_I2C;

	/* Duty Cycle is 50% as per standard */
	I2C_InitStruct.I2C_DutyCycle = I2C_DutyCycle_2;

	/* Only useful for slave mode (will we do this later? maybe) */
	I2C_InitStruct.I2C_OwnAddress1 = 0x00;

	/* Acknowledgement on read is disabled here as it is explicitly enabled / disabled when retrieving data. */
	I2C_InitStruct.I2C_Ack = I2C_Ack_Disable;

	/* 7 bit acknowledge addresses, hmm strange. */
	I2C_InitStruct.I2C_AcknowledgedAddress = I2C_AcknowledgedAddress_7bit;
	I2C_Init(I2C1, &I2C_InitStruct);

	/* Turn it on! */
	I2C_Cmd(I2C1, ENABLE);
};

void SendStart() {
	/* Begin comms! */
	I2C_GenerateSTART(I2C1, ENABLE);

	/* Start condition has been correctly released on the bus (will fail if another device attempts to communicate and bus not free) */
	/* hmmm. I don't like while loops that never stop. */
	while(!I2C_CheckEvent(I2C1, I2C_EVENT_MASTER_MODE_SELECT));
}

void SendAddress(uint8_t address, uint8_t direction) {
	/* send the address */
	I2C_Send7bitAddress(I2C1, address, direction);

	/* Wait for peripheral to acknowledge (own up) to the sent address */
	if (direction == I2C_Direction_Transmitter) {
		while(!I2C_CheckEvent(I2C1, I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED));
	} else {
		while(!I2C_CheckEvent(I2C1, I2C_EVENT_MASTER_RECEIVER_MODE_SELECTED));
	}
}

void SendData(uint8_t data) {
	/* make sure that the bus is not transmitting */
	while(!I2C_CheckEvent(I2C1, I2C_EVENT_MASTER_BYTE_TRANSMITTING));

	/* send the data */
	I2C_SendData(I2C1, data);

	/* wait for confirmation */
	/* Testing on this event over I2C_EVENT_MASTER_BYTE_TRANSMITTING is more reliable, and slower. */
	while(!I2C_CheckEvent(I2C1, I2C_EVENT_MASTER_BYTE_TRANSMITTED));
}

void SendStop() {
	/* Communication is over for now */
	I2C_GenerateSTOP(I2C1, ENABLE);
}

uint8_t ReadDataExpectingEnd() {
	/* don't automatically reply "yes, more". Instead, we will send a NACK to indicate no more. */
	I2C_AcknowledgeConfig(I2C1, DISABLE);

	/* wait till the data is ready */
	while(!I2C_CheckEvent(I2C1, I2C_EVENT_MASTER_BYTE_RECEIVED));

	/* return the read data */
	return I2C_ReceiveData(I2C1);
}

uint8_t ReadFromAddressRegister(uint8_t peripheralAddress, uint8_t registerAddress) {
	SendStart();
	SendAddress(peripheralAddress, I2C_Direction_Transmitter);
	SendData(registerAddress);
	SendStart();
	SendAddress(0xD0, I2C_Direction_Receiver);
	uint8_t data = ReadDataExpectingEnd();
	SendStop();
	return data;
}


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


void ReadGyroscopeValues(struct AngularPosition* angularPosition) {
	uint8_t temperatureHigh = ReadFromAddressRegister(0xD0, 0x1B);
	uint8_t temperatureLow = ReadFromAddressRegister(0xD0, 0x1C);
	uint8_t xHigh = ReadFromAddressRegister(0xD0, 0x1D);
	uint8_t xLow = ReadFromAddressRegister(0xD0, 0x1E);
	uint8_t yHigh = ReadFromAddressRegister(0xD0, 0x1F);
	uint8_t yLow = ReadFromAddressRegister(0xD0, 0x20);
	uint8_t zHigh = ReadFromAddressRegister(0xD0, 0x21);
	uint8_t zLow = ReadFromAddressRegister(0xD0, 0x22);

	/* To explain the crazy temperature calculation,
	 * see the comments by ErieRider at https://www.sparkfun.com/products/10724 */
	int16_t temperature = (((int16_t) temperatureHigh << 8) | temperatureLow);
	angularPosition->gyroscopeTemperature = 35 + (temperature + 13200) / 280;
	angularPosition->x = (((int16_t) xHigh << 8) | xLow);
	angularPosition->y = (((int16_t) yHigh << 8) | yLow);
	angularPosition->z = (((int16_t) zHigh << 8) | zLow);

}

struct AngularPosition CreateInitialAngularPosition() {
	struct AngularPosition angularPosition;
	angularPosition.gyroscopeTemperature = 0;
	angularPosition.x = 0;
	angularPosition.y = 0;
	angularPosition.z = 0;
	return angularPosition;
}
