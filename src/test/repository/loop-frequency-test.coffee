
define 'repository/loop-frequency-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it 'loop frequency repository should save number of loops per second', (test) ->

    specHelper.require 'repository/loop-frequency', (loops) ->
      loops.increment()
      loops.increment()
      loops.increment()
      loops.increment()

      test.expect(loops.count()).toBe(4)
      test.done()

  it 'loop frequency repository should reset loop count', (test) ->

    specHelper.require 'repository/loop-frequency', (loops) ->
      loops.increment()
      loops.increment()
      loops.reset()
      loops.increment()

      test.expect(loops.count()).toBe(1)
      test.done()
