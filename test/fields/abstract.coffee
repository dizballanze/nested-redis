###
Nested Redis
Abstract field test cases
###


describe "Field", ->
  Field = require '../../lib/fields/abstract'
  redis = require "redis-mock"
  client = redis.createClient()

  class TestField extends Field
    @params = 
      test_param: 'test'
    constructor: (@redis, @prefix, @name, params)->
      if params?
        @_mergeParams params

  describe "#constructor()", ->

    it "should raise exception on creating instance if abstract field", ->
      (->
        instance = new Field()
      ).should.throw 'You cant create instance of abstract field'

  describe "#_getKeyName()", ->

    it "should return right key", ->
      [prefix, name] = ['prefix', 'name']
      field_name = "#{prefix}:#{name}"
      field = new TestField null, prefix, name
      field_name.should.be.equal field._getKeyName()

  describe "#del()", ->

    it "should delete key", (done)->
      [prefix, name, value] = ['prefix', 'name', 'something']
      field = new TestField client, prefix, name
      client.set field._getKeyName(), value, (err)->
        field.del ->
          client.exists field._getKeyName(), (err, exists)->
            exists.should.be.equal 0
            done()

  describe "#_mergeParams()", ->

    it "should correct merge default params with specified", ->
      field = new TestField client, 'some:prefix', 'some_name', test_param: 'overridden'
      field.params.test_param.should.be.equal 'overridden'