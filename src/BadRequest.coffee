exports.BadRequest = ({ response, error }) ->
  console.error error
  response.statusCode = 400
  response.end()
