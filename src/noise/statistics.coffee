
numberOfValues = 0
oldMean = 0
newMean = 0
oldStd = 0
newStd = 0


api = {};

api.clear = -> numberOfValues = 0

api.push = (value) ->
  numberOfValues++

  if (numberOfValues == 1)
    oldMean = newMean = value
    oldStd = 0.0
  else
    newMean = oldMean + (value - oldMean) / numberOfValues
    newStd = oldStd + (value - oldMean) * (value - newMean)
  
    oldMean = newMean
    oldStd = newStd

api.numberOfValues = -> numberOfValues

api.mean = -> 
  if (numberOfValues > 0) 
    return newMean
  return 0.0

api.variance = -> 
  if (numberOfValues > 1) 
    return (newStd / (numberOfValues - 1))
  return 0.0

api.standardDeviation = -> Math.sqrt(api.variance());

module.exports = api;