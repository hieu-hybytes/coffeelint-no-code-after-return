f = ->
  reachable()
  if something
    reachable()
    if somethingElse
      reachable()
      return 'something'
      unreachable()
    else
      return 'nothing'
    unreachable()
  reachable()
