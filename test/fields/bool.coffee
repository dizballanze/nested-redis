###
Nested Redis
Boolean field test cases
###


describe "BoolField", ->
  BoolField = require '../../lib/fields/bool'
  redis = require "redis-mock"

  describe "#set()", ->

    field = null
    client = null
    beforeEach ->
      client = redis.createClient()
      client.flushdb()
      field = new BoolField client, "test", "str"

    it "should set right value", (done)->
      test_val = true
      field.set test_val, (err)->
        client.get field._getKeyName(), (err, value)->
          value.should.be.equal "T"
          done()

  describe "#get()", ->
    
    client = null
    test_key = "test:value"
    test_val = false
    before (done)->
      client = redis.createClient()
      client.flushdb()
      client.set test_key, "", done

    it "should get right value", (done)->
      field = new BoolField client, "test", "value"
      field.get (err, value)->
        value.should.be.equal test_val
        done()