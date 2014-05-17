expect = require 'expect.js'
order = require '../src/order-defines'

describe 'order-defines', ->

  it 'should return empty array when no defines are provided', (done) ->
    order [], (error, ordered) ->
      expect(ordered).to.eql([])
      done()

  it 'should return empty array when defines are null', (done) ->
    order null, (error, ordered) ->
      expect(ordered).to.eql([])
      done()

  it 'should return empty array when defines are undefined', (done) ->
    order undefined, (error, ordered) ->
      expect(ordered).to.eql([])
      done()

  it 'should return define when there is only one', (done) ->
    defines =
      module:
        name: 'module',
        dependencyNames: []
        factory: 'factory'

    order defines, (error, ordered) ->
      expect(Object.keys(ordered).length).to.be(1)
      expect(ordered[0].name).to.be('module')
      expect(ordered[0].dependencyNames).to.eql([])
      expect(ordered[0].factory).to.be('factory')
      done()

  it 'should return defines when they dont have any dependencies', (done) ->
    defines =
      moduleA: name: 'moduleA', dependencyNames: []
      moduleB: name: 'moduleB', dependencyNames: []

    order defines, (error, ordered) ->
      expect(Object.keys(ordered).length).to.be(2)
      expect(ordered[0].name).to.be('moduleA')
      expect(ordered[0].dependencyNames).to.eql([])
      expect(ordered[1].name).to.be('moduleB')
      expect(ordered[1].dependencyNames).to.eql([])
      done()

  it 'should return defines in least constrained dependencies order when provided in order', (done) ->
    defines =
      moduleA: name: 'moduleA', dependencyNames: []
      moduleB: name: 'moduleB', dependencyNames: ['moduleA']

    order defines, (error, ordered) ->
      expect(Object.keys(ordered).length).to.be(2)
      expect(ordered[0].name).to.be('moduleA')
      expect(ordered[0].dependencyNames).to.eql([])
      expect(ordered[1].name).to.be('moduleB')
      expect(ordered[1].dependencyNames).to.eql(['moduleA'])
      done()

  it 'should return defines in least constrained dependencies order when provided out of order', (done) ->
    defines =
      moduleB: name: 'moduleB', dependencyNames: ['moduleA']
      moduleA: name: 'moduleA', dependencyNames: []

    order defines, (error, ordered) ->
      expect(Object.keys(ordered).length).to.be(2)
      expect(ordered[0].name).to.be('moduleA')
      expect(ordered[0].dependencyNames).to.eql([])
      expect(ordered[1].name).to.be('moduleB')
      expect(ordered[1].dependencyNames).to.eql(['moduleA'])
      done()

  it 'should include disconnected module dependencies', (done) ->
    defines =
      moduleA: name: 'moduleA', dependencyNames: []
      moduleB: name: 'moduleB', dependencyNames: ['moduleA']
      moduleD: name: 'moduleD', dependencyNames: ['moduleC']
      moduleC: name: 'moduleC', dependencyNames: []

    order defines, (error, ordered) ->
      expect(Object.keys(ordered).length).to.be(4)
      expect(ordered[0].name).to.be('moduleA')
      expect(ordered[0].dependencyNames).to.eql([])
      expect(ordered[1].name).to.be('moduleC')
      expect(ordered[1].dependencyNames).to.eql([])
      expect(ordered[2].name).to.be('moduleB')
      expect(ordered[2].dependencyNames).to.eql(['moduleA'])
      expect(ordered[3].name).to.be('moduleD')
      expect(ordered[3].dependencyNames).to.eql(['moduleC'])
      done()

  it 'should throw error when there are cyclic dependencies', (done) ->
    defines =
      moduleA: name: 'moduleA', dependencyNames: ['moduleB']
      moduleB: name: 'moduleB', dependencyNames: ['moduleA']

    order defines, (error) ->
      expect(error.message).to.be('moduleA can not come before moduleB')
      done()
