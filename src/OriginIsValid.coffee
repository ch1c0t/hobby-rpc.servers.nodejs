{ BadRequest } = require './BadRequest'

exports.OriginIsValid = ({ response, request, CORS }) ->
  if origins = CORS?.Origins 
    origin = request.headers['origin']

    if origin in origins
      response.setHeader 'Access-Control-Allow-Origin', origin
    else
      error = "The request origin #{origin} is not allowed."
      BadRequest { response, error }
      no
  else
    response.setHeader 'Access-Control-Allow-Origin', '*'
