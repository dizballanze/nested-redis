###
Nested Redis string field
###
Field = require './abstract'


class StringField extends Field

  ###
  Default values of accepted parameters
  TODO: implement validations
  ###
  @params = 
    min_length: no
    max_length: no
    required: yes
    default: null

  constructor: (@redis, @prefix, @name, params={})->
    @_mergeParams params

  get: (cb)->
    @redis.get @_getKeyName(), (err, value)=>
      if err
        cb err
        return

      if (value is null) and @params.default?
        cb null, @params.default
        return
      cb null, value

  set: (val, cb)->
    @redis.set @_getKeyName(), val, cb

exports = module.exports = StringField