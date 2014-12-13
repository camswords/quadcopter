//******************************************************************************

// https://my.st.com/public/STe2ecommunities/mcu/Lists/cortex_mx_stm32/Flat.aspx?RootFolder=https://my.st.com/public/STe2ecommunities/mcu/Lists/cortex_mx_stm32/compensating%20latencies%20on%20STM32F4%20interrupts&FolderCTID=0x01200200770978C69A1141439FE559EB459D7580009C4E14902C3CDE46A77F0FFD06506F5B&currentviews=2116

volatile unsigned int *DWT_CYCCNT   = (volatile unsigned int *)0xE0001004; //address of the register
volatile unsigned int *DWT_CONTROL  = (volatile unsigned int *)0xE0001000; //address of the register
volatile unsigned int *SCB_DEMCR        = (volatile unsigned int *)0xE000EDFC; //address of the register

//******************************************************************************

#include <delay.h>

void EnableTiming(void)
{
    static int enabled = 0;

    if (!enabled)
    {
        *SCB_DEMCR = *SCB_DEMCR | 0x01000000;
        *DWT_CYCCNT = 0; // reset the counter
        *DWT_CONTROL = *DWT_CONTROL | 1 ; // enable the counter

        enabled = 1;
    }
}

//******************************************************************************

void TimingDelay(unsigned int tick)
{
    unsigned int start, current;

    start = *DWT_CYCCNT;

    do
    {
        current = *DWT_CYCCNT;
    } while((current - start) < tick);
}

//******************************************************************************

void WaitASecond() {
	TimingDelay(160000000);
}

void WaitAMillisecond() {
	TimingDelay(160000);
}

void WaitAFewMillis(int16_t millis) {
	TimingDelay(160000000 / 1000 * millis);
}
