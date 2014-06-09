define 'configuration', ->
  overrides:
    analogWrite: analogWrite
    setWatch: setWatch
    serial: Serial4
  throttle:
    inputPin: A8
    updateIntervalMs: 200
  propeller:
    pwmFrequency: 50
    frontLeft:
      outputPin: C6
    frontRight:
      outputPin: C7
    backLeft:
      outputPin: C8
    backRight:
      outputPin: C9
  serial:
    baudRate: 9600
    rx: C11
    tx: C10
  features:
    saveAnalyticsToFile: false
