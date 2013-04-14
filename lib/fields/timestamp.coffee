###
Nested Redis timestamp field
###
StringField = require './string'


class TimestampField extends StringField

  ###
  Default values of accepted parameters
  TODO: implement validations
  ###
  @params = 
    default: null

  get: (cb)->
    super (err, value)=>
      if err
        cb err
        return

      timestamp = parseInt value
      timestamp = null if timestamp == NaN
      cb null, timestamp

  set: (value, cb)->
    str_val = value.valueOf() + ""
    super str_val, cb

exports = module.exports = TimestampField