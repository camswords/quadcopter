#include <stm32f4xx.h>
#include <stm32f4xx_gpio.h>
#include <delay.h>

void InitialiseLEDs()
{
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);

    GPIO_InitTypeDef gpioStructure;
    gpioStructure.GPIO_Pin = GPIO_Pin_13 | GPIO_Pin_14 | GPIO_Pin_15;
    gpioStructure.GPIO_Mode = GPIO_Mode_OUT;
    gpioStructure.GPIO_Speed = GPIO_Speed_100MHz;
    gpioStructure.GPIO_OType = GPIO_OType_PP;
    gpioStructure.GPIO_PuPd = GPIO_PuPd_NOPULL;
    GPIO_Init(GPIOD, &gpioStructure);
}

void InitialiseTimer()
{
    // according to the MCU clock configuration the
    // timers have a clock speed of 84MHz
    // see http://myembeddedtutorial.blogspot.com.au/2013/06/working-with-stm32f4-timers.html

    RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM4, ENABLE);

    TIM_TimeBaseInitTypeDef timerInitStructure;

    // -1 is used because it will count from 0, therefore we
    // count up until 41999 to avoid the off by one error

    // 1000ms / 50Hz = an update every 20ms
    // Unfortunately, we can't use 84000000 / 84000 = 1000 so that every second it will count 1000 ticks
    // This is because the TIM_Prescaler is only 16bit, therefore can only count to 65535

    // instead, we will use the 84000000 / 42000 = 2000 so that every second it will count 2000 ticks
    // we will have to double the TIM_Period and the TIM_Pulse
    timerInitStructure.TIM_Prescaler = 42000 - 1;
    timerInitStructure.TIM_CounterMode = TIM_CounterMode_Up;
    timerInitStructure.TIM_Period = 40 - 1;
    timerInitStructure.TIM_ClockDivision = TIM_CKD_DIV1;
    timerInitStructure.TIM_RepetitionCounter = 0;
    TIM_TimeBaseInit(TIM4, &timerInitStructure);
    TIM_Cmd(TIM4, ENABLE);
}

void InitialisePWMChannel()
{
    GPIO_InitTypeDef gpioStructure;
    gpioStructure.GPIO_Pin = GPIO_Pin_12;
    gpioStructure.GPIO_Mode = GPIO_Mode_AF;
    gpioStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOD, &gpioStructure);

    TIM_OCInitTypeDef outputChannelInit = {0,};
    outputChannelInit.TIM_OCMode = TIM_OCMode_PWM1;

    // low throttle
    outputChannelInit.TIM_Pulse = 2;
    outputChannelInit.TIM_OutputState = TIM_OutputState_Enable;
    outputChannelInit.TIM_OCPolarity = TIM_OCPolarity_High;

    TIM_OC1Init(TIM4, &outputChannelInit);
    TIM_OC1PreloadConfig(TIM4, TIM_OCPreload_Enable);

    GPIO_PinAFConfig(GPIOD, GPIO_PinSource12, GPIO_AF_TIM4);
}


int main(void) {
  InitialiseLEDs();
  InitialiseTimer();
  InitialisePWMChannel();

  GPIOD->BSRRH = 0x0000;
  GPIOD->BSRRL = 0xE000;
}
