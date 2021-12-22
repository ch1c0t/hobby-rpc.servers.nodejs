exports.RespondToOPTIONS = ({ response }) ->
  response.setHeader 'Access-Control-Allow-Methods', 'POST, OPTIONS'
  response.setHeader 'Access-Control-Allow-Headers', 'Authorization, Content-Type'
  response.setHeader 'Access-Control-Max-Age', '86400'
  response.end()
