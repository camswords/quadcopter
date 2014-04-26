
define 'utility/random-string-generator-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it 'random string generator should create a string of length 5', (test) ->
    specHelper.require 'utility/random-string-generator', (randomString) ->
      test.expect(typeof(randomString())).toBe('string')
      test.expect(randomString().length).toBe(5)
      test.done()

  it 'random string generator should create different strings each time', (test) ->
    specHelper.require 'utility/random-string-generator', (randomString) ->
      test.expect(randomString()).toNotBe(randomString())
      test.done()


