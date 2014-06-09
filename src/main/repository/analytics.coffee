define 'repository/analytics', [
       'repository/throttle', 'repository/loop-frequency'], (
       throttle, loops) ->
  headers: -> 'loops,throttle'
  get: -> "#{loops.count()},#{throttle.get()}"
