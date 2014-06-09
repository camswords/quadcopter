define 'utility/analytics-gateway-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it 'analytics-gateway should send analytics to serial port', (test) ->
    lastMessage = 'no message written'

    stubs = 'espruino/serial':
      write: (message) -> lastMessage = message

    specHelper.require 'utility/analytics-gateway', stubs, (analyticsGateway) ->
      analyticsGateway.send('analytics.metrics')

      test.expect(lastMessage).toBe('analytics.metrics|')
      test.done()
