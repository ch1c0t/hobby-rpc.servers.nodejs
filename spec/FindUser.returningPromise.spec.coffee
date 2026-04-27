{ RPC } = require 'hobby-rpc'

describe 'FindUser, when it returns a Promise,', ->
  it 'resolves a user Promise', ->
    await serve """
      functions:
        HelloName: ->
          "Hello, \#{@user.name}."
      FindUser: (token) ->
        if token is 'ValidToken'
          Promise.resolve name: 'ValidUser'
    """, @

    rpc = RPC
      url: @url
      token: 'ValidToken'

    output = await rpc 'HelloName'
    expect(output).toBe "Hello, ValidUser."

  it 'handles a rejected Promise as an authentication failure', ->
    await serve """
      functions:
        HelloName: ->
          "Hello, \#{@user.name}."
      FindUser: (token) ->
        Promise.reject()
    """, @

    rpc = RPC
      url: @url
      token: 'ValidToken'

    await expectAsync(rpc 'HelloName').toBeRejectedWith 403

  it 'handles a Promise resolved to a falsy value as an authentication failure', ->
    await serve """
      functions:
        HelloName: ->
          "Hello, \#{@user.name}."
      FindUser: (token) ->
        Promise.resolve false
    """, @

    rpc = RPC
      url: @url
      token: 'ValidToken'

    await expectAsync(rpc 'HelloName').toBeRejectedWith 403
