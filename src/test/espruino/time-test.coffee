
define 'espruino/time-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it 'time should return time since power on in seconds as an integer', (test) ->
    specHelper.require 'espruino/time', (time) ->
      seconds = time()
      test.expect(typeof(seconds)).toBe('number')
      test.expect(seconds).toBeGreaterThan(0)
      test.expect(seconds).toBe(parseInt(seconds))
      test.done()
