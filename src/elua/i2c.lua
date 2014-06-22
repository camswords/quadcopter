
local sda = pio.PA_02
local scl = pio.PA_03

local function waitABit()
  local count = 0

  while (true) do
    count = count + 1

    if count > 10 then
      break;
    end
  end
end

local function tickLow()
  waitABit()
  pio.pin.setlow(scl)
end

local function tickHigh()
  waitABit()
  pio.pin.sethigh(scl)
end

local function send0()
  tickLow()
  pio.pin.setlow(sda)
  tickHigh()
end

local function send1()
  tickLow()
  pio.pin.sethigh(sda)
  tickHigh()
end

-- initially both lines should be high
print("setting both lines to high")
pio.pin.setdir(pio.OUTPUT, sda, scl)
pio.pin.sethigh(sda, scl)
waitABit()
waitABit()

-- start by setting the SDA to low with SCL high
print("starting i2c")
pio.pin.setlow(sda)
waitABit()


-- send address: 1101000 + WriteBit
print("sending 1101000")
send1()
send1()
send0()
send1()
send0()
send0()
send0()
send0()

print("waiting for acknowledgement :)")
tickLow()
pio.pin.setdir(pio.INPUT, sda)
pio.pin.setpull(pio.PULLUP, sda)
tickHigh()

local acknowledged = pio.pin.getval(sda)
print("acknowledged is", acknowledged)



