exports.VerifyToken = ({ response, request, FindUser }) ->
  token = request.headers['authorization'] ? ''

  try
    user = FindUser token
    throw "no user for token #{token}" unless user

    if typeof user.then is 'function'
      user = await user
      throw "no user in Promise for token #{token}" unless user
      user
    else
      Promise.resolve user
  catch error
    console.error error
    response.statusCode = 403
    response.end()
    no
