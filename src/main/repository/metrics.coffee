
define 'repository/metrics', [
       'espruino/time', 'espruino/file', 'utility/random-string-generator', 'configuration'], (
       time, file, randomString, configuration) ->
  metricsFile = "metrics-#{randomString()}.txt"

  save: (name, value) ->
    if configuration.features.saveAnalyticsToFile
      file(metricsFile).append "#{time()}|#{name}|#{value}\n"

  get: -> file(metricsFile).read()
