uglify = require 'gulp-uglify'

module.exports = ->
  uglify
    mangle: false,
    compress:
      sequences: false,
      properties: false,
      dead_code: false,
      drop_debugger: false,
      unsafe: false,
      unsafe_comps: false,
      conditionals: false,
      comparisons: false,
      evaluate: false,
      booleans: false,
      loops: false,
      unused: false,
      hoist_funs: false,
      keep_fargs: false,
      hoist_vars: false,
      if_return: false,
      join_vars: false,
      cascade: false,
      side_effects: false,
      pure_getters: false,
      pure_funcs: null,
      negate_iife: false,
      drop_console: false
