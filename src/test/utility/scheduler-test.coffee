define 'utility/scheduler-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it "scheduler should execute function every specified interval", (test) ->
    specHelper.require 'utility/scheduler', (scheduler) ->
      timesCalled = 0
      startTime = getTime()

      scheduledJob = scheduler.every(100).execute ->
        timesCalled++
        if timesCalled == 5
          scheduledJob.stop()

          timeTaken = getTime() - startTime
          test.expect(timeTaken).toBeLessThan(0.505)
          test.expect(timeTaken).toBeGreaterThan(0.499)
          test.done()

  it "scheduler should execute function after specified interval", (test) ->
    specHelper.require 'utility/scheduler', (scheduler) ->
      startTime = getTime()

      scheduler.after(200).execute ->
        timeTaken = getTime() - startTime
        test.expect(timeTaken).toBeLessThan(0.205)
        test.expect(timeTaken).toBeGreaterThan(0.199)
        test.done()
