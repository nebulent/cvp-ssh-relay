http         = require 'http'
connect      = require 'connect'
route        = require './lib/simple_route'
tokenStore   = require './lib/token_store'
ttyServer    = require './lib/tty_server'
PORT = 8080

tokenHandler = (req, res, next)->
  token = tokenStore.put(req.body)
  res.end(token)
tokenWare = route.post '/token', tokenHandler

welcome = (req, res, next)->
  res.end 'The server is online.'
welcomeWare = route.get '/', welcome

app = connect()
  .use(connect.logger('dev'))
  .use(connect.bodyParser())
  .use(welcomeWare)
  .use(tokenWare)

server = http.createServer(app)
server.listen(PORT)
ttyServer.listen(server, tokenStore)
console.log "listening on port #{PORT}"
