SSH = require 'ssh2'
io = require 'socket.io'
fs = require 'fs'

ssh = new SSH()

ssh.on 'connect', ->
  console.log 'connected!'


processCommand = (err,stream)->
  throw err if err
  stream.on 'data', (data, ext)->
    console.log data.toString()

  stream.on 'exit', (code,signal)->
    console.log 'exit', code, signal
    ssh.end()

executeCommand = (cmd)->
  ssh.exec 'uptime', processCommand

sessionHandler = ->
  console.log 'running session!'
  executeCommand 'uptime'

ssh.on 'ready', sessionHandler
ssh.on 'error', ->
  console.log 'opasnoste!'

ssh.on 'end', ->
  console.log 'connection end'

ssh.on 'close', ->
  console.log 'connection close'


ssh.connect({
  host: '192.168.88.86',
  port: 22,
  username: 'ivaaan',
  password: 'supervanea'
})
