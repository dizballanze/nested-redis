###
Nested Redis
NestedList field test cases
###


describe "NestedListField", ->
  async = require "async"
  NestedListField = require '../../lib/fields/nestedlist'
  Model = require '../../lib/model'
  Connector = require '../../lib/connector'
  redis = require "redis-mock"
  client = redis.createClient()

  class Person extends Model
    properties: ->
      @str 'first_name'
      @str 'last_name'

  person1 = 
    first_name: "John"
    last_name: "Mclein"

  person2 = 
    first_name: "Brad"
    last_name: "Pitt"

  describe "#get()", ->

    beforeEach ->
      client.flushdb()

    it "should return right data", (done)->
      Connector.setClient client
      field = new NestedListField client, "company:1", "staff", model: Person
      async.parallel [
        (cb)->
          client.set "company:1:staff:counter", "2", cb

        (cb)->
          client.set "company:1:staff:0:first_name", person1.first_name, cb

        (cb)->
          client.set "company:1:staff:0:last_name", person1.last_name, cb

        (cb)->
          client.set "company:1:staff:1:first_name", person2.first_name, cb

        (cb)->
          client.set "company:1:staff:1:last_name", person2.last_name, cb
      ], ->
        field.get (err, data)->
          data.should.be.an.instanceof Array
          data.should.have.length 2

          person1 = data[0]
          person1.should.have.keys 'first_name', 'last_name'
          person1.should.have.property 'first_name', person1.first_name
          person1.should.have.property 'last_name', person1.last_name

          person2 = data[1]
          person2.should.have.keys 'first_name', 'last_name'
          person2.should.have.property 'first_name', person2.first_name
          person2.should.have.property 'last_name', person2.last_name

          done()


  describe "#set()", ->

    beforeEach ->
      client.flushdb()

    it "should successfully save data", (done)->
      Connector.setClient client
      field = new NestedListField client, "company:1", "staff", model: Person

      field.set [person1, person2], ->
        async.parallel [
          (cb)->
            client.get "company:1:staff:counter", (err, num)->
              num.should.be.equal "2"
              cb()

          (cb)->
            client.get "company:1:staff:0:first_name", (err, first_name)->
              first_name.should.be.equal person1.first_name
              cb()

          (cb)->
            client.get "company:1:staff:0:last_name", (err, last_name)->
              last_name.should.be.equal person1.last_name
              cb()

          (cb)->
            client.get "company:1:staff:1:first_name", (err, first_name)->
              first_name.should.be.equal person2.first_name
              cb()

          (cb)->
            client.get "company:1:staff:1:last_name", (err, last_name)->
              last_name.should.be.equal person2.last_name
              cb()
        ], done

    it "should raise exception when argument is not an array"

    it "should clear database before settings new data"

  describe "#add()", ->

    beforeEach ->
      client.flushdb()

    it "should add value to field", (done)->
      Connector.setClient client
      field = new NestedListField client, "company:1", "staff", model: Person

      field.add person1, (err, count)->
        count.should.be.equal 1
        async.parallel [
          (cb)->
            client.get "company:1:staff:counter", (err, num)->
              num.should.be.equal "1"
              cb()

          (cb)->
            client.get "company:1:staff:0:first_name", (err, first_name)->
              first_name.should.be.equal person1.first_name
              cb()

          (cb)->
            client.get "company:1:staff:0:last_name", (err, last_name)->
              last_name.should.be.equal person1.last_name
              cb()
        ], ->
          field.add person2, (err, count)->
            count.should.be.equal 2
            async.parallel [
              (cb)->
                client.get "company:1:staff:counter", (err, num)->
                  num.should.be.equal "2"
                  cb()

              (cb)->
                client.get "company:1:staff:1:first_name", (err, first_name)->
                  first_name.should.be.equal person2.first_name
                  cb()

              (cb)->
                client.get "company:1:staff:1:last_name", (err, last_name)->
                  last_name.should.be.equal person2.last_name
                  cb()
            ], done

  describe "#del()", ->

    it "should clear all nested model instances in list", (done)->
      Connector.setClient client
      field = new NestedListField client, "company:1", "staff", model: Person

      async.parallel [
        (cb)->
          field.add person1, cb

        (cb)->
          field.add person2, cb
      ], ->
        field.del ->
          async.parallel [
            (cb)->
              client.exists "company:1:staff:counter", (err, exist)->
                exist.should.be.equal 0
                cb()

            (cb)->
              client.exists "company:1:staff:0:first_name", (err, exist)->
                exist.should.be.equal 0
                cb()

            (cb)->
              client.exists "company:1:staff:0:last_name", (err, exist)->
                exist.should.be.equal 0
                cb()

            (cb)->
              client.exists "company:1:staff:1:first_name", (err, exist)->
                exist.should.be.equal 0
                cb()

            (cb)->
              client.exists "company:1:staff:1:last_name", (err, exist)->
                exist.should.be.equal 0
                cb()
          ], done