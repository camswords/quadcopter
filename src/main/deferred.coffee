
Deferred =
  create: ->
    callbacks = []
    resolved = false
    rejected = false

    nextTick = (callback, parameters) ->
      setTimeout (-> callback.apply({}, parameters)), 1

    self = {}
    self.isFinished = -> !!(resolved || rejected)

    self.resolve = (value) ->
      if !self.isFinished()
        nextTick(callback.success, [value]) for callback in callbacks
        resolved = { value: value }

    self.reject = (value) ->
      if !self.isFinished()
        nextTick(callback.failure, [value]) for callback in callbacks
        rejected = { value: value }

    self.promise =
      then: (success, failure) ->
        success = success || ->
        failure = failure || ->

        nextTick(success, [resolved.value]) if resolved
        nextTick(failure, [rejected.value]) if rejected

        if !self.isFinished()
          callbacks.push({ success: success, failure: failure })

    self

  all: (promises) ->
    deferred = Deferred.create()
    results = new Array(promises.length)
    callbacks = 0

    for promise, index in promises
      onSuccess = ((elementIndex) ->
        (value) ->
          results[elementIndex] = value
          deferred.resolve(results) if ++callbacks == promises.length
      )(index)

      onFailure = (value) -> deferred.reject(value)

      promise.then(onSuccess, onFailure)

    deferred.promise
