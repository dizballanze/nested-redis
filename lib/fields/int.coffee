###
Nested Redis int field
###
StringField = require './string'


class IntField extends StringField

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

      int_val = parseInt value
      cb null, int_val

exports = module.exports = IntField