assert = require 'should'
factory = require('../src/factory').factory

describe "factory hooks", ->
  afterEach ->
    # clear stubs/mocks set in test
    factory.db = null

  describe "before", ->
    it "gets called with defaults applied to given attributes", (done) ->
      factory.define 'something',
        defaults:
          stringKey: 'foo'
          overwrite: 'boring'
        before: (attrs, callback) ->
          assert.deepEqual stringKey: 'foo', anotherKey: 5, overwrite: 'haha', attrs
          done()
      factory.build 'something', overwrite: 'haha', anotherKey: 5, ->

    it "gets called with attributes before insertion in db", (done) ->
      factory.define 'something',
        defaults:
          stringKey: 'foo'
        before: (attrs, callback) ->
          done()
      factory.db =
        insert: (table, attrs, callback) ->
          done new Error("insert called")

      factory.build 'something', anotherKey: 5, ->

    it "stores modified attributes in db", (done) ->
      factory.define 'something',
        defaults:
          stringKey: 'default'
        before: (attrs, callback) ->
          attrs.stringKey = 'pwn'
          callback null, attrs

      factory.db =
        insert: (table, attrs, callback) ->
          table.should.equal 'something'
          attrs.should.eql stringKey: 'pwn'
          done()

      factory.create 'something', stringKey: 'overwrite', ->

  describe "after", ->
    it "doesn't get called when only building a record", (done) ->
      factory.define 'something',
        after: (attrs, callback) ->
          done new Error('after called')

      factory.build 'something', -> done()

    it "doesn't get called before insert", (done) ->
      factory.define 'something',
        after: (record, callback) ->
          done new Error('after called')

      factory.db =
        insert: (table, attrs, callback) ->
          done()

      factory.create 'something', ->

    it "gets called after insert", (done) ->
      factory.define 'something',
        after: (record, callback) ->
          done()

      factory.db =
        insert: (table, attrs, callback) ->
          callback null

      factory.create 'something', ->
