{ Server } = require 'hobby-rpc.server'

StartServer = (params) ->
  port = params.port ? 8090
  delete params.port

  server = Server params

  new Promise (resolve) ->
    server.listen port, ->
      resolve server

StopServer = (server) ->
  server.close()

  new Promise (resolve) ->
    server.on 'close', ->
      resolve()

module.exports = { StartServer, StopServer }
