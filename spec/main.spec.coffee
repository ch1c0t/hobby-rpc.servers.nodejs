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

    it 'responds to Hello', ->
      output = await rpc 'Hello', 'World'
      expect(output).toBe 'Hello, World.'

    it 'fails for functions that do not exist', ->
      await expectAsync(rpc 'SomeName', 'World').toBeRejectedWith 400

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
