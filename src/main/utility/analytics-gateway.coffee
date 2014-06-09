define 'utility/analytics-gateway', ['espruino/serial'], (serial) ->
  send: (message) -> serial.write(message + '|')
