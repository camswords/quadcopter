#include <i2c.h>

/* Note: should convert the while loops to not loop forever */
/* Hmm: what about when a client needs more time and attempts to extend the acknowledgement? */

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

uint8_t ReadDataExpectingMore() {
	/* automatically reply "yes, more" to tell the peripheral to move to the next register. */
	I2C_AcknowledgeConfig(I2C1, ENABLE);

	/* wait till the data is ready */
	while(!I2C_CheckEvent(I2C1, I2C_EVENT_MASTER_BYTE_RECEIVED));

	/* return the read data */
	return I2C_ReceiveData(I2C1);
}

uint8_t ReadDataExpectingEnd() {
	/* don't automatically reply "yes, more". Instead, we will send a NACK to indicate no more. */
	I2C_AcknowledgeConfig(I2C1, DISABLE);

	/* wait till the data is ready */
	while(!I2C_CheckEvent(I2C1, I2C_EVENT_MASTER_BYTE_RECEIVED));

	/* return the read data */
	return I2C_ReceiveData(I2C1);
}
