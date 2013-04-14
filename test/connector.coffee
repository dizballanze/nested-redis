###
Nested Redis
Connector test cases
###


describe "Connector", ->

  describe "@setClient()", ->

    it "should set same client for all models", ->
      Model = require '../lib/model'

      class Child1 extends Model

      class Child2 extends Model

      Connector = require '../lib/connector'
      Connector.setClient 'test'

      Child1.connector.getClient().should.be.equal 'test'
      Child2.connector.getClient().should.be.equal 'test'