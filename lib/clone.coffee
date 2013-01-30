clone = (obj)->
  return obj unless (obj is null or typeof obj is "object")

  if obj instanceof Date
    copy = new Date()
    copy.setTime(obj.getTime())
    return copy

  if obj instanceof Array
    return (clone(elem) for elem in obj)

  if obj instanceof Object
    copy = {}
    for k,v of obj
      copy[k] = clone(v)
    return copy

  throw new Error("Unable to copy obj! Its type isn't supported.")

module.exports = clone
