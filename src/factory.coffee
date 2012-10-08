isFunction = (obj) ->
  Object.prototype.toString.call(obj) is '[object Function]'

waterfall = (tasks, done) ->
  execute = (idx, lastArgs) ->
    if idx is tasks.length
      done null, lastArgs... if done?
    else
      lastArgs.length = tasks[idx].length - 1 if tasks[idx].length > 0

      tasks[idx] lastArgs..., (err, newArgs...) ->
        if err?
          done err if done?
          return
        execute idx + 1, newArgs

  execute 0, []

defaultsNull = (obj, defaults) ->
  for key, val of defaults when obj[key] is undefined
    obj[key] = val

processFunctionAttributes = do ->
  n = 0
  (attrs) ->
    ++ n
    for own key, val of attrs
      if isFunction(val)
        attrs[key] = val(n, attrs)
    attrs

factories = {}
factory =
  db: null

  define: (name, options) ->
    options.name = name

    if options.inherits?
      inherited = factories[options.inherits]

    options.primaryKey ?= inherited?.primaryKey ? 'id'
    options.table      ?= inherited?.table ? options.name
    options.before     ?= (attrs, callback) -> callback null, attrs
    options.after      ?= (attrs, callback) -> callback null, attrs
    options.defaults   ?= {}

    if inherited?
      before = options.before
      options.before = (attrs, callback) ->
        inherited.before attrs, (err, attrs) ->
          return callback err if err?
          before attrs, callback

      after = options.after
      options.after = (attrs, callback) ->
        inherited.after attrs, (err, attrs) ->
          return callback err if err?
          after attrs, callback

      defaultsNull options.defaults, inherited.defaults

    factories[name] = options

  build: (name, attrs..., callback) ->
    throw new Error("Unknown factory #{name}") unless factories[name]?

    f = factories[name]
    attrs = if attrs.length is 1 then attrs[0] else {}
    defaultsNull attrs, f.defaults
    attrs = processFunctionAttributes(attrs)

    f.before attrs, (err, attrs) ->
      throw new Error(err) if err?
      callback null, attrs

  create: (name, attrs..., callback) ->
    f = factories[name]
    attrs = if attrs.length is 1 then attrs[0] else {}

    waterfall [
      (next) ->
        factory.build name, attrs, next
      (attrs, next) ->
        factory.db.insert f.table, attrs, next
      (info, next) ->
        if f.primaryKey and info?.insertId? and factory.db.findOne?
          params = {}
          params[f.primaryKey] = info.insertId
          factory.db.findOne f.table, params, next
        else
          next null, attrs
      (record, next) ->
        f.after record, next
    ], (err, record) ->
      throw new Error(err) if err?
      callback err, record

exports.factory = factory
# TODO: add db layer
