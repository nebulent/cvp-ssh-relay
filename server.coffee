http         = require 'http'
connect      = require 'connect'
route        = require './lib/simple_route'
tokenStore   = require './lib/token_store'
ttyServer    = require './lib/tty_server'


tokenHandler = (req, res, next)->
  token = tokenStore.put(req.body)
  res.end(token)
tokenWare = route.post '/token', tokenHandler

welcome = (req, res, next)->
  res.end 'CVP SSH RELAY.'
welcomeWare = route.get '/', welcome

app = connect()
  .use(connect.logger('dev'))
  .use(connect.bodyParser())
  .use(welcomeWare)
  .use(tokenWare)

server = http.createServer(app)
server.listen(8080)
ttyServer.listen(server, tokenStore)
