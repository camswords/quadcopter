#include <pwm_input.h>
#include <stm32f4xx_gpio.h>

RCC_ClocksTypeDef RCC_Clocks;

void MeasurePwmInput() {
	pwmInput.dutyCycle = 0.0f;
	pwmInput.frequency = 0;

	/* Work out the system / bus / timer clock speed */
    RCC_GetClocksFreq(&RCC_Clocks);

    /* Enable the clock to GPIOB */
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOB, ENABLE);

    /* Turn on PB06, it will be connected to Timer 4, Channel 1.
     * Timer Channel 2 will also be used, I believe this renders pin PB7 unusable.
     */
    GPIO_InitTypeDef GPIO_InitStructure;
    GPIO_InitStructure.GPIO_Pin   = GPIO_Pin_6;
    GPIO_InitStructure.GPIO_Mode  = GPIO_Mode_AF;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
    GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
    GPIO_InitStructure.GPIO_PuPd  = GPIO_PuPd_UP ;
    GPIO_Init(GPIOB, &GPIO_InitStructure);

    /* Connect TIM pin to AF2 */
    GPIO_PinAFConfig(GPIOB, GPIO_PinSource6, GPIO_AF_TIM4);

    /* Enable the timer clock */
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM4, ENABLE);

    /* init the timer:
     * We expect 1,680,000 ticks every 20ms
     * 1680 prescalar will ensure that there are 1000 ticks per 20ms
     * The maximum (16bit) period should never be reached, as we will reset the counter before we get there.
     */
	TIM_TimeBaseInitTypeDef timerInitStructure;
	timerInitStructure.TIM_Prescaler = 1000;
	timerInitStructure.TIM_CounterMode = TIM_CounterMode_Up;
	timerInitStructure.TIM_Period = 65535;
	timerInitStructure.TIM_ClockDivision = TIM_CKD_DIV1;
	timerInitStructure.TIM_RepetitionCounter = 0;
	TIM_TimeBaseInit(TIM4, &timerInitStructure);

	/* Enable the Timer counter */
	TIM_Cmd(TIM4, ENABLE);

	/* We're attempting to not have a prescalar, that is, not divide the incoming signal.
	 * I wonder this prescalar differs from the above prescalar.
	 * Channel 1 is configured to capture on the rising edge.
	 * */
	TIM_ICInitTypeDef TIM_ICInitStructure1;
	TIM_ICInitStructure1.TIM_Channel = TIM_Channel_1;
	TIM_ICInitStructure1.TIM_ICPolarity = TIM_ICPolarity_Rising;
	TIM_ICInitStructure1.TIM_ICSelection = TIM_ICSelection_DirectTI;
	TIM_ICInitStructure1.TIM_ICPrescaler = 0;
	TIM_ICInitStructure1.TIM_ICFilter = 0;
	TIM_ICInit(TIM4, &TIM_ICInitStructure1);

	/*
	 * Channel 2 is configured to capture on the falling edge.
	 * */
	TIM_ICInitTypeDef TIM_ICInitStructure2;
	TIM_ICInitStructure2.TIM_Channel = TIM_Channel_2;
	TIM_ICInitStructure2.TIM_ICPolarity = TIM_ICPolarity_Falling;
	TIM_ICInitStructure2.TIM_ICSelection = TIM_ICSelection_IndirectTI;
	TIM_ICInitStructure2.TIM_ICPrescaler = 0;
	TIM_ICInitStructure2.TIM_ICFilter = 0;
	TIM_ICInit(TIM4, &TIM_ICInitStructure2);

	/* Ensure that Channel two is set up as a slave, and that it resets the counters on a falling edge */
	TIM_SelectInputTrigger(TIM4, TIM_TS_TI1FP1);
	TIM_SelectSlaveMode(TIM4, TIM_SlaveMode_Reset);
	TIM_SelectMasterSlaveMode(TIM4, TIM_MasterSlaveMode_Enable);

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
    	/* ensure that the timer doesn't get triggered again */
        TIM_ClearITPendingBit(TIM4, TIM_IT_Update);

        uint32_t IC1Value = TIM_GetCapture1(TIM4);
    	uint32_t IC2Value = TIM_GetCapture2(TIM4);

    	/* As a percentage */
    	pwmInput.dutyCycle = (IC2Value * 100.0f) / IC1Value;

    	/* HCLK is the Advanced High Speed Bus (AHB) Clock Speed, which is a
           factor of the System Clock (one, at the moment, hence is the same) */
        pwmInput.frequency = (RCC_Clocks.HCLK_Frequency) / 2.0f / (IC1Value * 1000);
    }
}
