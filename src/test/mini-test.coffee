
it = (description, spec) ->
  if spec()
    console.log 'passed:', description
  else
    console.log 'failed:', description
