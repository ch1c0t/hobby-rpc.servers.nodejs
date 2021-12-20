{ Server } = require 'hobby-rpc.server'

StartServer = (params) ->
  server = Server params

  new Promise (resolve) ->
    server.listen 8090, ->
      resolve server

StopServer = (server) ->
  server.close()

  new Promise (resolve) ->
    server.on 'close', ->
      resolve()

module.exports = { StartServer, StopServer }
