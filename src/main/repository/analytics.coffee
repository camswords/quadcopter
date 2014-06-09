define 'repository/analytics', [
       'repository/throttle', 'repository/loop-frequency'], (
       throttle, loops) ->
  get: -> "#{loops.get()},#{throttle.get()}"
