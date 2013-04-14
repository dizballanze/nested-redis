###
Nested Redis Model
###

StringField = require "./fields/string"
IntField = require "./fields/int"
FloatField = require "./fields/float"
BoolField = require "./fields/bool"
DatetimeField = require "./fields/datetime"
TimestampField = require "./fields/timestamp"
HashField = require "./fields/hash"
NestedField = require "./fields/nested"
NestedListField = require "./fields/nestedlist"
async = require "async"
hat = require "hat"
_ = require 'lodash'


class Model

  @connector = require './connector'

  @client = ->
    if not @connector.getClient()
      throw new Error 'Redis client was not setted'
    @connector.getClient()

  ## Fields ##
  str: (name, params)=>
    field = new StringField Model.client(), @_getPrefix(), name, params
    @_setField name, field

  int: (name, params)=>
    field = new IntField Model.client(), @_getPrefix(), name, params
    @_setField name, field

  float: (name, params)=>
    field = new FloatField Model.client(), @_getPrefix(), name, params
    @_setField name, field

  bool: (name, params)=>
    field = new BoolField Model.client(), @_getPrefix(), name, params
    @_setField name, field

  datetime: (name, params)=>
    field = new DatetimeField Model.client(), @_getPrefix(), name, params
    @_setField name, field

  timestamp: (name, params)=>
    field = new TimestampField Model.client(), @_getPrefix(), name, params
    @_setField name, field

  hash: (name, params)=>
    field = new HashField Model.client(), @_getPrefix(), name, params
    @_setField name, field

  nested: (name, params)=>
    if typeof name == 'string'
      field = new NestedField Model.client(), @_getPrefix(), name, params
    else if (typeof name == 'object') and (name instanceof Array)
      name = name[0]
      field = new NestedListField Model.client(), @_getPrefix(), name, params
    @_setField name, field

  ## Service methods ##
  _setField: (name, field)->
    if @.hasOwnProperty name
      throw new Error "Wrong property name '#{name}'. Cant override built in model properties."
    @[name] = field
    @field_names.push name
    @fields.push field

  _getPrefix: ->
    return @prefix unless @id
    return [@prefix, @id].join ":"

  # Model constructor
  # TODO: add redis connection check
  constructor: (@id=null, @prefix=null, uuid=false)->
    if not @prefix?
      @prefix = @constructor.name.toLowerCase()
    if not @id? and uuid
      @setUUID()
    if not @fields and @properties?
      @fields = []
      @field_names = []
      @properties()

  # Return all model fields (including embeded)
  getAll: (fields, cb)->
    # TODO: Add tests for this one
    if typeof fields == "function"
      cb = fields
      ret_fields = @fields
    else
      ret_fields = []
      for field in fields
        ret_fields.push @[field]

    async.map ret_fields, (field, callback)->
      field.get (err, data)->
        callback err if err
        callback null, [field.name, data]
    , (err, data)->
      cb err if err
      ret = {}
      for [key, value] in data
        ret[key] = value
      cb null, ret

  # Set value of all model fields
  setAll: (data, cb)->
    async.each _.pairs(data), (field_data, callback)=>
      [key, val] = field_data
      if key of @
        @[key].set val, callback
    , cb

  # Delete value of all model fields
  deleteAll: (cb)->
    async.forEach @fields, (field, callback)->
      field.del callback
    , cb

  # Set uuid as model id
  setUUID: ->
    @id = hat()

exports = module.exports = Model