io = require 'socket.io'
pty = require 'pty.js'

validCredentials = (credentials)->
    return false unless credentials
    user = credentials.user
    host = credentials.host
    port = credentials.port
    password = credentials.credentials
    return false unless (user and host and port and password)
    true

sshOptions = (creds)->
  [
    "#{creds.user}@#{creds.host}",
    "-p #{creds.port}",
    "-o UserKnownHostsFile /tmp/cvp_known_hosts",
    "-o StrictHostKeyChecking no"
  ]

createTerminal = (ptyOptions)->
  pty.fork('ssh', ptyOptions, {
    name: 'xterm',
    cols: 80,
    rows: 24,
    cwd: process.env.HOME
  })

initSession = (tokenStore, token, error)->
  console.log 'New tty connection'

  credentials = tokenStore.get(token)
  unless credentials
    error('Invalid token')
    return

  unless validCredentials(credentials)
    error('Invalid credentials')
    return

  createTerminal sshOptions(credentials)

defineProtocol = (socket, tokenStore)->
  term = null
  error = (reason)->
    socket.emit 'tty_error', reason
    socket.disconnect()
    term?.destroy

  socket.on 'tty_connect', (token)->
    term = initSession(tokenStore, token, error)
    return unless term

    term.on 'data', (data)->
      socket.emit('data', data)

    console.log 'tty is ready!'
    socket.emit 'tty_ready'

  socket.on 'data', (data)->
    term?.write(data)

  socket.on 'disconnect', ->
    term?.destroy()

bindProtocol = (ws, tokenStore)->
  ws.sockets.on 'connection', (socket)->
    defineProtocol(socket, tokenStore)

module.exports = {
  listen: (server, tokenStore)->
    ws = io.listen(server)
    ws.set 'log level', 1
    bindProtocol(ws, tokenStore)
}
