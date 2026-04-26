String::lines = ->
  @split "\n"

String::indent = (n = 2) ->
  lines =
    for line in @lines()
      space = ' '.repeat n
      space + line
  lines.join "\n"

{ mkdir, write } = IO.sync
{ compile } = require 'coffeescript'
CreateServerFile = ({ path, code }) ->
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

{ randomUUID } = require 'crypto'
global.serve = (code, example) ->
  dir = "#{TE.dir}/servers"
  mkdir dir

  server_file = "#{dir}/#{randomUUID()}.js"
  CreateServerFile
    path: server_file
    code: code

  server = await Task
    run: server_file
    inside_of: dir
  AtExit -> server.stop()
  TE.tasks.push server
  example.server = server

  { host, port } = server.data
  url = "http://#{host}:#{port}"
  example.url = url
