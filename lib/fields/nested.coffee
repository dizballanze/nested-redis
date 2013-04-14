###
Nested field
Represent embed model and set of models
###
Field = require './abstract'


class NestedField extends Field

  ###
  Default values of accepted parameters
  TODO: implement validations
  ###
  @params = 
    required: yes
    model: null
  
  constructor: (@redis, @prefix, @name, params={})->
    @_mergeParams params
    if not @params.model?
      throw new Error 'Need to specify nested field model constructor'
    @instance = new @params.model null, "#{@prefix}:#{@name}"

  get: (cb)->
    @instance.getAll cb

  set: (value, cb)->
    @instance.setAll value, cb

  del: (cb)->
    @instance.deleteAll cb

exports = module.exports = NestedField