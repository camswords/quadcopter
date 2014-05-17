
printOutcome = (test, condition) ->
  if condition
    console.log "passed: #{test}"
  else
    console.log "failed: #{test}"

tests = [
  ((done) ->
    testName = 'amd should require a defined module'

    define 'foobar', [], -> name: 'foo'
    require ['foobar'], (foobar) ->
      done(testName, foobar.name == 'foo')
  ),
  ((done) ->
    testName = 'amd should require a defined module even if defined afterwards'

    require ['barfoo'], (barfoo) ->
      done(testName, barfoo.name == 'bar')

    define 'barfoo', [], -> name: 'bar'
  ),
  ((done) ->
    testName = 'amd should require more than one defined module'

    define 'b', [], -> value: 'b'

    require ['a', 'b'], (a, b) ->
      done(testName, a.value == 'a' && b.value == 'b')

    define 'a', [], -> value: 'a'
  ),
  ((done) ->
    testName = 'amd should require a module that has dependencies'

    define 'petrolTank', [], -> full: -> true
    define 'car', ['petrolTank'], (petrolTank) -> full: -> petrolTank.full()

    require ['car'], (car) -> done(testName, car.full() == true)
  ),
  ((done) ->
    testName = 'amd should return all defined module names'

    define 'first', [], -> value: 1
    define 'second', [], -> value: 2

    definedamd = define.all()
    done(testName, definedamd.indexOf('first') && definedamd.indexOf('second'))
  ),
  ((done) ->
    testName = 'amd should only execute factory function once'
    callback = 0

    define 'newmodule', [], -> callback++

    require ['newmodule'], ->
      require ['newmodule'], ->
        require ['newmodule'], ->
          done(testName, callback == 1)
  ),
  ((done) ->
    testName = 'amd should only allow defining a module once'

    define 'amodule', [], -> 1
    define 'amodule', [], -> 2

    require ['amodule'], (amodule) -> done(testName, amodule == 1)
  ),
  ((done)->
    testName = 'amd should allow definitions without dependencies'

    define 'mymodule', -> 'foo'
    require ['mymodule'], (mymodule) -> done(testName, mymodule == 'foo')
  ),
  ((done) ->
    testName = 'amd should allow overriding of dependencies'

    define 'moduleToOverride', -> 'before'
    define.newContext()
    define.override 'moduleToOverride', 'after'
    require ['moduleToOverride'], (module) -> done(testName, module == 'after')
  ),
  ((done) ->
    testName = 'amd should allow overriding of overridden dependencies'

    define 'overrideLots', -> 'first'
    define.newContext()
    define.override 'overrideLots', 'second'
    define.newContext()
    define.override 'overrideLots', 'third'
    require ['overrideLots'], (module) ->
      done(testName, module == 'third')
  ),
  ((done) ->
    testName = 'amd should remove overridden dependency on new context'

    define 'pleaseResetThisModule', -> 'before'
    define.override 'pleaseResetThisModule', 'after'

    require ['pleaseResetThisModule'], ->
      define.newContext()

      require ['pleaseResetThisModule'], (module) ->
        done(testName, module == 'before')
  ),
  ((done) ->
    testName = 'amd can be overridden in define dependencies'

    define 'standsTall', -> 'tall'
    define 'leansOn', ['standsTall'], (tall) -> 'leans on ' + tall
    define.override 'standsTall', 'pretty high'

    require ['leansOn'], (leans) ->
      done(testName, leans == 'leans on pretty high')
  ),
  ((done) ->
    testName = 'amd delete factories when loaded by itself'
    define.config.optimise = true

    define 'aModuleUsingMemory', -> 'some value'

    require ['aModuleUsingMemory'], ->
      expression = defined['aModuleUsingMemory'].factory == undefined &&
      defined['aModuleUsingMemory'].dependencyNames == undefined

      done(testName, expression)
  ),
  ((done) ->
    testName = 'amd delete factories when loaded by others'
    define.config.optimise = true

    define 'module123', -> 'some value'
    define 'module321', ['module123'], -> 'some value'

    require ['module321'], ->
      expression = defined['module321'].factory == undefined &&
      defined['module321'].dependencyNames == undefined

      done(testName, expression)
  ),
  ((done) ->
    testName = 'amd delete waiting amd when they are loaded'
    define.config.optimise = true

    require ['module567'], ->

    waiting['module567'][0].promise.then ->
      done(testName, waiting['module567'] == undefined)

    define 'module567', -> 'some value'
  ),
  ((done) ->
    testName = 'amd dont delete factories when loaded by itself and no optimisation requested'
    define.config.optimise = false

    define 'module167', -> 'some value'

    require ['module167'], ->
      expression = defined['module167'].factory != undefined &&
                   defined['module167'].dependencyNames != undefined

      done(testName, expression)
  ),
  ((done) ->
    testName = 'amd delete factories when loaded by others and no optimisation requested'
    define.config.optimise = false

    define 'module876', -> 'some value'
    define 'module981', ['module876'], -> 'some value'

    require ['module981'], ->
      expression = defined['module981'].factory != undefined &&
                   defined['module981'].dependencyNames != undefined

      done(testName, expression)
  )
  ((done) ->
    testName = 'amd dont delete waiting amd when no optimisation requested'
    define.config.optimise = false

    require ['module135'], ->

    waiting['module135'][0].promise.then ->
      done(testName, waiting['module135'] != undefined)

    define 'module135', -> 'some value'
  )]

runTest = (index) ->
  tests[index] (testName, condition) ->
    printOutcome(testName, condition)

    nextIndex = index + 1
    runTest(nextIndex) if nextIndex < tests.length

runTest(0)


