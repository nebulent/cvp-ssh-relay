SSHClient = require './ssh_client'
io = require 'socket.io'
fs = require 'fs'

client = new SSHClient({
  host: '192.168.88.86',
  port: 22,
  username: 'ivaaan',
  password: 'supervanea'
})

client.on 'ready', ->
  console.log 'client is ready'
  client.execute 'uptime', (output)->
    console.log output.toString()
