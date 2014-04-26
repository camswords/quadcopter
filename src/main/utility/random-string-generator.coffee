
define 'utility/random-string-generator', ->

  possibles = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
  nextCharacter = -> possibles[Math.floor(Math.random() * possibles.length)]

  ->
    nextCharacter() + nextCharacter() + nextCharacter() + nextCharacter() + nextCharacter()
