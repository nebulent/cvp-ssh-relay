https        = require 'https'
fs	     = require 'fs'
connect      = require 'connect'
path         = require 'path'
route        = require './lib/simple_route'
tokenStore   = require './lib/token_store'
ttyServer    = require './lib/tty_server'

options = {
    key:    fs.readFileSync('../server.key'),
    cert:   fs.readFileSync('../server.crt'),
    requestCert:        true,
    rejectUnauthorized: false
}

UPLOAD_PATH = path.join(process.cwd(), 'certs')
PORT = 8080

tokenHandler = (req, res, next)->
  console.log req.files
  token = tokenStore.put(req.body, req.files)
  res.end(token)

welcome = (req, res, next)->
  res.end 'The server is online.'


tokenWare = route.post '/token', tokenHandler
welcomeWare = route.get '/', welcome
bodyWare = connect.bodyParser({
  uploadDir: UPLOAD_PATH
})


app = connect()
  .use(connect.logger('dev'))
  .use(bodyWare)
  .use(welcomeWare)
  .use(tokenWare)

server = https.createServer(options, app)
server.listen(PORT)
ttyServer.listen(server, tokenStore)
console.log "listening on port #{PORT}"
