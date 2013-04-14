###
Nested Redis
Nested field test cases
###


describe "NestedField", ->
  async = require "async"
  NestedField = require '../../lib/fields/nested'
  Model = require '../../lib/model'
  Connector = require '../../lib/connector'
  redis = require "redis-mock"
  client = redis.createClient()

  class Person extends Model
    properties: ->
      @str 'first_name'
      @str 'last_name'

  describe "#set()", ->

    beforeEach: ->
      client.flushdb()

    it "should set value to the right key", (done)->
      Connector.setClient client
      field = new NestedField client, 'customer:1', 'person', model: Person
      field.set 
        first_name: "John"
        last_name: "Smith"
      , (err)->
        async.parallel [
          (cb)->
            client.get 'customer:1:person:first_name', (err, first_name)->
              first_name.should.be.equal "John"
              cb()

          (cb)->
            client.get 'customer:1:person:last_name', (err, last_name)->
              last_name.should.be.equal "Smith"
              cb()
        ], ->
          done()


  describe "#get()", ->

    beforeEach: ->
      client.flushdb()

    it "should fetch right value", (done)->
      Connector.setClient client
      async.parallel [
        (cb)->
          client.set 'customer:1:person:first_name', 'First'
          cb()

        (cb)->
          client.set 'customer:1:person:last_name', 'Last'
          cb()

      ], ->
        field = new NestedField client, 'customer:1', 'person', model: Person
        field.get (err, data)->
          data.should.have.keys 'first_name', 'last_name'
          data.first_name.should.be.equal 'First'
          data.last_name.should.be.equal 'Last'
          done()
  describe "#del()", ->

    beforeEach: ->
      client.flushdb()

    it "should delete all nested instance fields", (done)->
      Connector.setClient client
      async.parallel [
        (cb)->
          client.set 'customer:1:person:first_name', 'First'
          cb()

        (cb)->
          client.set 'customer:1:person:last_name', 'Last'
          cb()

      ], ->
        field = new NestedField client, 'customer:1', 'person', model: Person
        field.del ->
          async.parallel [
            (cb)->
              client.exists 'customer:1:person:first_name', (err, exist)->
                exist.should.be.equal 0
                cb()

            (cb)->
              client.exists 'customer:1:person:last_name', (err, exist)->
                exist.should.be.equal 0
                cb()
          ], done