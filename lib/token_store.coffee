crypto = require 'crypto'
clone  = require './clone'
hash   = require './hash'

class TokenStore
  constructor: (@expire=60000)->
    @store  = {}

  put: (data)->
    token = hash JSON.stringify(data)
    @store[token] = data

    expireWrap = ()=> @expire(token)
    setInterval expireWrap, @expire
    token

  get: (token)->
    if @store[token] isnt null
      expire token
    else
      null

  expire: (token)->
    data = clone @store[token]
    delete @store[token]
    data


module.exports = new TokenStore()
