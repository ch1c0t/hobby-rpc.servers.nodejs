# Introduction

It is to create [Hobby-RPC][protocol] servers with Node.js. To install: `npm i hobby-rpc.server`.

[protocol]: https://github.com/ch1c0t/hobby-rpc.protocol

# Usage

Either require or import:

```coffee
{ Server } = require 'hobby-rpc.server'
```

```coffee
import { Server } from 'hobby-rpc.server'
```

`Server` is a function which returns [an `http.Server`][http.Server].
It takes an object which must have the `functions` property.
Functions can return any object serializable with [`JSON.stringify`][JSON.stringify].

Here is a simple server providing `SomeNullaryFunction` and `SomeUnaryFunction`:

```coffee
server = Server
  functions:
    SomeNullaryFunction: ->
      'A string returned from SomeNullaryFunction.'
    SomeUnaryFunction: (input) ->
      "A string returned from SomeUnaryFunction with #{input}."
```

To start a server, you can use [`server.listen()`][server.listen]:

```coffee
server.listen 8080
```

[JSON.stringify]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify
[http.Server]: https://nodejs.org/api/http.html#class-httpserver
[server.listen]: https://nodejs.org/api/http.html#serverlisten

## CORS headers

By default, it will return permissive CORS headers(`Access-Control-Allow-Origin: *`) for requests from any origin. For private APIs, you might want to restrict that:

```coffee
server = Server
  CORS:
    Origins: ['https://some.domain', 'https://another.domain']
  functions:
    SomeNullaryFunction: ->
      'A string returned from SomeNullaryFunction.'
    SomeUnaryFunction: (input) ->
      "A string returned from SomeUnaryFunction with #{input}."
```

You can also override the default values as follows:

```coffee
server = Server
  CORS:
    Methods: 'POST, OPTIONS'
    Headers: 'Authorization, Content-Type'
    MaxAge: '86400'
  functions:
    SomeNullaryFunction: ->
      'A string returned from SomeNullaryFunction.'
    SomeUnaryFunction: (input) ->
      "A string returned from SomeUnaryFunction with #{input}."
```

## Authorization

By default, any client is allowed to call the functions.
For public APIs, you will probably want to restrict that.

To do so, pass `FindUser` as follows:

```coffee
server = Server
  FindUser: (token) ->
    if token is 'TheOnlyValidToken'
      name: 'A'
  functions:
    SomeNullaryFunction: ->
      "Hello, #{@user.name}."
```

`FindUser` should be a function that takes one argument, a String `token`.
`token` is what clients are supposed to pass in [the Authorization header][Authorization].

If `FindUser` returns one of these:

- a falsy value;
- a rejected Promise;
- a Promise resolved to a falsy value;

or throws an error, the server responds with [403 Forbidden][Forbidden].

If `FindUser` returns something else, the server will assume it is something that represents the current user. It will be available inside of the function as `@user`. Or, if it is a Promise, `@user` is the value resolved from this Promise.

[Authorization]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Authorization
[Forbidden]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/403
