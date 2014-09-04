
#ifndef I2C_H
#define I2C_H

#include <stdint.h>
#include <stm32f4xx_i2c.h>

void InitialiseI2C();

void SendStart();

void SendAddress(uint8_t address, uint8_t direction);

void SendData(uint8_t data);

void SendStop();

uint8_t ReadDataExpectingMore();

uint8_t ReadDataExpectingEnd();

#endif
