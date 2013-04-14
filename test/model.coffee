###
Nested Redis
Model test cases
###


describe "Model", ->
  async = require "async"
  redis = require "redis-mock"

  Connector = require '../lib/connector'
  Connector.setClient true

  Model = require '../lib/model'

  class Person extends Model
    properties: ->
      @str 'first_name'
      @str 'last_name'

  describe "#constructor()", ->
    
    it "should set default prefix to lowercase class name", ->
      model = new Model()
      model.prefix.should.be.equal "model"

    it "should set default prefix to lowercase class name for child classes", ->
      class Child extends Model

      child_model = new Child()
      child_model.prefix.should.be.equal "child"

  describe "Field setters", ->

    describe "#str()", ->
      
      StringField = require "../lib/fields/string"

      class StrChild extends Model
        properties: ->
          @str 'test_field'

      prefix = "some_prefix"
      inst = new StrChild null, prefix
      field = inst.fields[0]

      it "should set new child field", ->
        inst.fields.should.have.length 1
        field.should.be.an.instanceOf StringField

      it "should set right name", ->
        field.name.should.be.equal 'test_field'

      it "should set right prefix", ->
        field.prefix.should.be.equal prefix

    describe "#hash()", ->

      HashField = require "../lib/fields/hash"

      class HashChild extends Model
        properties: ->
          @hash 'test_field2'

      prefix = "some_prefix2"
      inst = new HashChild null, prefix
      field = inst.fields[0]
      it "should set new child field", ->
        inst.fields.should.have.length 1
        field.should.be.an.instanceOf HashField

      it "should set right name", ->
        field.name.should.be.equal 'test_field2'

      it "should set right prefix", ->
        field.prefix.should.be.equal prefix

    describe "#nested()", ->

      class Person extends Model
        properties: ->
          @str 'first_name'
          @str 'last_name'

      describe "NestedField", ->

        class Payment extends Model
          properties: ->
            @nested 'customer',
              model: Person

        NestedField = require "../lib/fields/nested"
        inst = new Payment 1
        field = inst.fields[0]
        it "should set new child field", ->
          inst.fields.should.have.length 1
          field.should.be.an.instanceOf NestedField

        it "should set right name", ->
          field.name.should.be.equal 'customer'

        it "should set right prefix", ->
          field.prefix.should.be.equal 'payment:1'

        it "should set right params", ->
          field.params.model.should.be.equal Person

      describe "NestedListField", ->

        class Company extends Model
          properties: ->
            @nested ['staff'],
              model: Person

        NestedListField = require "../lib/fields/nestedlist"
        inst = new Company 1
        field = inst.fields[0]

        it "should set new child field", ->
          inst.fields.should.have.length 1
          field.should.be.an.instanceOf NestedListField

        it "should set right name", ->
          field.name.should.be.equal 'staff'

        it "should set right prefix", ->
          field.prefix.should.be.equal 'company:1'

        it "should set right params", ->
          field.params.model.should.be.equal Person

  describe "#_setField()", ->

    it "should add field to lists and as property", ->
      class Child extends Model
        properties: ->
          @str 'test'

      child = new Child
      child.fields.should.have.length 1
      child.should.have.property 'test', child.fields[0]
      child.field_names.should.have.length 1
      child.field_names[0].should.be.equal 'test'


    it "should raise error if field name match to built-in model property", ->
      class Child extends Model
        properties: ->
          @hash 'hash'

      (->
        child = new Child
      ).should.throw()

  describe "#_getPrefix()", ->

    it "should return only prefix if no id specified", ->
      inst = new Model null, "prefix"
      inst._getPrefix().should.be.equal "prefix"

    it "should return prefix with id if id specified", ->
      inst = new Model 123, "prefix"
      inst._getPrefix().should.be.equal "prefix:123"

  describe "GET/SET methods", ->
    
    client = redis.createClient()

    beforeEach: ->
      client.flushdb()

    describe "#getAll()", ->
        
      it "should return right data", (done)->
        Connector.setClient client
        async.parallel [
          (cb)->
            client.set "person:1:first_name", "John", cb
          (cb)->
            client.set "person:1:last_name", "White", cb
        ], (err)->

          person = new Person 1
          person.getAll (err, result)->
            result.should.have.keys 'first_name' , 'last_name'
            result.first_name.should.be.equal 'John'
            result.last_name.should.be.equal 'White'
            done()

    describe "#setAll()", ->
      it "should set all fields with right data", (done)->
        client = redis.createClient()
        Connector.setClient client

        person = new Person 2
        person.setAll 
          first_name: "Ivan"
          last_name: "Ivanov"
        , (err)->
          async.parallel [
            (cb)->
              client.get "person:2:first_name", (err, first_name)->
                first_name.should.be.equal "Ivan"
                cb err

            (cb)->
              client.get "person:2:last_name", (err, last_name)->
                last_name.should.be.equal "Ivanov"
                cb err

          ], (err)->
            done()

  describe "#deleteAll()", ->

    beforeEach: ->
      client.flushdb()

    it "should delete all fields", (done)->
      client = redis.createClient()
      Connector.setClient client

      person_data = 
        first_name: 'First'
        last_name: 'Last'
      person = new Person 2
      person.setAll person_data, ->
        person.deleteAll ->
          async.parallel [
            (callback)=>
              client.exists 'person:2:first_name', (err, exist)->
                exist.should.be.equal 0
                callback()

            (callback)=>
              client.exists 'person:2:last_name', (err, exist)->
                exist.should.be.equal 0
                callback()
          ], done

