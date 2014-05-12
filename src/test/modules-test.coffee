
outcome = (test, condition) ->
  if condition
    console.log "passed: #{test}"
  else
    console.log "failed: #{test}"

(->
  testName = 'modules should require a defined module'

  define 'foobar', [], -> name: 'foo'
  require ['foobar'], (foobar) ->
    outcome(testName, foobar.name == 'foo')
)()

(->
  testName = 'modules should require a defined module even if defined afterwards'

  require ['barfoo'], (barfoo) ->
    outcome(testName, barfoo.name == 'bar')

  define 'barfoo', [], -> name: 'bar'
)()

(->
  testName = 'modules should require more than one defined module'

  define 'b', [], -> value: 'b'

  require ['a', 'b'], (a, b) ->
    outcome(testName, a.value == 'a' && b.value == 'b')

  define 'a', [], -> value: 'a'
)()

(->
  testName = 'modules should require a module that has dependencies'

  define 'petrolTank', [], -> full: -> true
  define 'car', ['petrolTank'], (petrolTank) -> full: -> petrolTank.full()

  require ['car'], (car) -> outcome(testName, car.full() == true)
)()

(->
  testName = 'modules should return all defined module names'

  define 'first', [], -> value: 1
  define 'second', [], -> value: 2

  definedModules = define.all()
  outcome(testName, definedModules.indexOf('first') && definedModules.indexOf('second'))
)()

(->
  testName = 'modules should only execute factory function once'
  callback = 0

  define 'newmodule', [], -> callback++

  require ['newmodule'], ->
    require ['newmodule'], ->
      require ['newmodule'], ->
        outcome(testName, callback == 1)
)()

(->
  testName = 'modules should only allow defining a module once'

  define 'amodule', [], -> 1
  define 'amodule', [], -> 2

  require ['amodule'], (amodule) -> outcome(testName, amodule == 1)
)()

(->
  testName = 'modules should allow definitions without dependencies'

  define 'mymodule', -> 'foo'
  require ['mymodule'], (mymodule) -> outcome(testName, mymodule == 'foo')
)()

(->
  testName = 'modules should allow overriding of dependencies'

  define 'moduleToOverride', -> 'before'
  define.newContext()
  define.override 'moduleToOverride', 'after'
  require ['moduleToOverride'], (module) -> outcome(testName, module == 'after')
)()

(->
  testName = 'modules should allow overriding of overridden dependencies'

  define 'overrideLots', -> 'first'
  define.newContext()
  define.override 'overrideLots', 'second'
  define.newContext()
  define.override 'overrideLots', 'third'
  require ['overrideLots'], (module) -> outcome(testName, module == 'third')
)()

(->
  testName = 'modules should remove overridden dependency on new context'

  define 'pleaseResetThisModule', -> 'before'
  define.override 'pleaseResetThisModule', 'after'

  require ['pleaseResetThisModule'], ->
    define.newContext()

    require ['pleaseResetThisModule'], (module) ->
      outcome(testName, module == 'before')
)()

(->
  testName = 'modules can be overridden in define dependencies'

  define 'standsTall', -> 'tall'
  define 'leansOn', ['standsTall'], (tall) -> 'leans on ' + tall
  define.override 'standsTall', 'pretty high'

  require ['leansOn'], (leans) -> outcome(testName, leans == 'leans on pretty high')
)()

