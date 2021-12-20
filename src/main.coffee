http = require 'http'

exports.Server = ({ functions }) ->
  http.createServer (request, response) ->
    try
      { method } = request
      unless method in ['POST', 'OPTIONS']
        error = "The request.method is #{method}, but only POST and OPTIONS are allowed."
        BadRequest { response, error }

      response.setHeader 'Access-Control-Allow-Origin', '*'

      switch method
        when 'OPTIONS'
          response.setHeader 'Access-Control-Allow-Methods', 'POST, OPTIONS'
          response.setHeader 'Access-Control-Allow-Headers', 'Authorization, Content-Type'
          response.setHeader 'Access-Control-Max-Age', '86400'
          response.end()
        when 'POST'
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
                output = if message.in?
                  fn message.in
                else
                  fn()

                response.setHeader 'Content-Type', 'application/json'
                response.statusCode = 200
                response.end JSON.stringify output
              else
                error = "No function named #{message.fn}."
                BadRequest { response, error }

            catch error
              BadRequest { response, error }

    catch error
      BadRequest { response, error }

BadRequest = ({ response, error }) ->
  console.error error
  response.statusCode = 400
  response.end()
