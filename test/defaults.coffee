assert = require('should')
factory = require('../src/factory').factory

describe 'factory defaults', ->
  afterEach ->
    # clear stubs/mocks set in test
    factory.db = null

  describe 'attributes', ->
    before ->
      factory.define 'user',
        table: 'user_tbl'
        defaults:
          name: 'john'
          age: 5

    describe 'plain attributes', ->
      it 'uses defaults', (done) ->
        factory.build 'user', (err, user) ->
          assert.not.exist err
          user.should.include name: 'john', age: 5
          done()

      it 'uses supplied attributes over defaults', (done) ->
        factory.build 'user', age: 7, (err, user) ->
          assert.not.exist err
          user.should.include name: 'john', age: 7
          done()

      it 'uses user supplied null over defaults', (done) ->
        factory.build 'user', age: null, (err, user) ->
          assert.not.exist err
          assert.not.exist user.age
          done()

    describe 'function attributes', ->
      it 'handles function attributes receiving counter', (done) ->
        factory.define 'user',
          table: 'user_tbl'
          defaults:
            name: (n) -> "john#{n}"
            age: (n) -> n

        factory.build 'user', (err, user) ->
          user.name.should.equal "john#{user.age}"
          done()

      it 'handles function attributes receiving all the attributes', (done) ->
        factory.define 'user',
          table: 'user_tbl'
          defaults:
            name: (n, attrs) -> "john#{attrs.age}"
            age: (n) -> n

        factory.build 'user', age: 5, (err, user) ->
          user.name.should.equal "john5"
          done()
