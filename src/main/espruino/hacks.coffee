

# This class exists to make life easier to overcome for features / quirks
# regarding the espruino.

# This is deliberately not an AMD module. These variables should be
# defined globally.

# Error isn't defined by the espruino.

# Don't pass this error to the fail whale, if the fail whale
# can't be loaded then we end up in a recursive loop until we
# stack overflow.
Error = (message) -> console.log('ERROR FOUND:', message)

