#include <i2c.h>
#include <stm32f4xx_i2c.h>

/* Note: could PEC positioning help ensure correctness? */

/* Events:
	I2C_EVENT_SLAVE_TRANSMITTER_ADDRESS_MATCHED: EV1
	I2C_EVENT_SLAVE_RECEIVER_ADDRESS_MATCHED: EV1
	I2C_EVENT_SLAVE_TRANSMITTER_SECONDADDRESS_MATCHED: EV1
	I2C_EVENT_SLAVE_RECEIVER_SECONDADDRESS_MATCHED: EV1
	I2C_EVENT_SLAVE_GENERALCALLADDRESS_MATCHED: EV1
	I2C_EVENT_SLAVE_BYTE_RECEIVED: EV2
	(I2C_EVENT_SLAVE_BYTE_RECEIVED | I2C_FLAG_DUALF): EV2
	(I2C_EVENT_SLAVE_BYTE_RECEIVED | I2C_FLAG_GENCALL): EV2
	I2C_EVENT_SLAVE_BYTE_TRANSMITTED: EV3
	(I2C_EVENT_SLAVE_BYTE_TRANSMITTED | I2C_FLAG_DUALF): EV3
	(I2C_EVENT_SLAVE_BYTE_TRANSMITTED | I2C_FLAG_GENCALL): EV3
	I2C_EVENT_SLAVE_ACK_FAILURE: EV3_2
	I2C_EVENT_SLAVE_STOP_DETECTED: EV4
	I2C_EVENT_MASTER_MODE_SELECT: EV5
	I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED: EV6
	I2C_EVENT_MASTER_RECEIVER_MODE_SELECTED: EV6
	I2C_EVENT_MASTER_BYTE_RECEIVED: EV7
	I2C_EVENT_MASTER_BYTE_TRANSMITTING: EV8
	I2C_EVENT_MASTER_BYTE_TRANSMITTED: EV8_2
	I2C_EVENT_MASTER_MODE_ADDRESS10: EV9
*/

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

	/* Disable this for now, though we might need to turn on later */
	I2C_InitStruct.I2C_Ack = I2C_Ack_Enable;

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
	while(!I2C_CheckEvent(I2C1, I2C_EVENT_MASTER_TRANSMITTER_MODE_SELECTED));
}

void SendData(uint8_t data) {
	/* send the data */
	I2C_SendData(I2C1, data);

	/* wait for confirmation */
	/* Testing on this event over I2C_EVENT_MASTER_BYTE_TRANSMITTING is more reliable, and slower. */
	while(!I2C_CheckEvent(I2C1, I2C_EVENT_MASTER_BYTE_TRANSMITTED));
}

void InitialiseGyroscope() {
	SendStart();

	/* Talk to the Gyro */
	SendAddress(0xD0, I2C_Direction_Transmitter);

	/* Reset the Gyro */
	SendData(0x3E);
	SendData(0x80);

	/* Setup:
	 * the full scale range of the gyro should be +/-2000 degrees / second
	 * digital low pass filter bandwidth is 42Hz, internal sample rate is 1kHz.
	 * Note: we could adjust the low pass filter in future to see the impact.
	 */
	SendData(0x16);
	SendData(0x1B);

	/* Set the sample rate
	 * Sample rate = internal sample rate / (divider + 1)
	 * Setting divider to 4 to give a sample rate of 200Hz.
	 * The gyro values will update every 5ms.
	 */
	SendData(0x15);
	SendData(0x04);

	/* Set the clock source to PLL with Z Gyro as the reference.
	 * This should be more stable / accurate than an internal oscillator (which would be greatly affected by temperature)
	 * Probably not as good as an external oscillator though.
	 */
	SendData(0x3E);
	SendData(0x03);
};

