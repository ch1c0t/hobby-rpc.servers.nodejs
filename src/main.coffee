http = require 'http'

{ BadRequest } = require './BadRequest'
{ RespondToOPTIONS } = require './RespondToOPTIONS'
{ RespondToPOST } = require './RespondToPOST'

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
          RespondToOPTIONS { response }
        when 'POST'
          RespondToPOST { response, request, functions }

    catch error
      BadRequest { response, error }
