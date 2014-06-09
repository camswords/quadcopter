define 'utility/scheduler-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it "scheduler should execute function every specified interval", (test) ->
    specHelper.require 'utility/scheduler', (scheduler) ->
      timesCalled = 0
      startTime = getTime()

      scheduler.every(100).execute 'foo', ->
        timesCalled++
        if timesCalled == 5
          scheduler.stopAll()

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

  it "scheduler should stop all scheduled interval jobs", (test) ->
    specHelper.require 'utility/scheduler', (scheduler) ->
      timesCalled = 0

      waitABit = ->
        test.expect(timesCalled).toBe(1)
        test.done()

      scheduler.every(50).execute 'another.scheduled.job', ->
        timesCalled++

        scheduler.stopAll()
        setTimeout(waitABit, 300)

  it "scheduler should stop all scheduled timeout jobs", (test) ->
    specHelper.require 'utility/scheduler', (scheduler) ->
      timesCalled = 0

      finishTest = ->
        test.expect(timesCalled).toBe(0)
        test.done()

      scheduler.after(150).execute -> timesCalled++

      scheduler.stopAll()
      setTimeout(finishTest, 300)
