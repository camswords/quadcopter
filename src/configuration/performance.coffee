define 'configuration', ->
  overrides:
    digitalPulse: (->)
    setWatch: (->)
  throttle:
    inputPin: 1
  propeller:
    frontLeft:
      outputPin: 2
    frontRight:
      outputPin: 3
    backLeft:
      outputPin: 4
    backRight:
      outputPin: 5
