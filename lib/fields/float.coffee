###
Nested Redis float field
###
StringField = require './string'


class FloatField extends StringField

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

      float_val = parseFloat value
      cb null, float_val

exports = module.exports = FloatField