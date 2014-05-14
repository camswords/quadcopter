
require ['utility/scheduler', 'quadcopter'], (scheduler, quadcopter) ->
  scheduler.after(100).execute -> quadcopter.fly()
  scheduler.after(500).execute ->
    for moduleName in Object.keys(amdModuleMemory)
      console.log 'module memory ', amdModuleMemory[moduleName], moduleName

    console.log 'running memory:', process.memory().usage
    quadcopter.kill()
