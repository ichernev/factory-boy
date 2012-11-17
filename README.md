This library is inspired by ruby's `factory_girl`. It should be obvious that it's quite far from it, feature-wise, but it mostly works quite nicely. Some rough notes on how to get it up and running follow.

## DB layer

The `factory.db` property needs to be set to something that responds to `insert` and `findOne` with the following API:

``` coffee
factory.db =
  insert: (table_name, attributes, callback) ->
    # ...
    callback(err, record)
  findOne: (table_name, parameters, callback) ->
    # ...
    callback(err, record)
```

## API

Defining a factory:

``` coffee
factory.define 'model'
  primaryKey: 'column_name'
  table: 'table_name'
  before: (attrs, callback) -> callback(null, attrs)
  after: (attrs, callback) -> callback(null, attrs)
  defaults:
    first_attribute: 'first'
    second_attribute: 'second'
```

## Examples:

Simple case:

``` coffee
factory = require('factory-boy').factory

factory.db = new MyDatabaseObject()

factory.define 'user',
  table: 'users',
  defaults:
    first_name: 'John'
    age: 5

factory.create 'user', last_name: 'Doe', age: 35, (err, user) ->
  console.log user
```

With a relation:

``` coffee
factory.define 'post',
  table: 'posts'
  defaults:
    title: 'Post'
    body: 'Lorem ipsum dolor sit amet'
  before: (attrs, callback) ->
    factory.create 'user', (err, user) ->
      return callback(err, null) if err?

      attrs.user_id = user.id
      callback(null, attrs)

factory.create 'post', title: 'New Post', (err, post) ->
  console.log post, post.user_id
```
