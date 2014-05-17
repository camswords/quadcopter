expect = require 'expect.js'
gulp = require 'gulp'
amdOptimise = require '../src/amd-optimise'

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
