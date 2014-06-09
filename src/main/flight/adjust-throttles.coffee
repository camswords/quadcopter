
define 'flight/adjust-throttles', [
       'flight/propeller', 'configuration', 'repository/loop-frequency'], (
       propeller, config, loops) ->

  frontLeft = propeller.create(config.propeller.frontLeft.outputPin)
  backRight = propeller.create(config.propeller.backRight.outputPin)
  frontRight = propeller.create(config.propeller.frontRight.outputPin)
  backLeft = propeller.create(config.propeller.backLeft.outputPin)

  (throttle) ->
    frontLeft.accelerateTo(throttle)
    backRight.accelerateTo(throttle)

    frontRight.accelerateTo(throttle)
    backLeft.accelerateTo(throttle)

    loops.increment()
