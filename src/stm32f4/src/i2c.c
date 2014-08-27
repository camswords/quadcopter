#include <i2c.h>
#include <stm32f4xx_i2c.h>

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
	I2C_InitStruct.I2C_Ack = I2C_Ack_Disable;

	/* 7 bit acknowledge addresses, hmm strange. */
	I2C_InitStruct.I2C_AcknowledgedAddress = I2C_AcknowledgedAddress_7bit;
	I2C_Init(I2C1, &I2C_InitStruct);

	/* Turn it on! */
	I2C_Cmd(I2C1, ENABLE);
};

