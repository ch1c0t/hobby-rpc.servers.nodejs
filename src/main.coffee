http = require 'http'

{ BadRequest } = require './BadRequest'
{ RespondToOPTIONS } = require './RespondToOPTIONS'
{ RespondToPOST } = require './RespondToPOST'
{ VerifyToken } = require './VerifyToken'

exports.Server = ({ functions, FindUser }) ->
  http.createServer (request, response) ->
    try
      { method } = request
      unless method in ['POST', 'OPTIONS']
        error = "The request.method is #{method}, but only POST and OPTIONS are allowed."
        BadRequest { response, error }

      if typeof FindUser is 'function'
        user = VerifyToken { response, request, FindUser }
        return unless user

      response.setHeader 'Access-Control-Allow-Origin', '*'

      switch method
        when 'OPTIONS'
          RespondToOPTIONS { response }
        when 'POST'
          RespondToPOST { response, request, functions, user }

    catch error
      BadRequest { response, error }
