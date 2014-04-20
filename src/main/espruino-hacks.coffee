

# This class exists to make life easier to overcome for features / quirks
# regarding the espruino.


# Error isn't defined by the espruino.
# If anyone creates one, print the error message, then quit.
Error = (message) ->
  console.log 'ERROR:', message
  quit()


