
wait = {};

wait.until = (isSatisfied) ->
  if !isSatisfied()
    process.stdout.write('.')
    setTimeout((-> wait.until(isSatisfied)), 100)

module.exports = wait
