
define 'performance-test', ['utility/scheduler', 'quadcopter'], (scheduler, quadcopter) ->
  scheduler.after(1000).execute ->
    console.log '   blocks', '  module name'

    for moduleName in Object.keys(memoryUsage)
        console.log '    ', memoryUsage[moduleName], '    ', moduleName

    console.log 'running memory:', process.memory().usage
    quadcopter.kill()
