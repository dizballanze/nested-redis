###
Nested Redis bool field
###
StringField = require './string'


class BoolField extends StringField

  ###
  Default values of accepted parameters
  TODO: implement validations
  ###
  @params = 
    default: null

  set: (value, cb)->
    value = !!value
    str_value = if value then "T" else ""
    super str_value, cb

  get: (cb)->
    super (err, value)=>
      if err
        cb err
        return

      bool_val = !!value
      cb null, bool_val

exports = module.exports = BoolField