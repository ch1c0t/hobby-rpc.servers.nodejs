exports.RespondToOPTIONS = ({ response, CORS }) ->
  response.setHeader 'Access-Control-Allow-Methods', (CORS?.Methods or 'POST, OPTIONS')
  response.setHeader 'Access-Control-Allow-Headers', (CORS?.Headers or 'Authorization, Content-Type')
  response.setHeader 'Access-Control-Max-Age', (CORS?.MaxAge or '86400')
  response.end()
