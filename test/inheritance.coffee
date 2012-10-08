assert = require 'should'
factory = require('../src/factory').factory

describe "factory inheritance", ->
  afterEach ->
    # clear stubs/mocks set in test
    factory.db = null

  it "uses parent defaults as default values for derived defaults", (done) ->
    factory.define 'base',
      primaryKey: no
      defaults:
        foo: 5
        bar: 'baz'

    factory.define 'derived',
      inherits: 'base'
      defaults:
        foo: 6

    factory.build 'derived', (err, attrs) ->
      assert.equal 6, attrs.foo
      assert.equal 'baz', attrs.bar
      done()

  it 'uses base table name if one is not specified', (done) ->
    factory.define 'base',
      table: 'sample_tbl'
      primaryKey: no
      defaults:
        foo: null
        bar: null

    factory.define 'derived',
      inherits: 'base'
      defaults:
        foo: 5

    factory.db =
      insert: (table, attrs, callback) ->
        table.should.equal 'sample_tbl'
        done()

    factory.create 'derived', ->

  it 'uses parent factory name for table name if one is not specified', (done) ->
    factory.define 'sample_tbl',
      primaryKey: no
      defaults:
        foo: null
        bar: null

    factory.define 'derived',
      inherits: 'sample_tbl'
      defaults:
        foo: 5

    factory.db =
      insert: (table, attrs, callback) ->
        table.should.equal 'sample_tbl'
        done()

    factory.create 'derived', ->

  it 'calls before methods from base to derived', (done) ->
    factory.define 'base',
      before: (attrs, callback) ->
        attrs.base = true
        callback null, attrs

    factory.define 'derived'
      inherits: 'base'
      before: (attrs, callback) ->
        attrs.base.should.be.ok
        done()

    factory.build 'derived', ->

  it 'calls after methods from base to derived', (done) ->
    factory.define 'base',
      table: 'sample_tbl'
      primaryKey: no
      defaults:
        foo: 5
        bar: 'baaar'
      after: (record, callback) ->
        record.base = true
        callback null, record

    factory.define 'derived'
      inherits: 'base'
      after: (record, callback) ->
        record.base.should.be.ok
        done()

    factory.db =
      insert: (table, attrs, callback) ->
        callback null

    factory.create 'derived', ->
