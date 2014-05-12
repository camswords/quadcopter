
require ['utility/scheduler', 'quadcopter'], (scheduler, quadcopter) ->
  scheduler.after(100).execute -> quadcopter.fly()
  scheduler.after(500).execute ->
    console.log "running memory:", process.memory().usage
    quadcopter.kill()
