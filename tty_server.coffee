io = require 'socket.io'
pty = require 'pty.js'

ws = io.listen(8001)
ws.set 'log level', 1

validCredentials = (credentials)->
    return false unless credentials
    user = credentials.user
    host = credentials.host
    port = credentials.port
    return false unless (user and host and port)
    true

sshOptions = (user, host, port)->
  [
    "#{user}@#{host}",
    "-p #{port}",
    "-o 'UserKnownHostsFile /dev/null'",
    "-o 'StrictHostKeyChecking no'"
  ]

ws.sockets.on 'connection', (socket)->
  term = null

  socket.on 'tty_connect', (credentials)->
    console.log 'forking tty...'

    return unless validCredentials(credentials)
    user = credentials.user
    host = credentials.host
    port = credentials.port

    term = pty.fork('ssh', sshOptions(user, host, port), {
      name: 'xterm',
      cols: 80,
      rows: 24,
      cwd: process.env.HOME
    })

    term.on 'data', (data)->
      socket.emit('data', data)

    console.log 'tty is ready!'
    socket.emit 'tty_ready'

  socket.on 'data', (data)->
    term?.write(data)

  socket.on 'disconnect', ->
    term?.destroy()
