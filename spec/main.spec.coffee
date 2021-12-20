{ StartServer, StopServer } = require './server.setup.coffee'

require 'isomorphic-fetch'
global.window = { fetch }

describe 'Server', ->
  beforeAll ->
    { RPC } = await import('hobby-rpc')
    global.rpc = RPC url: 'http://localhost:8090'

  it 'works', ->
    @server = await StartServer
      functions:
        Hello: (name) ->
          "Hello, #{name}."

    output = await rpc 'Hello', 'World'
    expect(output).toBe 'Hello, World.'

  afterEach ->
    await StopServer @server
