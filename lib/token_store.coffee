crypto = require 'crypto'
clone  = require 'clone'
hash   = require './hash'

class TokenStore
  constructor: (@expireTimeout=60000)->
    @store  = {}

  put: (data)->
    strData = JSON.stringify(data)
    token = hash strData
    @store[token] = data
    console.log "#{token} -> #{strData}"

    expireWrap = ()=> @expire(token)
    setTimeout expireWrap, @expireTimeout
    token

  get: (token)->
    if @store[token] isnt null
      @expire token
    else
      null

  expire: (token)->
    console.log "Expiring token #{token}"
    data = clone @store[token]
    delete @store[token]
    data


module.exports = new TokenStore()
