expect = require 'expect.js'
order = require '../src/order-defines'

describe 'order-defines', ->

  it 'should return empty array when no defines are provided', (done) ->
    order [], (ordered) ->
      expect(ordered).to.eql([])
      done()

  it 'should return empty array when defines are null', (done) ->
    order null, (ordered) ->
      expect(ordered).to.eql([])
      done()

  it 'should return empty array when defines are undefined', (done) ->
    order undefined, (ordered) ->
      expect(ordered).to.eql([])
      done()

  it 'should return define when there is only one', (done) ->
    defines =
      module:
        dependencyNames: []
        factory: 'factory'

    order defines, (ordered) ->
      expect(Object.keys(ordered).length).to.be(1)
      expect(ordered[0].name).to.be('module')
      expect(ordered[0].dependencyNames).to.eql([])
      expect(ordered[0].factory).to.be('factory')
      done()

  it 'should return defines when they dont have any dependencies', (done) ->
    defines =
      moduleA: dependencyNames: []
      moduleB: dependencyNames: []

    order defines, (ordered) ->
      expect(Object.keys(ordered).length).to.be(2)
      expect(ordered[0].name).to.be('moduleA')
      expect(ordered[0].dependencyNames).to.eql([])
      expect(ordered[1].name).to.be('moduleB')
      expect(ordered[1].dependencyNames).to.eql([])
      done()

  it 'should return defines in least constrained dependencies order when provided in order', (done) ->
    defines =
      moduleA: dependencyNames: []
      moduleB: dependencyNames: ['moduleA']

    order defines, (ordered) ->
      expect(Object.keys(ordered).length).to.be(2)
      expect(ordered[0].name).to.be('moduleA')
      expect(ordered[0].dependencyNames).to.eql([])
      expect(ordered[1].name).to.be('moduleB')
      expect(ordered[1].dependencyNames).to.eql(['moduleA'])
      done()

  it 'should return defines in least constrained dependencies order when provided out of order', (done) ->
    defines =
      moduleB: dependencyNames: ['moduleA']
      moduleA: dependencyNames: []

    order defines, (ordered) ->
      expect(Object.keys(ordered).length).to.be(2)
      expect(ordered[0].name).to.be('moduleA')
      expect(ordered[0].dependencyNames).to.eql([])
      expect(ordered[1].name).to.be('moduleB')
      expect(ordered[1].dependencyNames).to.eql(['moduleA'])
      done()

  it 'should include disconnected module dependencies', (done) ->
    defines =
      moduleA: dependencyNames: []
      moduleB: dependencyNames: ['moduleA']
      moduleD: dependencyNames: ['moduleC']
      moduleC: dependencyNames: []

    order defines, (ordered) ->
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
