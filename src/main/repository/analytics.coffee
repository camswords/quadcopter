define 'repository/analytics', [
       'espruino/time', 'repository/loop-frequency', 'repository/throttle'], (
       time, loops, throttle) ->
  headers: -> 'time,loops,throttle'
  get: -> "#{time()},#{loops.count()},#{throttle.get()}"
