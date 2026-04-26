{ randomUUID } = require 'crypto'
{ mkdir } = IO.sync

exports.CreateTmpDirectory = ->
  name = "hobby-rpc.test.#{process.pid}.#{randomUUID()}"
  path = "/tmp/#{name}"
  mkdir path
  path
