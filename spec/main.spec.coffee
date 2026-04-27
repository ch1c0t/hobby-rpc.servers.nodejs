describe 'Server', ->
  beforeAll ->
    { RPC } = await import('hobby-rpc')
    global.RPC = RPC

  beforeEach ->
    await serve """
      functions:
        Hello: (name) ->
          "Hello, \#{name}."
        AsyncFunction: ->
          Promise.resolve 'from AsyncFunction'
        FailingAsyncFunction: ->
          Promise.reject()
        AsyncFunctionResolvingToFalse: ->
          Promise.resolve false
    """, @

  it 'responds to Hello', ->
    rpc = RPC url: @url
    await expectAsync rpc 'Hello', 'World'
      .toBeResolvedTo 'Hello, World.'

  it 'fails for functions that do not exist', ->
    rpc = RPC url: @url
    await expectAsync(rpc 'BadName', 'World').toBeRejectedWith 400

  it 'responds to AsyncFunction', ->
    rpc = RPC url: @url
    await expectAsync rpc 'AsyncFunction'
      .toBeResolvedTo 'from AsyncFunction'

  it 'fails for functions returning rejected Promises', ->
    rpc = RPC url: @url
    await expectAsync(rpc 'FailingAsyncFunction').toBeRejectedWith 400

  it 'responds to AsyncFunctionResolvingToFalse', ->
    rpc = RPC url: @url
    await expectAsync rpc 'AsyncFunctionResolvingToFalse'
      .toBeResolvedTo false
