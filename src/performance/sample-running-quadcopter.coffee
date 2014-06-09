


# override the analytics gateway so that we can receive them directly
define 'utility/analytics-gateway', ->
  metrics = []

  send: (message) -> metrics.push(message)
  retrieve: -> metrics

define 'performance-test', [
       'utility/scheduler', 'quadcopter', 'utility/analytics-gateway', 'repository/analytics'], (
       scheduler, quadcopter, analyticsGateway, analyticsRepository) ->
  scheduler.after 10000, ->
    console.log '-----------------MEMORY-------------------'
    console.log '   blocks', '  module name'

    for moduleName in Object.keys(memoryUsage)
        console.log '    ', memoryUsage[moduleName], '    ', moduleName

    console.log 'running memory:', process.memory().usage
    console.log '------------------------------------------'

    console.log()
    console.log '-----------------ANALYTICS--------------------'

    console.log analyticsRepository.headers()

    for metrics in analyticsGateway.retrieve()
      console.log metrics

    console.log '------------------------------------------'

    quadcopter.kill()
