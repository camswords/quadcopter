#include <pwm.h>
#include <stm32f4xx_gpio.h>

void InitialisePWM()
{
	/* set all of the pulse values to 0% */
	channel1Pulse = 1000;
	channel2Pulse = 1000;
	channel3Pulse = 1000;
	channel4Pulse = 1000;

    // we need to enable the peripheral ports / pins
    // enabling them more than once seems to have no measurable effect
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOA, ENABLE);
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOB, ENABLE);

    // according to the MCU clock configuration the
    // timers have a clock speed of 84MHz
    // see http://myembeddedtutorial.blogspot.com.au/2013/06/working-with-stm32f4-timers.html

    RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM3, ENABLE);

    TIM_TimeBaseInitTypeDef timerInitStructure;

    // -1 is used because it will count from 0, therefore we
    // count up until 83 to avoid the off by one error

    // 1000ms / 50Hz = an update every 20ms
    // Note that as the TIM_Prescaler is only 16bit it can only count to 65535

    // We will use 84000000 / 84 = 1000000 so that every second it will count 1000000 ticks
    // this means every 20ms will represent 20000 ticks
    // 2000 will represent high throttle (2ms high voltage)
    // 1000 will represent low throttle (1ms high voltage)
    // the throttle range of 1000 should be enough for precise control
    timerInitStructure.TIM_Prescaler = 84 - 1;
    timerInitStructure.TIM_CounterMode = TIM_CounterMode_Up;
    timerInitStructure.TIM_Period = 20000 - 1;
    timerInitStructure.TIM_ClockDivision = TIM_CKD_DIV1;
    timerInitStructure.TIM_RepetitionCounter = 0;
    TIM_TimeBaseInit(TIM3, &timerInitStructure);
    TIM_Cmd(TIM3, ENABLE);
}

void SetTim3Channel1(float pulse) {
	if (pulse >= 1000 && pulse <= 2000) {
		channel1Pulse = pulse;
	    TIM3->CCR1 = (uint32_t) pulse;
	}
}

void SetTim3Channel2(float pulse) {
	if (pulse >= 1000 && pulse <= 2000) {
		channel2Pulse = pulse;
	    TIM3->CCR2 = (uint32_t) pulse;
	}
}

void SetTim3Channel3(float pulse) {
	if (pulse >= 1000 && pulse <= 2000) {
		channel3Pulse = pulse;
		TIM3->CCR3 = (uint32_t) pulse;
	}
}

void SetTim3Channel4(float pulse) {
	if (pulse >= 1000 && pulse <= 2000) {
		channel4Pulse = pulse;
		TIM3->CCR4 = (uint32_t) pulse;
	}
}

void UpdateTim3Channel1(float pulse) {
	SetTim3Channel1(channel1Pulse + pulse);
}

void UpdateTim3Channel2(float pulse) {
	SetTim3Channel2(channel2Pulse + pulse);
}

void UpdateTim3Channel3(float pulse) {
	SetTim3Channel3(channel3Pulse + pulse);
}

void UpdateTim3Channel4(float pulse) {
	SetTim3Channel4(channel4Pulse + pulse);
}

float ReadTim3Channel1Pulse() {
	return channel1Pulse;
}

float ReadTim3Channel2Pulse() {
	return channel2Pulse;
}

float ReadTim3Channel3Pulse() {
	return channel3Pulse;
}

float ReadTim3Channel4Pulse() {
	return channel4Pulse;
}

DutyCycle InitialisePWMChannel(GPIO_TypeDef* GPIOx, uint16_t pin, uint8_t pinSource, uint8_t channel)
{
    GPIO_InitTypeDef gpioStructure;
    gpioStructure.GPIO_Pin = pin;
    gpioStructure.GPIO_Mode = GPIO_Mode_AF;
    gpioStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOx, &gpioStructure);

    TIM_OCInitTypeDef outputChannelInit = {0,};
    outputChannelInit.TIM_OCMode = TIM_OCMode_PWM1;

    // initial throttle is 0% (1000)
    outputChannelInit.TIM_Pulse = 1000;
    outputChannelInit.TIM_OutputState = TIM_OutputState_Enable;
    outputChannelInit.TIM_OCPolarity = TIM_OCPolarity_High;

    struct DutyCycle dutyCycle;

    if (channel == 1) {
    	dutyCycle.set = &SetTim3Channel1;
        dutyCycle.update = &UpdateTim3Channel1;
        dutyCycle.get = &ReadTim3Channel1Pulse;

        TIM_OC1Init(TIM3, &outputChannelInit);
        TIM_OC1PreloadConfig(TIM3, TIM_OCPreload_Enable);
    } else if (channel == 2) {
    	dutyCycle.set = &SetTim3Channel2;
        dutyCycle.update = &UpdateTim3Channel2;
        dutyCycle.get = &ReadTim3Channel2Pulse;

        TIM_OC2Init(TIM3, &outputChannelInit);
        TIM_OC2PreloadConfig(TIM3, TIM_OCPreload_Enable);
    } else if (channel == 3) {
    	dutyCycle.set = &SetTim3Channel3;
        dutyCycle.update = &UpdateTim3Channel3;
        dutyCycle.get = &ReadTim3Channel3Pulse;

        TIM_OC3Init(TIM3, &outputChannelInit);
        TIM_OC3PreloadConfig(TIM3, TIM_OCPreload_Enable);
    } else if (channel == 4) {
    	dutyCycle.set = &SetTim3Channel4;
        dutyCycle.update = &UpdateTim3Channel4;
        dutyCycle.get = &ReadTim3Channel4Pulse;

        TIM_OC4Init(TIM3, &outputChannelInit);
        TIM_OC4PreloadConfig(TIM3, TIM_OCPreload_Enable);
    }

    GPIO_PinAFConfig(GPIOx, pinSource, GPIO_AF_TIM3);

    // note that this will be copied - probably better off using a reference.
    return dutyCycle;
}
