esprima = require 'esprima'

module.exports =
  build: (source) ->
    ast = esprima.parse(source)

    ast.defines = ->
      defines = {}

      for expressionStatement in ast.body
        if expressionStatement.type == 'ExpressionStatement' &&
           expressionStatement.expression.type == 'CallExpression' &&
           expressionStatement.expression.callee.name == 'define'

          parameters = expressionStatement.expression.arguments
          name = parameters[0].value

          if parameters.length == 2
            defines[name] =
              name: name
              dependencyNames: []
              factory: parameters[1]
          else if parameters.length == 3
            defines[name] =
              name: name
              dependencyNames: (element.value for element in parameters[1].elements)
              factory: parameters[2]

      defines

    ast
