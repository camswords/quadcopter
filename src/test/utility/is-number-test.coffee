
define 'is-number-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it 'is-number should determine if input is a number', (test) ->
    specHelper.require 'utility/is-number', (isNumber) ->
      test.expect(isNumber(0)).toBeTruthy()
      test.expect(isNumber(-100)).toBeTruthy()
      test.expect(isNumber(100)).toBeTruthy()
      test.expect(isNumber(0.1)).toBeTruthy()
      test.expect(isNumber(-0)).toBeTruthy()
      test.expect(isNumber(-0.1)).toBeTruthy()
      test.expect(isNumber(3/3)).toBeTruthy()
      test.expect(isNumber(1/3)).toBeTruthy()
      test.expect(isNumber(undefined)).toBeFalsy()
      test.expect(isNumber(null)).toBeFalsy()
      test.expect(isNumber("1")).toBeFalsy()
      test.expect(isNumber(NaN)).toBeFalsy()
      test.done()
