define 'foo', -> { value: '123456789' }
define 'bob', ['foo'], (foo) -> { value: 'bob:' + foo.value }

define 'almond-modifications-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->
  it 'amd should use real modules when not stubbed', (test) ->
    specHelper.require 'bob', {}, (bob) ->
      test.expect(bob.value).toBe('bob:123456789');
      test.done()

  it 'amd should override modules when stubbed', (test) ->
    specHelper.require 'bob', { 'foo': { value: '987654321' } }, (bob) ->
      test.expect(bob.value).toBe('bob:987654321');
      test.done()

  it 'amd should use real modules again when stubbing has ceased', (test) ->
    specHelper.require 'bob', {}, (bob) ->
      test.expect(bob.value).toBe('bob:123456789');
      test.done()
