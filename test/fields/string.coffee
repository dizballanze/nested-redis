###
Nested Redis
String field test cases
###


describe "StringField", ->
  StringField = require '../../lib/fields/string'
  redis = require "redis-mock"

  describe "#set()", ->

    field = null
    client = null
    beforeEach ->
      client = redis.createClient()
      field = new StringField client, "test", "str"

    it "should set value to the right key", (done)->
      field.set "some value", (err)->
        client.exists "test:str", (err, exists)->
          exists.should.be.equal 1
          done()

    it "should set right value", (done)->
      test_val = "some value"
      field.set test_val, (err)->
        client.get field._getKeyName(), (err, value)->
          value.should.be.equal test_val
          done()

  describe "#get()", ->
    
    client = null
    test_key = "test:value"
    test_val = "something"
    before (done)->
      client = redis.createClient()
      client.set test_key, test_val, done

    it "should get right value", (done)->
      field = new StringField client, "test", "value"
      field.get (err, value)->
        value.should.be.equal test_val
        done()

    it "should return default value on empty if corresponding param is specified", (done)->
      field = new StringField client, "test", "unsetted", 
        default: "default value"

      field.get (err, value)->
        value.should.be.equal "default value"
        done()