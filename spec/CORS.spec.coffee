  describe 'CORS2', ->
    it 'sets default CORS headers', ->
      await serve """
        functions:
          Hello: (name) ->
            "Hello, \#{name}."
      """, @

      response = await fetch @url, method: 'OPTIONS'
      expect(response.status).toBe 200
      expect(response.headers.get 'Access-Control-Allow-Methods').toBe 'POST, OPTIONS'
      expect(response.headers.get 'Access-Control-Allow-Headers').toBe 'Authorization, Content-Type'
      expect(response.headers.get 'Access-Control-Max-Age').toBe '86400'

      response = await fetch @url,
        method: 'POST'
        headers:
          'Content-Type': 'application/json'
        body: JSON.stringify
          fn: 'Hello'
          in: 'A'

      expect(response.status).toBe 200
      expect(response.headers.get 'Access-Control-Allow-Origin').toBe '*'

      string = await response.json()
      expect(string).toBe 'Hello, A.'

    it 'allows to pass custom CORS headers', ->
      await serve """
        CORS:
          Methods: 'GET, POST, OPTIONS'
          Headers: 'Authorization, Content-Type, Content-Length'
          MaxAge: '80000'
        functions:
          Hello: (name) ->
            "Hello, \#{name}."
      """, @

      response = await fetch @url, method: 'OPTIONS'
      expect(response.status).toBe 200
      expect(response.headers.get 'Access-Control-Allow-Methods').toBe 'GET, POST, OPTIONS'
      expect(response.headers.get 'Access-Control-Allow-Headers').toBe 'Authorization, Content-Type, Content-Length'
      expect(response.headers.get 'Access-Control-Max-Age').toBe '80000'

    it 'allows to restrict the origin', ->
      await serve """
        CORS:
          Origins: [
            'https://allowed.origin'
          ]
        functions:
          Hello: (name) ->
            "Hello, \#{name}."
      """, @

      response = await fetch @url,
        method: 'POST'
        headers:
          'Content-Type': 'application/json'
          'Origin': 'https://not.allowed'
        body: JSON.stringify
          fn: 'Hello'
          in: 'A'
      expect(response.status).toBe 400

      response = await fetch @url,
        method: 'POST'
        headers:
          'Content-Type': 'application/json'
          'Origin': 'https://allowed.origin'
        body: JSON.stringify
          fn: 'Hello'
          in: 'A'
      expect(response.status).toBe 200

      string = await response.json()
      expect(string).toBe 'Hello, A.'
