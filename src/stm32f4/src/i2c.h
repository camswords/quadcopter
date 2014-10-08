
#ifndef I2C_H
#define I2C_H

#include <stdint.h>
#include <stdbool.h>
#include <stm32f4xx_i2c.h>

bool i2cHasProblem;

void WaitUntilBusIsFree();

void InitialiseI2C();

void SendStart();

void SendAddress(uint8_t address, uint8_t direction);

void SendData(uint8_t data);

void SendStop();

uint8_t ReadDataExpectingMore();

uint8_t ReadDataExpectingEnd();

#endif
