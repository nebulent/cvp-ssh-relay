crypto = require 'crypto'
clone  = require 'clone'
fs     = require 'fs'
hash   = require './hash'

certificates = {
  map: {}
  add: (token, filepath)->
    @map[token] = filepath

  remove: (token)->
    if @map[token]
      fs.unlink @map[token]
      delete @map[token]

}


class TokenStore
  constructor: (@expireTimeout=60000)->
    @store  = {}

  strForm: (data)->
    new Date().toString() + data['host'] + data['protocol']

  put: (data)->
    token = hash @strForm(data)
    @store[token] = data

    expireWrap = ()=> @expire(token)
    setTimeout expireWrap, @expireTimeout
    token

  get: (token)->
    if @store[token] isnt null
      @expire token
    else
      null

  addCertificate: (token, files)->
    certificates.add(token, files.cert.path)

  expire: (token)->
    console.log "Expiring token #{token}"
    data = clone @store[token]
    delete @store[token]
    certificates.remove(token)
    data


module.exports = new TokenStore()
