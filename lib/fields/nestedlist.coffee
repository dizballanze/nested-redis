###
Nested field
Represent embed model and set of models
###
Field = require './abstract'
async = require 'async'


class NestedListField extends Field

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
      throw new Error 'Need to specify nestedset field model constructor.'
    @counter_key = "#{@prefix}:#{@name}:counter"

  get: (cb)->
    @redis.get @counter_key, (err, count)=>
      console.error err if err
      count = parseInt count
      if not count
        cb null, {}
        return

      async.map [0...count], (index, callback)=>
        instance = new @params.model null, "#{@prefix}:#{@name}:#{index}"
        instance.getAll callback
      , (err, arr)=>
        if err
          cb err
        else
          cb null, arr



  set: (value, cb)->
    # if value not instanceof Array
    #   throw new Error 'Wrong argument `value`. Need to be an array.'
    @redis.get @counter_key, (err, count)=>
      count = parseInt count
      
      @del =>
        async.forEach [0...value.length], (index, callback_map)=>
          instance = new @params.model null, "#{@prefix}:#{@name}:#{index}"
          instance.setAll value[index], callback_map
        , (err)=>
          cb err if err
          @redis.set @counter_key, value.length, cb
        
  add: (value, cb)->
    @redis.get @counter_key, (err, count)=>
      count = parseInt count
      count = 0 unless count

      instance = new @params.model null, "#{@prefix}:#{@name}:#{count}"
      instance.setAll value, (err)=>
        if err
          cb err
          return

        count++
        @redis.set @counter_key, count, (err)->
          if err
            cb err
            return
          cb null, count

  del: (cb)->
    @redis.get @counter_key, (err, count)=>
      if err
        cb err
        return

      count = parseInt count
      if not count
        cb null
        return

      async.parallel [
        (callback)=>
          @redis.del @counter_key, callback

        (callback)=>
          async.map [0...count], (index, callback_map)=>
            instance = new @params.model null, "#{@prefix}:#{@name}:#{index}"
            instance.deleteAll callback_map
          , callback
      ], cb

  getModelByIndex: (index)->
    instance = new @params.model null, "#{@prefix}:#{@name}:#{index}"

exports = module.exports = NestedListField