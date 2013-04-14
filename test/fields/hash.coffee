###
Nested redis ORM
Hash field test
###


describe "HashField", ->
  HashField = require '../../lib/fields/hash'
  redis = require "redis-mock"

  describe "#set()", ->

    field = null
    client = null
    beforeEach ->
      client = redis.createClient()
      client.flushdb()
      field = new HashField client, "test", "str"

    afterEach ->
      client.flushdb()

    it "should set value to the right key", (done)->
      field.set {"test": "123"}, (err)->
        client.exists field._getKeyName(), (err, exist)->
          exist.should.be.equal 1
          done()

    it "should set right value", (done)->
      hash = "a": "123", "b": "321"
      field.set hash, (err)->
        client.hgetall field._getKeyName(), (err, getted_hash)->
          getted_hash.should.have.keys "a", "b"
          getted_hash.should.have.property "a", "123"
          getted_hash.should.have.property "b", "321"
          done()

  describe "#get()", ->
    
    client = null
    test_key = "test:value"
    test_val = "a": "123", "b": "321"
    before (done)->
      client = redis.createClient()
      client.hmset test_key, test_val, done

    it "should get right value", (done)->
      field = new HashField client, "test", "value"
      field.get (err, value)->
        value.should.have.keys "a", "b"
        value.should.have.property "a", "123"
        value.should.have.property "b", "321"
        done()