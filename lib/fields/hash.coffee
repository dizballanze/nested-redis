"""
Nested Redis string field
"""
Field = require './abstract'


class HashField extends Field

  ###
  Default values of accepted parameters
  TODO: implement validations
  ###
  @params = 
    required: yes

  constructor: (@redis, @prefix, @name, params={})->
    @_mergeParams params

  set: (value, cb)->
    @redis.hmset @_getKeyName(), value, cb

  get: (cb)->
    @redis.hgetall @_getKeyName(), cb

exports = module.exports = HashField