define 'scheduler-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it "scheduler should function every specified interval", (test) ->
    specHelper.require 'scheduler', (scheduler) ->
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
