SSH = require 'ssh2'

streamHandlerGenerator = (ssh, callback)->
  (err, stream)->
    throw err if err

    stream.on 'data', (data, ext)->
      callback(data)

    stream.on 'exit', (code,signal)->
      console.log 'exit', code, signal
      ssh.end()


class SSHClient
  constructor: (@opts)->
    @ssh = new SSH()
    @bindCallbacks()
    @ssh.connect(@opts)
    @ready = false
    @callbacks = {}

  emit: (evt, data)->
    return unless @callbacks[evt]
    cb(data) for cb in @callbacks[evt]

  on: (evt, cb)->
    @callbacks[evt] = [] unless @callbacks[evt]
    @callbacks[evt].push(cb)

  execute: (cmd, callback)->
    throw 'connection is not ready' unless @ready
    @ssh.exec cmd, streamHandlerGenerator(@ssh, callback)

  disconnect: ->
    @ssh.end()

  bindCallbacks: ->
    self = this
    @ssh.on 'ready', ->
      self.ready = true
      self.emit 'ready'

    @ssh.on 'error', -> console.log 'opasnoste!'
    @ssh.on 'end', -> console.log 'connection end'
    @ssh.on 'close', -> console.log 'connection close'


module.exports = SSHClient
