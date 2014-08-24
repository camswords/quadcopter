#include <pwm_input.h>
#include <stm32f4xx_gpio.h>

void BreakOnTimerCount() {
    /* Enable the timer clock */
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM4, ENABLE);

    /* init the timer:
     * "count" every 40000 clock cycles
     * count up until 500, then reset
     */
	TIM_TimeBaseInitTypeDef timerInitStructure;
	timerInitStructure.TIM_Prescaler = 40000;
	timerInitStructure.TIM_CounterMode = TIM_CounterMode_Up;
	timerInitStructure.TIM_Period = 500;
	timerInitStructure.TIM_ClockDivision = TIM_CKD_DIV1;
	timerInitStructure.TIM_RepetitionCounter = 0;
	TIM_TimeBaseInit(TIM4, &timerInitStructure);

	/* Enable the Timer counter */
	TIM_Cmd(TIM4, ENABLE);

	/* Enable the interrupt that gets fired when the timer counter hits the period */
	TIM_ITConfig(TIM4, TIM_IT_Update, ENABLE);

	/* Enable the Timer interrupts */
	NVIC_InitTypeDef nvicStructure;
	nvicStructure.NVIC_IRQChannel = TIM4_IRQn;
	nvicStructure.NVIC_IRQChannelPreemptionPriority = 0;
	nvicStructure.NVIC_IRQChannelSubPriority = 1;
	nvicStructure.NVIC_IRQChannelCmd = ENABLE;
	NVIC_Init(&nvicStructure);
}

/* Timer 4 interrupt handler */
void TIM4_IRQHandler()
{
	/* makes sure the interrupt status is not reset (and therefore SET?) */
    if (TIM_GetITStatus(TIM4, TIM_IT_Update) != RESET)
    {
    	uint32_t count = TIM_GetCounter(TIM4);
    	/* ensure that the timer doesn't get triggered again */
        TIM_ClearITPendingBit(TIM4, TIM_IT_Update);


    }
}

