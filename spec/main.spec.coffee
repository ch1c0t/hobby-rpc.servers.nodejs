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

  describe 'FindUser', ->
    beforeEach ->
      @server = await StartServer
        functions:
          SomeFunction: -> 'output'
          HelloName: ->
            "Hello, #{@user.name}."
        FindUser: (token) ->
          if token is 'ValidToken'
            name: 'ValidUser'

    it 'returns the output when a valid token was passed', ->
      rpc = RPC
        url: 'http://localhost:8090'
        token: 'ValidToken'

      output = await rpc 'SomeFunction'
      expect(output).toBe 'output'

    it 'fails when no token was passed', ->
      await expectAsync(rpc 'SomeFunction').toBeRejectedWith 403

    it 'fails when an invalid token was passed', ->
      rpc = RPC
        url: 'http://localhost:8090'
        token: 'InvalidToken'

      await expectAsync(rpc 'SomeFunction').toBeRejectedWith 403

    it 'provides access to a user', ->
      rpc = RPC
        url: 'http://localhost:8090'
        token: 'ValidToken'

      output = await rpc 'HelloName'
      expect(output).toBe "Hello, ValidUser."

    it 'resolves a user promise', ->
      server = await StartServer
        port: 8091
        functions:
          HelloName: ->
            "Hello, #{@user.name}."
        FindUser: (token) ->
          if token is 'ValidToken'
            Promise.resolve name: 'ValidUser'

      rpc = RPC
        url: 'http://localhost:8091'
        token: 'ValidToken'

      output = await rpc 'HelloName'
      expect(output).toBe "Hello, ValidUser."

      await StopServer server

    it 'handles a rejected Promise as an authentication failure', ->
      server = await StartServer
        port: 8091
        functions:
          HelloName: ->
            "Hello, #{@user.name}."
        FindUser: (token) ->
          Promise.reject()

      rpc = RPC
        url: 'http://localhost:8091'
        token: 'ValidToken'

      await expectAsync(rpc 'HelloName').toBeRejectedWith 403

      await StopServer server

    it 'handles a Promise resolved to a falsy value as an authentication failure', ->
      server = await StartServer
        port: 8091
        functions:
          HelloName: ->
            "Hello, #{@user.name}."
        FindUser: (token) ->
          Promise.resolve false

      rpc = RPC
        url: 'http://localhost:8091'
        token: 'ValidToken'

      await expectAsync(rpc 'HelloName').toBeRejectedWith 403

      await StopServer server
