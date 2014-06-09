
define 'repository/loop-frequency', ->

  loops = 0

  increment: -> loops++
  count: -> loops
  reset: -> loops = 0
