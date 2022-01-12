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

  describe 'CORS', ->
    it 'sets default CORS headers', ->
      @server = await StartServer
        functions:
          Hello: (name) ->
            "Hello, #{name}."

      response = await fetch 'http://localhost:8090', method: 'OPTIONS'
      expect(response.status).toBe 200
      expect(response.headers.get 'Access-Control-Allow-Methods').toBe 'POST, OPTIONS'
      expect(response.headers.get 'Access-Control-Allow-Headers').toBe 'Authorization, Content-Type'
      expect(response.headers.get 'Access-Control-Max-Age').toBe '86400'

      response = await fetch 'http://localhost:8090',
        method: 'POST'
        headers:
          'Content-Type': 'application/json'
        body: JSON.stringify
          fn: 'Hello'
          in: 'A'

      expect(response.status).toBe 200
      expect(response.headers.get 'Access-Control-Allow-Origin').toBe '*'

    it 'allows to pass custom CORS headers', ->
      @server = await StartServer
        CORS:
          Methods: 'GET, POST, OPTIONS'
          Headers: 'Authorization, Content-Type, Content-Length'
          MaxAge: '80000'
        functions:
          Hello: (name) ->
            "Hello, #{name}."

      response = await fetch 'http://localhost:8090', method: 'OPTIONS'
      expect(response.status).toBe 200
      expect(response.headers.get 'Access-Control-Allow-Methods').toBe 'GET, POST, OPTIONS'
      expect(response.headers.get 'Access-Control-Allow-Headers').toBe 'Authorization, Content-Type, Content-Length'
      expect(response.headers.get 'Access-Control-Max-Age').toBe '80000'

    it 'allows to restrict the origin', ->
      @server = await StartServer
        CORS:
          Origins: [
            'https://allowed.origin'
          ]
        functions:
          Hello: (name) ->
            "Hello, #{name}."

      response = await fetch 'http://localhost:8090',
        method: 'POST'
        headers:
          'Content-Type': 'application/json'
          'Origin': 'https://not.allowed'
        body: JSON.stringify
          fn: 'Hello'
          in: 'A'
      expect(response.status).toBe 400

      response = await fetch 'http://localhost:8090',
        method: 'POST'
        headers:
          'Content-Type': 'application/json'
          'Origin': 'https://allowed.origin'
        body: JSON.stringify
          fn: 'Hello'
          in: 'A'
      expect(response.status).toBe 200

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
