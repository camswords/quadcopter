define 'throttle-repository-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it "throttle repository should retrieve saved throttle", (test) ->
    specHelper.require 'throttleRepository', (throttleRepository) ->
      throttleRepository.save(1234)
      test.expect(throttleRepository.get()).toBe(1234)
      test.done()

  it "throttle repository should have zero throttle when it has never been set", (test) ->
    specHelper.require 'throttleRepository', (throttleRepository) ->
      test.expect(throttleRepository.get()).toBe(0)
      test.done()
