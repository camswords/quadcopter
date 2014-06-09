define 'repository/analytics', [
       'espruino/time', 'repository/loop-frequency', 'repository/throttle', 'repository/throttle-output'], (
       time, loops, throttleIn, throttleOut) ->
  headers: -> 'time,loops,throttle in,throttle out'
  get: -> "#{time()},#{loops.count()},#{throttleIn.get()},#{throttleOut.get()}"
