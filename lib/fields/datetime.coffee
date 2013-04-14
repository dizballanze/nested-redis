###
Nested Redis datetime field
###
StringField = require './string'


class DatetimeField extends StringField

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
      cb null, new Date(timestamp)

  set: (value, cb)->
    str_val = value.valueOf() + ""
    super str_val, cb

exports = module.exports = DatetimeField