crypto = require 'crypto'
clone  = require 'clone'
fs     = require 'fs'
hash   = require './hash'

class TokenStore
  constructor: (@expireTimeout=60000)->
    @store  = {}

  strForm: (data)->
    new Date().toString() + data['host'] + data['protocol']

  put: (data, files)->
    token = hash @strForm(data)
    @store[token] = data

    if data.certificate_file_name
      @addCertificate token, files.cert.path

    expireWrap = ()=> @expire(token)
    setTimeout expireWrap, @expireTimeout
    token

  addCertificate: (token, path)->
    pem_name = path
    fs.chmodSync pem_name, 0o600
    @store[token].cert = pem_name

  get: (token)->
    if @store[token] isnt null
      @expire token
    else
      null

  expire: (token)->
    return unless @store[token]
    removeWrap = (file)=>
      ()-> fs.unlink(file)

    console.log "Expiring token #{token}"
    data = clone @store[token]

    if @store[token].cert
      setTimeout removeWrap(@store[token].cert), 15000

    delete @store[token]
    data


module.exports = new TokenStore()
