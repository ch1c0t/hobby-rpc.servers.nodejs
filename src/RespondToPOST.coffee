{ BadRequest } = require './BadRequest'

exports.RespondToPOST = ({ response, request, functions, user }) ->
  ContentType = request.headers['content-type'] ? 'missing'
  unless ContentType.startsWith? 'application/json'
    error = "The content type is #{ContentType}, but application/json was expected."
    BadRequest { response, error }

  data = ''
  request.on 'data', (chunk) ->
    data += chunk
  request.on 'end', ->
    try
      message = JSON.parse data

      if fn = functions[message.fn]
        output = fn.call { user }, message.in
        response.setHeader 'Content-Type', 'application/json'
        response.statusCode = 200
        response.end JSON.stringify output
      else
        error = "No function named #{message.fn}."
        BadRequest { response, error }

    catch error
      BadRequest { response, error }
