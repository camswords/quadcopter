define 'intensity', ->
  (intensity) ->
    if isNaN(intensity) || intensity < 0
      return 0

    if intensity > 100
      return 100

    intensity
