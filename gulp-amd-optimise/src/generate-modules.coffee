escodegen = require 'escodegen'

instantiateObject = (variableName) ->
  type: "ExpressionStatement"
  expression:
    type: "AssignmentExpression"
    operator: "="
    left:
      type: "Identifier"
      name: variableName
    right:
      type: "ObjectExpression"
      properties: []

callModuleFunction = (module) ->
  statement =
    type: 'ExpressionStatement'
    expression:
      type: 'AssignmentExpression'
      operator: '='
      left:
        type: 'MemberExpression'
        computed: true
        object:
          type: 'Identifier'
          name: 'modules'
        property:
          type: 'Literal'
          value: module.name
          raw: module.name
      right:
        type: 'CallExpression'
        callee: module.factory
        arguments: []

  for dependencyName in module.dependencyNames
    statement.expression.right.arguments.push
      type: 'MemberExpression'
      computed: true
      object:
        type: 'Identifier'
        name: 'modules'
      property:
        type: 'Literal'
        value: dependencyName
        raw: dependencyName

  statement

recordMemoryBaseline = ->
  type: 'VariableDeclaration'
  declarations: [
    type: 'VariableDeclarator'
    id:
      type: 'Identifier'
      name: 'memoryBeforeModule'
    init:
      type: 'MemberExpression'
      computed: false
      object:
        type: 'CallExpression'
        callee:
          type: 'MemberExpression'
          computed: false
          object:
            type: 'Identifier'
            name: 'process'
          property:
            type: 'Identifier'
            name: 'memory'
        arguments: []
      property:
        type: 'Identifier'
        name: 'usage'
  ]
  kind: 'var'

recordMemoryForModule = (module) ->
  type: 'ExpressionStatement'
  expression:
    type: 'AssignmentExpression'
    operator: '='
    left:
      type: 'MemberExpression'
      computed: true
      object:
        type: 'Identifier'
        name: 'memoryUsage'
      property:
        type: 'Literal'
        value: module.name
        raw: module.name
    right:
      type: 'BinaryExpression'
      operator: '-'
      left:
        type: 'MemberExpression'
        computed: false
        object:
          type: 'CallExpression'
          callee:
            type: 'MemberExpression'
            computed: false
            object:
              type: 'Identifier'
              name: 'process'
            property:
              type: 'Identifier'
              name: 'memory'
          arguments: []
        property:
          type: 'Identifier'
          name: 'usage'
      right:
        type: 'Identifier'
        name: 'memoryBeforeModule'

module.exports =
  generate: (modules, options) ->
    ast =
      type: "Program"
      body: [instantiateObject('modules')]

    if options?.recordMemoryUsage
      ast.body.push instantiateObject('memoryUsage')

    for module in modules
      if options?.recordMemoryUsage
        ast.body.push recordMemoryBaseline()
      ast.body.push callModuleFunction(module)

      if options?.recordMemoryUsage
        ast.body.push recordMemoryForModule(module)

    escodegen.generate(ast)


