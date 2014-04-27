
define 'repository/metrics-test', ['spec-helper', 'mini-test-it'], (specHelper, it) ->

  it 'metrics repository should save metrics to file', (test) ->
    written = null

    stubs = {
      'espruino/time': (-> 56),
      'espruino/file': (-> append: (data) -> written = data)
    }

    specHelper.require 'repository/metrics', stubs, (metricsRepository) ->
      metricsRepository.save('loop-frequency-hz', '401')

      test.expect(written).toBe('56|loop-frequency-hz|401\n')
      test.done()

  it 'metrics repository should write to new file each time', (test) ->
    metricsFile = null

    stubs = {
      'utility/random-string-generator': -> 'ABCDE'
      'espruino/file': (filename) ->
        metricsFile = filename
        return append: (->)
    }

    specHelper.require 'repository/metrics', stubs, (metricsRepository) ->
      metricsRepository.save('my-fancy-metric', 'true')

      test.expect(metricsFile).toBe('metrics-ABCDE.txt')
      test.done()
