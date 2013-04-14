###
Keep redis connection and
provide access to it from all models
###


class Connector
  redis = null

  @setClient: (client)->
    redis = client

  @getClient: ->
    return redis

exports = module.exports = Connector