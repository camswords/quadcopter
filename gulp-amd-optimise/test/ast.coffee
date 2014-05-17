expect = require 'expect.js'
astFactory = require '../src/ast'

describe 'ast', ->
  describe 'build', ->
    it 'should generate ast of javascript code', ->
      source = 'define("module", [], function() {});'
      ast = astFactory.build(source)

      expect(ast).to.be.ok()
      expect(ast.type).to.be('Program')

  describe 'defines', ->
    it 'should return single item with no dependencies', ->
      ast = astFactory.build('define("module", [], function() {});')

      defined = ast.defines()
      expect(Object.keys(defined).length).to.be(1)
      expect(defined['module'].dependencyNames).to.eql([])
      expect(defined['module'].factory.type).to.be('FunctionExpression')

    it 'should return single item with no dependencies when no dependencies are specified', ->
      ast = astFactory.build('define("module", function() {});')

      defined = ast.defines()
      expect(Object.keys(defined).length).to.be(1)
      expect(defined['module'].dependencyNames).to.eql([])
      expect(defined['module'].factory.type).to.be('FunctionExpression')

    it 'should ignore defines with only one parameter', ->
      ast = astFactory.build('define("module");')

      defined = ast.defines()
      expect(Object.keys(defined).length).to.be(0)
