escodegen = require 'escodegen'

defineModuleVariable = ->
  type: "ExpressionStatement",
  expression:
    type: "AssignmentExpression",
    operator: "=",
    left:
      type: "Identifier",
      name: "modules"
    right:
      type: "ObjectExpression",
      properties: []

callModuleFunction = (module) ->
  statement =
    type: 'ExpressionStatement',
    expression:
      type: 'AssignmentExpression',
      operator: '=',
      left:
        type: 'MemberExpression',
        computed: true,
        object:
          type: 'Identifier',
          name: 'modules'
        property:
          type: 'Literal',
          value: module.name,
          raw: module.name
      right:
        type: 'CallExpression',
        callee: module.factory
        arguments: []

  for dependencyName in module.dependencyNames
    statement.expression.right.arguments.push
      type: 'MemberExpression',
      computed: true,
      object:
        type: 'Identifier',
        name: 'modules'
      property:
        type: 'Literal',
        value: dependencyName,
        raw: dependencyName

  statement

module.exports =
  generate: (modules) ->
    ast = type: "Program", body: [defineModuleVariable()]

    for module in modules
      ast.body.push(callModuleFunction(module))

    escodegen.generate(ast)


