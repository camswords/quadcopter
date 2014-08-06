#include <stm32f4xx.h>
#include <stm32f4xx_gpio.h>

void Delay(__IO uint32_t nCount) {
  while(nCount--) {
  }
}

TIM_OCInitTypeDef outputChannelInit2 = {0,};

/* This funcion shows how to initialize 
 * the GPIO pins on GPIOD and how to configure
 * them as inputs and outputs 
 */
void init_leds(void){
  GPIO_InitTypeDef GPIO_InitStruct;

  RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOC, ENABLE);

  GPIO_InitStruct.GPIO_Pin = GPIO_Pin_13 | GPIO_Pin_12;
  GPIO_InitStruct.GPIO_Mode = GPIO_Mode_OUT;
  GPIO_InitStruct.GPIO_Speed = GPIO_Speed_100MHz;
  GPIO_InitStruct.GPIO_OType = GPIO_OType_PP;
  GPIO_InitStruct.GPIO_PuPd = GPIO_PuPd_NOPULL;
  GPIO_Init(GPIOC, &GPIO_InitStruct);
}

void InitializeTimer()
{
    RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM4, ENABLE);

    TIM_TimeBaseInitTypeDef timerInitStructure;
    timerInitStructure.TIM_Prescaler = 10;
    timerInitStructure.TIM_CounterMode = TIM_CounterMode_Up;
    timerInitStructure.TIM_Period = 500;
    timerInitStructure.TIM_ClockDivision = TIM_CKD_DIV1;
    timerInitStructure.TIM_RepetitionCounter = 0;
    TIM_TimeBaseInit(TIM4, &timerInitStructure);
    TIM_Cmd(TIM4, ENABLE);
}

void InitializePWMChannel()
{
    TIM_OCInitTypeDef outputChannelInit = {0,};
    outputChannelInit.TIM_OCMode = TIM_OCMode_PWM1;
    outputChannelInit.TIM_Pulse = 500;
    outputChannelInit.TIM_OutputState = TIM_OutputState_Enable;
    outputChannelInit.TIM_OCPolarity = TIM_OCPolarity_High;

    TIM_OC1Init(TIM4, &outputChannelInit);
    TIM_OC1PreloadConfig(TIM4, TIM_OCPreload_Enable);

    GPIO_PinAFConfig(GPIOD, GPIO_PinSource12, GPIO_AF_TIM4);
}

void InitializePWMChannel2()
{
    outputChannelInit2.TIM_OCMode = TIM_OCMode_PWM1;
    outputChannelInit2.TIM_Pulse = 10;
    outputChannelInit2.TIM_OutputState = TIM_OutputState_Enable;
    outputChannelInit2.TIM_OCPolarity = TIM_OCPolarity_High;

    TIM_OC2Init(TIM4, &outputChannelInit2);
    TIM_OC2PreloadConfig(TIM4, TIM_OCPreload_Enable);

    GPIO_PinAFConfig(GPIOD, GPIO_PinSource13, GPIO_AF_TIM4);
}

void InitializeLEDs()
{
    RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOD, ENABLE);

    GPIO_InitTypeDef gpioStructure;
    gpioStructure.GPIO_Pin = GPIO_Pin_12 | GPIO_Pin_13;
    gpioStructure.GPIO_Mode = GPIO_Mode_AF;
    gpioStructure.GPIO_Speed = GPIO_Speed_50MHz;
    GPIO_Init(GPIOD, &gpioStructure);
}

void init_interrupt(void) {
  EXTI_InitTypeDef EXTI_InitStruct;
  GPIO_InitTypeDef GPIO_InitStruct;
  NVIC_InitTypeDef NVIC_InitStruct;

  RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOA, ENABLE);
  RCC_APB2PeriphClockCmd(RCC_APB2Periph_SYSCFG, ENABLE);

  GPIO_InitStruct.GPIO_Mode = GPIO_Mode_IN;
  GPIO_InitStruct.GPIO_PuPd = GPIO_PuPd_NOPULL;
  GPIO_InitStruct.GPIO_Pin = GPIO_Pin_0;
  GPIO_Init(GPIOA, &GPIO_InitStruct);

  SYSCFG_EXTILineConfig(EXTI_PortSourceGPIOA, EXTI_PinSource0);

  EXTI_InitStruct.EXTI_Line = EXTI_Line0;
  EXTI_InitStruct.EXTI_Mode = EXTI_Mode_Interrupt;
  EXTI_InitStruct.EXTI_Trigger = EXTI_Trigger_Rising;  
  EXTI_InitStruct.EXTI_LineCmd = ENABLE;
  EXTI_Init(&EXTI_InitStruct);

  NVIC_InitStruct.NVIC_IRQChannel = EXTI0_IRQn;
  NVIC_InitStruct.NVIC_IRQChannelPreemptionPriority = 0x0F;
  NVIC_InitStruct.NVIC_IRQChannelSubPriority = 0x0F;
  NVIC_InitStruct.NVIC_IRQChannelCmd = ENABLE;
  NVIC_Init(&NVIC_InitStruct);
}

uint8_t pins = 0x1;

void EXTI0_IRQHandler(void) {
  if(EXTI_GetITStatus(EXTI_Line0) != RESET) {
    // toggle++;
    //GPIOD->BSRRL = 0xF000;

    GPIOD->BSRRH = pins << 12;

    uint8_t shifted = pins << 1;
    pins = (shifted & 0xf) | (shifted >> 4);

    GPIOD->BSRRL = pins << 12;


    EXTI_ClearITPendingBit(EXTI_Line0);
  }
}

int main(void) {
  init_leds();
  init_interrupt();

  // InitializeLEDs();
  // InitializeTimer();
  // InitializePWMChannel();
  // InitializePWMChannel2();

  GPIOC->BSRRL = 0x1000; 
  Delay(3000000L);

  uint8_t mypin = 0x1;

  while (1) {  
    // TIM4->CCR2 = (TIM4->CCR2 + 100) % 500;  
    // } else {
      //GPIOD->BSRRH = pins << 12;
      //0xF000;
    // }

    if (mypin == 0x1) {
      mypin = 0x2;
    } else if (mypin == 0x2) {
      mypin = 0x3;
    } else {
      mypin = 0x1;
    }

    GPIOC->BSRRH = (mypin ^ 0xF) << 12;
    GPIOC->BSRRL = mypin << 12;

    Delay(3000000L);
  }
}
