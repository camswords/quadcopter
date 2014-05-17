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

    it 'should return dependency names', ->
      ast = astFactory.build('define("module", ["dependencyA", "dependencyB"], function() {});')

      defined = ast.defines()
      expect(Object.keys(defined).length).to.be(1)
      expect(defined['module'].dependencyNames).to.eql(['dependencyA', 'dependencyB'])

    it 'should return dependencies when there are multiple defines', ->
      ast = astFactory.build(
        'define("moduleA", ["moduleC"], function() {});
         define("moduleB", ["moduleD", "moduleE"], function() {});')

      defined = ast.defines()
      expect(Object.keys(defined).length).to.be(2)
      expect(defined['moduleA'].dependencyNames).to.eql(['moduleC'])
      expect(defined['moduleB'].dependencyNames).to.eql(['moduleD', 'moduleE'])

    it 'should ignore source code that is not a define', ->
      ast = astFactory.build(
          'console.log("foo");
           define("module", [], function() {});
           console.log("bar");')

      defined = ast.defines()
      expect(Object.keys(defined).length).to.be(1)
      expect(defined['module'].dependencyNames).to.eql([])

    it 'should ignore defines that are called from within functions', ->
      ast = astFactory.build(
          'var myfunc = function() {
            define("module", [], function() {});
           };')

      defined = ast.defines()
      expect(Object.keys(defined).length).to.be(0)
