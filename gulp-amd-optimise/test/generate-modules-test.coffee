expect = require 'expect.js'
esprima = require 'esprima'
sourceCode = require '../src/generate-modules'

astOfFunction = (functionSource) ->
  ast = esprima.parse('var foo = ' + functionSource)
  ast.body[0].declarations[0].init

describe 'generate-modules', ->

  it 'should generate code given a single define', ->
    module =
      name: 'module'
      dependencyNames: []
      factory: astOfFunction('function() { return 67; }')

    eval(sourceCode.generate([module]))
    expect(modules['module']).to.be(67)

  it 'should pass in a modules dependencies', ->
    moduleA =
      name: 'moduleA'
      dependencyNames: []
      factory: astOfFunction('function() { return 22; }')

    moduleB =
      name: 'moduleB'
      dependencyNames: ['moduleA']
      factory: astOfFunction('function(moduleA) { return 10 + moduleA; }')

    eval(sourceCode.generate([moduleA, moduleB]))
    expect(modules['moduleA']).to.be(22)
    expect(modules['moduleB']).to.be(32)

  it 'should pass in module dependencies in correct order', ->
    moduleA =
      name: 'moduleA'
      dependencyNames: []
      factory: astOfFunction('function() { return "a"; }')

    moduleB =
      name: 'moduleB'
      dependencyNames: ['moduleA']
      factory: astOfFunction('function(moduleA) { return moduleA + "b"; }')

    moduleC =
      name: 'moduleC'
      dependencyNames: ['moduleB', 'moduleA']
      factory: astOfFunction('function(moduleB, moduleA) { return moduleB + moduleA + "c"; }')

    eval(sourceCode.generate([moduleA, moduleB, moduleC]))
    expect(modules['moduleA']).to.be('a')
    expect(modules['moduleB']).to.be('ab')
    expect(modules['moduleC']).to.be('abac')

  it 'should record amount of memory each module requires', ->
    moduleA =
      name: 'moduleA'
      dependencyNames: []
      factory: astOfFunction('function() { return 102; }')

    moduleB =
      name: 'moduleB'
      dependencyNames: []
      factory: astOfFunction('function(moduleA) { return "a string"; }')

    processMemoryDefn = "
      var timesCalled = 0;

      process.memory = function() {
        timesCalled++;
        return { usage: timesCalled * timesCalled };
      };
    "
    sourceCode = sourceCode.generate([moduleA, moduleB], recordMemoryUsage: true)
    eval(processMemoryDefn + sourceCode)

    expect(memoryUsage['moduleA']).to.be(3)
    expect(memoryUsage['moduleB']).to.be(7)
