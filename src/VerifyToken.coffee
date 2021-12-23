exports.VerifyToken = ({ response, request, FindUser }) ->
  token = request.headers['authorization'] ? ''

  try
    user = FindUser token
    throw "no user for token #{token}" unless user
    user
  catch error
    console.error error
    response.statusCode = 403
    response.end()
    no
