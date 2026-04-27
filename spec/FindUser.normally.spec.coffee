{ RPC } = require 'hobby-rpc'

describe 'FindUser normally', ->
  beforeEach ->
    await serve """
      functions:
        SomeFunction: -> 'output'
        HelloName: ->
          "Hello, \#{@user.name}."
      FindUser: (token) ->
        if token is 'ValidToken'
          name: 'ValidUser'
    """, @

  it 'returns the output when a valid token was passed', ->
    rpc = RPC
      url: @url
      token: 'ValidToken'

    output = await rpc 'SomeFunction'
    expect(output).toBe 'output'

  it 'fails when no token was passed', ->
    rpc = RPC url: @url
    await expectAsync(rpc 'SomeFunction').toBeRejectedWith 403

    Client = require('hobby-rpc.client').RPC
    rpc = Client url: @url
    await expectAsync(rpc 'SomeFunction').toBeRejectedWith 403

  it 'fails when an invalid token was passed', ->
    rpc = RPC
      url: @url
      token: 'InvalidToken'

    await expectAsync(rpc 'SomeFunction').toBeRejectedWith 403

  it 'provides access to a user', ->
    rpc = RPC
      url: @url
      token: 'ValidToken'

    output = await rpc 'HelloName'
    expect(output).toBe "Hello, ValidUser."
