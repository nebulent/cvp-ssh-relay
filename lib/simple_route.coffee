buildHelper = (method)->
  (url, fn)->
    (req, res, next)->
      if req.method is method and req.url is url
        fn(req, res, next)
      else
        next()

get  = buildHelper 'GET'
post = buildHelper 'POST'

module.exports = {
  get: get,
  post: post
}
