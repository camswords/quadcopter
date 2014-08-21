#include <pwm_input.h>
#include <stm32f4xx_gpio.h>

void CapturePWMInput() {
    /* Initialise duty cycle and freq to zero, surely there is a better place to do this? */
    pwmInput.dutyCycle = 0;
    pwmInput.frequency = 0;


    /* TIM4 clock enable */
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM4, ENABLE);

    /* GPIOB clock enable */
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOB, ENABLE);

    /* TIM4 chennel2 configuration : PB.07 */
    GPIO_InitTypeDef GPIO_InitStructure;
    GPIO_InitStructure.GPIO_Pin   = GPIO_Pin_7;
    GPIO_InitStructure.GPIO_Mode  = GPIO_Mode_AF;
    GPIO_InitStructure.GPIO_Speed = GPIO_Speed_100MHz;
    GPIO_InitStructure.GPIO_OType = GPIO_OType_PP;
    GPIO_InitStructure.GPIO_PuPd  = GPIO_PuPd_UP ;
    GPIO_Init(GPIOB, &GPIO_InitStructure);

    /* Connect TIM pin to AF2 */
    GPIO_PinAFConfig(GPIOB, GPIO_PinSource7, GPIO_AF_TIM4);

    /* Enable the TIM4 global Interrupt */
    NVIC_InitTypeDef NVIC_InitStructure;
    NVIC_InitStructure.NVIC_IRQChannel = TIM4_IRQn;
    NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;
    NVIC_InitStructure.NVIC_IRQChannelSubPriority = 1;
    NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
    NVIC_Init(&NVIC_InitStructure);

    TIM_ICInitTypeDef TIM_ICInitStructure;
    TIM_ICInitStructure.TIM_Channel = TIM_Channel_2;
    TIM_ICInitStructure.TIM_ICPolarity = TIM_ICPolarity_Rising;
    TIM_ICInitStructure.TIM_ICSelection = TIM_ICSelection_DirectTI;
    TIM_ICInitStructure.TIM_ICPrescaler = TIM_ICPSC_DIV1;
    TIM_ICInitStructure.TIM_ICFilter = 0x0;

    TIM_PWMIConfig(TIM4, &TIM_ICInitStructure);

    /* Select the TIM4 Input Trigger: TI2FP2 */
    /* I believe this sets the slave up to trigger on the falling edge */
    TIM_SelectInputTrigger(TIM4, TIM_TS_TI2FP2);

    /* Select the slave Mode: Reset Mode */
    TIM_SelectSlaveMode(TIM4, TIM_SlaveMode_Reset);
    TIM_SelectMasterSlaveMode(TIM4, TIM_MasterSlaveMode_Enable);

    /* TIM enable counter */
    TIM_Cmd(TIM4, ENABLE);

    /* Enable the CC2 Interrupt Request */
     TIM_ITConfig(TIM4, TIM_IT_CC2, ENABLE);
}

void TIM4_IRQHandler(void) {
    RCC_ClocksTypeDef RCC_Clocks;
    RCC_GetClocksFreq(&RCC_Clocks);

    /* Clear TIM4 Capture compare interrupt pending bit */
    TIM_ClearITPendingBit(TIM4, TIM_IT_CC2);

    /* Get the Input Capture value */
    uint16_t IC2Value = TIM_GetCapture2(TIM4);

    /* When is this zero?
       On first capture?
       At the start of every period? */
    if (IC2Value != 0) {
        /* I thought IC1 would have the period, not IC2. Hmm. */

        /* Duty cycle computation */
        pwmInput.dutyCycle = (TIM_GetCapture1(TIM4) * 100) / IC2Value;

        /* Frequency computation
           TIM4 counter clock = (RCC_Clocks.HCLK_Frequency)/2 */

        /* HCLK is the Advanced High Speed Bus (AHB) Clock Speed, which is a
           factor of the System Clock (one, at the moment, hence is the same) */

        pwmInput.frequency = (RCC_Clocks.HCLK_Frequency) / 2 / IC2Value;
    }
    else {
        pwmInput.dutyCycle = 0;
        pwmInput.frequency = 0;
    }
}
