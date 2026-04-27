{ write } = IO.sync
{ compile } = require 'coffeescript'

global.CreateServerFile = ({ path, code }) ->
  js_code = compile """
    { Server } = require '#{process.cwd()}'

    server = Server
    #{code.indent()}

    server.listen 0, '127.0.0.1', ->
      process.send
        pid: process.pid
        port: server.address().port
        host: server.address().address
  """
  write path, js_code
