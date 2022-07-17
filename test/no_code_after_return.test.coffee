_ = require 'lodash'
chai = require 'chai'
coffeelint = require 'coffeelint'
fs = require 'fs'
path = require 'path'

NoCodeAfterReturn = require path.join '..', 'coffeelint_no_code_after_return'
coffeelint.registerRule NoCodeAfterReturn

expect = chai.expect

examplesDir = path.join __dirname, 'examples'

isExampleFile = (name) -> /_example\.coffee$/.test name
isNegative = (name) -> /^negative_/.test name
forEachExample = (fn) ->
  files = fs.readdirSync examplesDir
  files.filter(isExampleFile).forEach fn
getUnreachableLines = (source) ->
  _(source).split("\n")
    .map (line, num) -> if /unreachable/.test line then num+1 else null
    .compact().value()

describe 'No Code After Return', ->
  forEachExample (filename) ->
    examplePath = path.join __dirname, 'examples', filename
    context "\"#{filename}\"", ->
      if isNegative(filename)
        it 'does not have any dead code', (done) ->
          fs.readFile examplePath, (err, source) ->
            return done(err) if err

            errors = coffeelint.lint(source.toString())

            expect(errors).to.be.empty

            done()

      else
        it 'has dead code', (done) ->
          fs.readFile examplePath, (err, source) ->
            return done(err) if err
            unreachableLines = getUnreachableLines(source)

            errors = coffeelint.lint(source.toString())

            expect(errors).to.have.length unreachableLines.length
            _.zip(errors, unreachableLines).forEach (pair) ->
              expect(pair[0].lineNumber).to.equal pair[1]

            done()
