
define 'utility/is-number', ->
  (value) -> typeof(value) == 'number' && !isNaN(value)
