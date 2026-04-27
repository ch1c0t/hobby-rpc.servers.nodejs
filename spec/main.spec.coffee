{ StartServer, StopServer } = require './server.setup.coffee'

describe 'Server', ->
  beforeAll ->
    { RPC } = await import('hobby-rpc')
    global.RPC = RPC
    global.rpc = RPC url: 'http://localhost:8090'

  afterEach ->
    await StopServer @server

  describe 'Basics', ->
    beforeEach ->
      @server = await StartServer
        functions:
          Hello: (name) ->
            "Hello, #{name}."
          AsyncFunction: ->
            Promise.resolve 'from AsyncFunction'
          FailingAsyncFunction: ->
            Promise.reject()
          AsyncFunctionResolvingToFalse: ->
            Promise.resolve false

    it 'responds to Hello', ->
      output = await rpc 'Hello', 'World'
      expect(output).toBe 'Hello, World.'

    it 'fails for functions that do not exist', ->
      await expectAsync(rpc 'BadName', 'World').toBeRejectedWith 400

    it 'responds to AsyncFunction', ->
      output = await rpc 'AsyncFunction'
      expect(output).toBe 'from AsyncFunction'

    it 'fails for functions returning rejected Promises', ->
      await expectAsync(rpc 'FailingAsyncFunction').toBeRejectedWith 400

    it 'responds to AsyncFunctionResolvingToFalse', ->
      output = await rpc 'AsyncFunctionResolvingToFalse'
      expect(output).toBe false
