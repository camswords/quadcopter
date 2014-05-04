

# This class exists to make life easier to overcome for features / quirks
# regarding the espruino.

# This is deliberately not an AMD module. These variables should be
# defined globally. This ensures that these hacks work even when AMD loading fails.

# This file should be loaded first onto the Espruino.

# Use instead of throwing 'new Error'. Replace this with Error if Exceptions are ever implemented.
ReportError = (message) -> console.log('ERROR FOUND:', message)
