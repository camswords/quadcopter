define 'foo', -> { value: '123456789' }

define 'bob', ['foo'], (foo) -> { value: 'bob:' + foo.value }

define 'overriding-modules-test', ['spec-helper', 'mini-test'], (specHelper, miniTest) ->
  miniTest.it 'should use real when not stubbed', (test) ->
    specHelper.require 'bob', {}, (bob) ->
      test.expect(bob.value).toBe('bob:123456789');
      test.done()

  miniTest.it 'should override when stubbed', (test) ->
    specHelper.require 'bob', { 'foo': { value: '987654321' } }, (bob) ->
      test.expect(bob.value).toBe('bob:987654321');
      test.done()

  miniTest.it 'should use real when not stubbed the second time', (test) ->
    specHelper.require 'bob', {}, (bob) ->
      test.expect(bob.value).toBe('bob:123456789');
      test.done()
