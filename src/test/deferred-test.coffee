
outcome = (test, condition) ->
  if condition
    console.log "passed: #{test}"
  else
    console.log "failed: #{test}"


(->
  testName = 'deferred should execute success when deferred is resolved'
  deferred = Deferred.create()

  onSuccess = (value) -> outcome(testName, value == 12345)
  onFailure = -> outcome(testName, false)
  deferred.promise.then onSuccess, onFailure

  deferred.resolve(12345)
)()

(->
  testName = 'deferred should execute success when callback is registered after deferred is resolved'
  deferred = Deferred.create()

  deferred.resolve(54321)

  onSuccess = (value) -> outcome(testName, value == 54321)
  onFailure = -> outcome(testName, false)
  deferred.promise.then onSuccess, onFailure
)()

(->
  testName = 'deferred should execute failure when deferred is rejected'
  deferred = Deferred.create()

  onSuccess = -> outcome(testName, false)
  onFailure = (value) -> outcome(testName, value == 'an error message')
  deferred.promise.then onSuccess, onFailure

  deferred.reject('an error message')
)()

(->
  testName = 'deferred should execute failure when callback is registered after deferred is rejected'
  deferred = Deferred.create()

  deferred.reject('error message')

  onSuccess = -> outcome(testName, false)
  onFailure = (value) -> outcome(testName, value == 'error message')
  deferred.promise.then onSuccess, onFailure
)()

(->
  testName = 'deferred should only resolve once'
  deferred = Deferred.create()

  deferred.resolve('message')
  deferred.reject(1)
  deferred.resolve(100.23)

  onSuccess = (value) -> outcome(testName, value == 'message')
  onFailure = -> outcome(testName, false)
  deferred.promise.then onSuccess, onFailure
)()

(->
  testName = 'deferred should only reject once'
  deferred = Deferred.create()

  deferred.reject('error')
  deferred.resolve(1)
  deferred.reject(100.23)

  onSuccess = -> outcome(testName, false)
  onFailure = (value) -> outcome(testName, value == 'error')
  deferred.promise.then onSuccess, onFailure
)()

(->
  testName = 'deferred all should callback when all promises are resolved'
  deferredA = Deferred.create()
  deferredB = Deferred.create()

  deferredA.resolve('a')
  deferredB.resolve('b')

  onSuccess = ([valueA, valueB]) ->
    outcome(testName, valueA == 'a' && valueB == 'b')
  onFailure = -> outcome(testName, false)
  Deferred.all([deferredA.promise, deferredB.promise]).then onSuccess, onFailure
)()

(->
  testName = 'deferred all should callback when some promises are resolved after callback is attached'
  deferredA = Deferred.create()
  deferredB = Deferred.create()

  deferredA.resolve('a')

  onSuccess = ([valueA, valueB]) ->
    outcome(testName, valueA == 'a' && valueB == 'b')
  onFailure = -> outcome(testName, false)
  Deferred.all([deferredA.promise, deferredB.promise]).then onSuccess, onFailure

  deferredB.resolve('b')
)()

(->
  testName = 'deferred all should callback when all promises are resolved after callback is attached'
  deferredA = Deferred.create()
  deferredB = Deferred.create()

  onSuccess = ([valueA, valueB]) ->
    outcome(testName, valueA == 'a' && valueB == 'b')
  onFailure = -> outcome(testName, false)
  Deferred.all([deferredA.promise, deferredB.promise]).then onSuccess, onFailure

  deferredA.resolve('a')
  deferredB.resolve('b')
)()

(->
  testName = 'deferred all should fail if one promise fails'
  deferredA = Deferred.create()
  deferredB = Deferred.create()

  deferredA.resolve('a')
  deferredB.reject('error')

  onSuccess = -> outcome(testName, false)
  onFailure = (value) -> outcome(testName, value == 'error')
  Deferred.all([deferredA.promise, deferredB.promise]).then onSuccess, onFailure
)()

(->
  testName = 'deferred all should fail if a promise fails after callbacks are registered'
  deferredA = Deferred.create()
  deferredB = Deferred.create()

  deferredA.resolve('a')

  onSuccess = -> outcome(testName, false)
  onFailure = (value) -> outcome(testName, value == 'error')
  Deferred.all([deferredA.promise, deferredB.promise]).then onSuccess, onFailure

  deferredB.reject('error')
)()
