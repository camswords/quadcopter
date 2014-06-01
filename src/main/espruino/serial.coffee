define 'espruino/serial', ['configuration'], (config) ->

  config.overrides.serial.setup config.serial.baudRate,
                                rx: config.serial.rx,
                                tx: config.serial.tx

  write: (message) -> config.overrides.serial.write(message)
