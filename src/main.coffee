http = require 'http'

{ BadRequest } = require './BadRequest'
{ RespondToOPTIONS } = require './RespondToOPTIONS'
{ RespondToPOST } = require './RespondToPOST'
{ VerifyToken } = require './VerifyToken'
{ OriginIsValid } = require './OriginIsValid'

exports.Server = ({ functions, FindUser, CORS }) ->
  http.createServer (request, response) ->
    try
      { method } = request
      unless method in ['POST', 'OPTIONS']
        error = "The request.method is #{method}, but only POST and OPTIONS are allowed."
        BadRequest { response, error }

      if typeof FindUser is 'function'
        user = await VerifyToken { response, request, FindUser }
        return unless user

      return unless OriginIsValid { response, request, CORS }

      switch method
        when 'OPTIONS'
          RespondToOPTIONS { response, CORS }
        when 'POST'
          RespondToPOST { response, request, functions, user }

    catch error
      BadRequest { response, error }
