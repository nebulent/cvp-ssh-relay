http         = require 'http'
connect      = require 'connect'
path         = require 'path'
route        = require './lib/simple_route'
tokenStore   = require './lib/token_store'
ttyServer    = require './lib/tty_server'

UPLOAD_PATH = path.join(process.cwd(), 'certs/')
PORT = 3031

tokenHandler = (req, res, next)->
  token = tokenStore.put(req.body)
  if req.files
    console.log 'Certificate found, adding to store'
    tokenStore.addCertificate(token, req.files)
  res.end(token)

welcome = (req, res, next)->
  res.end 'The server is online.'


tokenWare = route.post '/token', tokenHandler
welcomeWare = route.get '/', welcome
attachmentWare = connect.multipart({
  uploadDir: UPLOAD_PATH
  limit: 1024
})


app = connect()
  .use(connect.logger('dev'))
  .use(attachmentWare)
  .use(connect.bodyParser())
  .use(welcomeWare)
  .use(tokenWare)

server = http.createServer(app)
server.listen(PORT)
ttyServer.listen(server, tokenStore)
console.log "listening on port #{PORT}"
