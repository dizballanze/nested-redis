###
Nested Redis
Int field test cases
###


describe "IntField", ->
  IntField = require '../../lib/fields/int'
  redis = require "redis-mock"

  describe "#set()", ->

    field = null
    client = null
    beforeEach ->
      client = redis.createClient()
      field = new IntField client, "test", "str"

    it "should set right value", (done)->
      test_val = 123
      field.set test_val, (err)->
        client.get field._getKeyName(), (err, value)->
          value.should.be.equal test_val + ""
          done()

  describe "#get()", ->
    
    client = null
    test_key = "test:value"
    test_val = 256
    before (done)->
      client = redis.createClient()
      client.set test_key, test_val, done

    it "should get right value", (done)->
      field = new IntField client, "test", "value"
      field.get (err, value)->
        value.should.be.equal test_val
        done()