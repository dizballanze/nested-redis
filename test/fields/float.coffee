###
Nested Redis
Float field test cases
###


describe "FloatField", ->
  FloatField = require '../../lib/fields/float'
  redis = require "redis-mock"

  describe "#set()", ->

    field = null
    client = null
    beforeEach ->
      client = redis.createClient()
      field = new FloatField client, "test", "str"

    it "should set right value", (done)->
      test_val = 123.5
      field.set test_val, (err)->
        client.get field._getKeyName(), (err, value)->
          value.should.be.equal test_val + ""
          done()

  describe "#get()", ->
    
    client = null
    test_key = "test:value"
    test_val = 256.13
    before (done)->
      client = redis.createClient()
      client.set test_key, test_val, done

    it "should get right value", (done)->
      field = new FloatField client, "test", "value"
      field.get (err, value)->
        value.should.be.equal test_val
        done()