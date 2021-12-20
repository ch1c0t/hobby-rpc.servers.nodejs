{ StartServer, StopServer } = require './server.setup.coffee'

describe 'Server', ->
  beforeAll ->
    { RPC } = await import('hobby-rpc')
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
      promise = rpc 'SomeName', 'World'
      promise.catch (error) ->
        expect(error).toBe ''
