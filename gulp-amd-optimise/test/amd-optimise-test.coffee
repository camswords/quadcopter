expect = require 'expect.js'
Readable = require('stream').Readable
StringStream = require('string-stream')
File = require('vinyl')
through = require('through2')
gulp = require 'gulp'
amdOptimise = require '../src/amd-optimise'
util = require 'util'

createObjectStream = (object) ->
  CodeStream = -> Readable.call(@, objectMode: true)

  util.inherits(CodeStream, Readable)

  CodeStream.prototype._read = ->
    this.push(object)
    this.push(null)

  new CodeStream(object)

describe 'amd-optimise', ->
  it 'should optimise amd modules', (done) ->
    sourceCode = ''

    gulp.src('./gulp-amd-optimise/test/some-modules.js')
        .pipe amdOptimise()
        .on 'data', (data) -> sourceCode += data.contents.toString()
        .on 'end', ->
          eval(sourceCode)
          expect(modules['a']).to.be('a')
          expect(modules['b']).to.be('ab')
          expect(modules['c']).to.be('abac')
          expect(modules['d']).to.be('d')
          expect(modules['e']).to.be('ababace')
          expect(modules['f']).to.be('f')
          expect(modules['g']).to.be('fabg')
          expect(modules['h']).to.be('fabgababaceh')
          done()

  it 'should pass along non read file streams', (done) ->
    createObjectStream(new File(contents: null))
      .pipe through.obj (file, encoding, callback) ->
        expect(file.contents).to.be.null
        this.push(null)
        callback()
        done()

  it 'should barf when contents is a stream', (done) ->
    optimiseStream = amdOptimise()

    optimiseStream.on 'error', (error) ->
      expect(error).to.equal('gulp-amd-optimise does not support streaming. Barfing.')
      done()

    createObjectStream new File(contents: new StringStream('code'))
        .pipe(optimiseStream)
