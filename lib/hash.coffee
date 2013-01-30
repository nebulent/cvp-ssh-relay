crypto = require 'crypto'

hash = (str)->
  sum = crypto.createHash('sha1')
  sum.update(str)
  sum.digest('hex')

module.exports = hash
