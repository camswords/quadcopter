
define 'performance-test', ['utility/scheduler', 'quadcopter', 'repository/metrics'], (scheduler, quadcopter, metrics) ->
  scheduler.after(10000).execute ->
    console.log '-----------------MEMORY-------------------'
    console.log '   blocks', '  module name'

    for moduleName in Object.keys(memoryUsage)
        console.log '    ', memoryUsage[moduleName], '    ', moduleName

    console.log 'running memory:', process.memory().usage
    console.log '------------------------------------------'

    console.log()
    console.log '-----------------SPEED--------------------'
    console.log metrics.get()
    console.log '------------------------------------------'

    quadcopter.kill()
