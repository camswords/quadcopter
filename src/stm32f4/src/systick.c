#include <systick.h>
#include <stm32f4xx_gpio.h>
#include <stm32f4xx_it.h>

struct CallbackTrigger {
    callback event;
    uint32_t seconds;
    uint8_t triggered;
};

// do I need some kind of locking on this?
// it's possible for the main loop and an interrupt to attempt a change
// "at the same time"
struct CallbackTrigger callbacks[10];
uint8_t maximumCallbacks = sizeof(callbacks) / sizeof(struct CallbackTrigger);

// the default callback function
void doNothing(void) {}

// 32 bit: this should be enough for about 68 years of continuous operation.
// note that if for some reason interrupts interrupt each other, this value may
// be relatively inaccurate regarding seconds elapsed.
uint32_t secondsElapsed = 0;
uint16_t intermediateMillis = 0;


void InitialiseSysTick() {
  for(int i = 0; i < maximumCallbacks; i++) {
      struct CallbackTrigger thisCallback;
      thisCallback.event = &doNothing;
      thisCallback.seconds = 0;
      thisCallback.triggered = 1;
      callbacks[i] = thisCallback;
  }

  // init the system ticker to trigger an interrupt every millisecond
  // this will call the SysTick_Handler
  // note that milliseconds are only used because calling it every second (ideal) fails.
  // This is presumably due to the ideal number of ticks being too many to store in a register

  // Note: you could probably configure this to only interrupt for the "next" callback.
  // Would totally be way more efficient.
  if (SysTick_Config(SystemCoreClock / 1000)) {
    HardFault_Handler();
  }
}

void AddCallback(uint32_t seconds, callback event) {
    uint8_t added = 0;

    for(int i = 0; i < maximumCallbacks && !added; i++) {
        if (callbacks[i].triggered == 1) {
            added = 1;
            callbacks[i].event = event;
            callbacks[i].seconds = secondsElapsed + seconds;
            callbacks[i].triggered = 0;
        }
    }

    // unfortunately, callbacks that are unable to be added are silently ignored.
}

// note that the SysTick handler is already defined in startup_stm32f40xx.s
// It is defined with a weak reference, so that anyone other
// definition will be used over the default
void SysTick_Handler(void)
{
    intermediateMillis++;

    if (intermediateMillis == 1000) {
        intermediateMillis = 0;
        secondsElapsed++;

        for(int i = 0; i < maximumCallbacks; i++) {
            if (callbacks[i].triggered == 0 && callbacks[i].seconds == secondsElapsed) {
                callbacks[i].triggered = 1;
                (*(callbacks[i].event))();
            }
        }
    }
}
