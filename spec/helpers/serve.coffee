{ mkdir } = IO.sync

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
