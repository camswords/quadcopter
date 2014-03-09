
wait = until: (options, retries) ->
    retries = 50 if !retries && retries != 0

    if !options.isSatisfied()
      if retries == 0
        throw new Error("That's it, I'm giving up! I've waited for #{options.description} long enough.")

      process.stdout.write('.')
      setTimeout((-> wait.until(options, retries - 1)), 100)

module.exports = wait
