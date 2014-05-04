uglify = require 'gulp-uglify'

module.exports = ->
  uglify
    mangle: false,
    compress:
      sequences     : true,
      properties    : true,
      dead_code     : true,
      drop_debugger : true,
      unsafe        : false,
      unsafe_comps  : false,
      conditionals  : true,
      comparisons   : true,
      evaluate      : true,
      booleans      : true,
      loops         : true,
      unused        : true,
      hoist_funs    : true,
      keep_fargs    : false,
      hoist_vars    : false,
      if_return     : true,
      join_vars     : true,
      cascade       : true,
      side_effects  : false,
      pure_getters  : false,
      pure_funcs    : null,
      negate_iife   : true,
      drop_console  : false
