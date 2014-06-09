define 'repository/throttle-output-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it "throttle output repository should retrieve saved throttle", (test) ->
    specHelper.require 'repository/throttle-output', (throttleOutput) ->
      throttleOutput.save(1234)
      test.expect(throttleOutput.get()).toBe(1234)
      test.done()

  it "throttle output repository should have zero throttle when it has never been set", (test) ->
    specHelper.require 'repository/throttle-output', (throttleOutput) ->
      test.expect(throttleOutput.get()).toBe(0)
      test.done()
