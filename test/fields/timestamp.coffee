###
Nested Redis
Timestamp field test cases
###


describe "TimestampField", ->
  TimestampField = require '../../lib/fields/timestamp'
  redis = require "redis-mock"

  describe "#set()", ->

    field = null
    client = null
    beforeEach ->
      client = redis.createClient()
      field = new TimestampField client, "test", "str"

    it "should set right value from Date object", (done)->
      test_val = new Date 1364512414258
      field.set test_val, (err)->
        client.get field._getKeyName(), (err, value)->
          value.should.be.equal "1364512414258"
          done()

    it "should set right value from timestamp", (done)->
      test_val = 1364512414258
      field.set test_val, (err)->
        client.get field._getKeyName(), (err, value)->
          value.should.be.equal "1364512414258"
          done()

  describe "#get()", ->
    
    client = null
    test_key = "test:value"
    test_val = new Date 1364512414258
    before (done)->
      client = redis.createClient()
      client.set test_key, "1364512414258", done

    it "should get right value", (done)->
      field = new TimestampField client, "test", "value"
      field.get (err, value)->
        value.should.not.be.instanceOf Date
        value.should.be.equal test_val.valueOf()
        done()