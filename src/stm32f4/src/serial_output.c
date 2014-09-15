
#include <serial_output.h>
#include <stm32f4xx_gpio.h>
#include <stm32f4xx_usart.h>

void InitialiseSerialOutput() {
	/* enable the clock to the GPIO C ports */
	RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOC, ENABLE);

	/* Enable the clock to UART4 */
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_UART4, ENABLE);

	/* Configure pins to be the alternate function for UART4 */
	GPIO_PinAFConfig(GPIOC, GPIO_PinSource10, GPIO_AF_UART4);
	GPIO_PinAFConfig(GPIOC, GPIO_PinSource11, GPIO_AF_UART4);

	/* Turn on Pin PC.10 (TX) and PC.11 (RX) */
	GPIO_InitTypeDef GPIO_InitStruct;
	GPIO_InitStruct.GPIO_Pin = GPIO_Pin_10 | GPIO_Pin_11;
	GPIO_InitStruct.GPIO_Mode = GPIO_Mode_AF;
	GPIO_InitStruct.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_InitStruct.GPIO_OType = GPIO_OType_PP;
	GPIO_InitStruct.GPIO_PuPd = GPIO_PuPd_UP;
	GPIO_Init(GPIOC, &GPIO_InitStruct);

	/* Initialise the UART */
	USART_InitTypeDef USART_InitStruct;
	USART_InitStruct.USART_BaudRate = 115200;
	USART_InitStruct.USART_WordLength = USART_WordLength_8b;
	USART_InitStruct.USART_StopBits = USART_StopBits_1;
	USART_InitStruct.USART_Parity = USART_Parity_No;
	USART_InitStruct.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
	USART_InitStruct.USART_Mode = USART_Mode_Tx | USART_Mode_Rx;
	USART_Init(UART4, &USART_InitStruct);

	/* enable the UART */
	USART_Cmd(UART4, ENABLE);
}

void WriteData(uint16_t data) {
	while(USART_GetFlagStatus(UART4, USART_FLAG_TXE) == RESET);
	USART_SendData(UART4, data);
}

void WriteOut(char* value) {
	char* letter = value;

	while(*letter) {
		WriteData(*letter);
		*letter++;
	}
}

void RecordAnalytics(char* name, uint32_t timeInSeconds, uint16_t value) {
	WriteOut(name);
	WriteOut(":I:");

	uint8_t timeHighest = (timeInSeconds >> 24) & 0xFF;
	uint8_t timeHigh = (timeInSeconds >> 16) & 0xFF;
	uint8_t timeLow = (timeInSeconds >> 8) & 0xFF;
	uint8_t timeLowest = (timeInSeconds >> 0) & 0xFF;

	uint8_t valueyHigh = (value >> 8) & 0xFF;
	uint8_t valueyLow = (value >> 0) & 0xFF;

	WriteData(timeHighest); /* high part of the time in seconds */
	WriteData(timeHigh); /* high part of the time in seconds */
	WriteData(timeLow); /* high part of the time in seconds */
	WriteData(timeLowest);  /* low part of the time in seconds */
	WriteData(valueyHigh);
	WriteData(valueyLow);
	WriteData('|');
}

void RecordFloatAnalytics(char* name, uint32_t timeInSeconds, float value) {
	WriteOut(name);
	WriteOut(":F:");

	uint8_t timeHighest = (timeInSeconds >> 24) & 0xFF;
	uint8_t timeHigh = (timeInSeconds >> 16) & 0xFF;
	uint8_t timeLow = (timeInSeconds >> 8) & 0xFF;
	uint8_t timeLowest = (timeInSeconds >> 0) & 0xFF;

	int32_t roundedValue = (value * 1000000);

	uint8_t valueHighest = (roundedValue >> 24) & 0xFF;
	uint8_t valueHigh = (roundedValue >> 16) & 0xFF;
	uint8_t valueLow = (roundedValue >> 8) & 0xFF;
	uint8_t valueLowest = (roundedValue >> 0) & 0xFF;

	WriteData(timeHighest);
	WriteData(timeHigh);
	WriteData(timeLow);
	WriteData(timeLowest);
	WriteData(valueHighest);
	WriteData(valueHigh);
	WriteData(valueLow);
	WriteData(valueLowest);
	WriteData('|');
}
