

-- note that there is a bug in the stm32f4 platform elua code. It only seems to use the pin, not the port.
-- this means that we can only have interrupts on port 0 (A).
-- but... why is the interrupt being called twice? Seems strange.
pio.pin.setdir(pio.INPUT, pio.PA_03)

-- this fires an interrupt for PA_03. What?
pio.pin.setpull(pio.PULLDOWN)

local function gpio_positive_handler(resnum)
    local port, pin = pio.decode(resnum)
    print( string.format( "GPIO positive edge interrupt on port %d, pin %d", port, pin ) )
end

local porty, piny = pio.decode(pio.PA_03)
print( string.format( "Setting interrupt on port %d, pin %d", porty, piny) )

-- compare to espruino

cpu.set_int_handler(cpu.INT_GPIO_POSEDGE, gpio_positive_handler)
cpu.sei(cpu.INT_GPIO_POSEDGE, pio.PA_03)

while true do
  print("looping...")
  tmr.delay(tmr.SYS_TIMER, 1000000)
end
