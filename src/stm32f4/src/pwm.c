#include <pwm.h>
#include <stm32f4xx_gpio.h>

void InitialisePWM()
{
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


void InitialisePWMChannel(GPIO_TypeDef* GPIOx, uint16_t pin, uint8_t pinSource, uint8_t channel)
{
    GPIO_InitTypeDef gpioStructure;
    gpioStructure.GPIO_Pin = pin;
    gpioStructure.GPIO_Mode = GPIO_Mode_AF;
    gpioStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOx, &gpioStructure);

    TIM_OCInitTypeDef outputChannelInit = {0,};
    outputChannelInit.TIM_OCMode = TIM_OCMode_PWM1;

    // high throttle
    outputChannelInit.TIM_Pulse = 2000;
    outputChannelInit.TIM_OutputState = TIM_OutputState_Enable;
    outputChannelInit.TIM_OCPolarity = TIM_OCPolarity_High;

    if (channel == 1) {
        TIM_OC1Init(TIM3, &outputChannelInit);
        TIM_OC1PreloadConfig(TIM3, TIM_OCPreload_Enable);
    } else if (channel == 2) {
        TIM_OC2Init(TIM3, &outputChannelInit);
        TIM_OC2PreloadConfig(TIM3, TIM_OCPreload_Enable);
    } else if (channel == 3) {
        TIM_OC3Init(TIM3, &outputChannelInit);
        TIM_OC3PreloadConfig(TIM3, TIM_OCPreload_Enable);
    } else if (channel == 4) {
        TIM_OC4Init(TIM3, &outputChannelInit);
        TIM_OC4PreloadConfig(TIM3, TIM_OCPreload_Enable);
    }


    GPIO_PinAFConfig(GPIOx, pinSource, GPIO_AF_TIM3);
}
