SSHClient = require './ssh_client'
io = require 'socket.io'

ws = io.listen(8001)
ws.set 'log level', 1


ws.sockets.on 'connection', (socket)->
  client = null

  socket.on 'init', (ssh_data)->
    client = new SSHClient(ssh_data)
    client.on 'ready', -> socket.emit 'ssh_ready'

  socket.on 'cmd', (cmd)->
    if client is null
      socket.emit 'cmd_result', {cmd: cmd, error: 'You need to initiate a connection first'}
    else
      client.execute cmd, (output)->
        socket.emit 'cmd_result', {cmd: cmd, result: output.toString()}

  socket.on 'disconnect', ->
    client.disconnect() unless client is null
