
Deferred =
  create: ->
    callbacks = []
    resolved = false
    rejected = false

    resolve: (value) ->
      if !resolved && !rejected
        callback.success(value) for callback in callbacks
        resolved = { value: value }

    reject: (value) ->
      if !resolved && !rejected
        callback.failure(value) for callback in callbacks
        rejected = { value: value }

    promise:
      then: (success, failure) ->
        success(resolved.value) if resolved
        failure(rejected.value) if rejected

        if !rejected && !resolved
          callbacks.push({ success: success, failure: failure })

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
