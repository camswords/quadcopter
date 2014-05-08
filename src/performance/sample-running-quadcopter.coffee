
require ['utility/scheduler', 'quadcopter'], (scheduler, quadcopter) ->
  scheduler.every(10).execute 'sample-memory', ->
    console.log("memory:", process.memory())

  scheduler.after(1000).execute -> quadcopter.fly()
  scheduler.after(5000).execute -> quadcopter.kill()
