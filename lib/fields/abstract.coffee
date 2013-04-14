###
Abstract field class
###
_ = require "lodash"


class Field

  ###
  Default values of accepted parameters
  TODO: implement validations
  ###
  @params = 
    required: yes
  
  constructor: (@redis, @prefix, @name, params)->
    throw new Error "You cant create instance of abstract field"

  get: (cb)->

  set: (value, cb)->

  del: (cb)->
    @redis.del @_getKeyName(), cb

  _getKeyName: ()->
    "#{@prefix}:#{@name}"

  _mergeParams: (params)->
    @params = _.merge _.cloneDeep(@.constructor.params), params


exports = module.exports = Field