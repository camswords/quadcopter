
#ifndef I2C_H
#define I2C_H

#include <stdint.h>
#include <stdbool.h>
#include <stm32f4xx_i2c.h>

/* Note that this is not defined by the STM32 Peripheral Library, but is a case that I need to cover in my I2C interrupt function. */
#define I2C_EVENT_MASTER_BYTE_RECEIVED_AND_TRANSFER_FINISHED ((uint32_t)0x00030044)  /* BUSY, MSL, RXNE and BTF flags */


bool i2cHasProblem;
bool i2cInUse;
bool i2cTransmitting;
uint32_t i2cMisunderstoodEvents;

/* the address to identify the peripheral we are communicating with */
uint8_t peripheralAddress;

/* the buffer for the characters to be sent */
uint8_t outgoing[10];
uint8_t expectedNumberOfOutgoing;
uint8_t outgoingIndex;

/* the buffer for the characters to be received */
uint8_t incoming[10];
uint8_t expectedNumberOfIncoming;
uint8_t incomingIndex;

void ReadFromAddress(uint8_t peripheral, uint8_t periperalRegister, uint8_t numberOfBytesToRead);

void WaitUntilBusIsFree();

void ResetI2C();

void InitialiseI2C();

void SendStart();

void SendAddress(uint8_t address, uint8_t direction);

void SendData(uint8_t data);

void SendStop();

uint8_t ReadDataExpectingMore();

uint8_t ReadDataExpectingEnd();

#endif
