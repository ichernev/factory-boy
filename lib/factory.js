// Generated by CoffeeScript 1.3.3
(function() {
  var defaultsNull, factories, factory, isFunction, processFunctionAttributes, waterfall,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty;

  isFunction = function(obj) {
    return Object.prototype.toString.call(obj) === '[object Function]';
  };

  waterfall = function(tasks, done) {
    var execute;
    execute = function(idx, lastArgs) {
      if (idx === tasks.length) {
        if (done != null) {
          return done.apply(null, [null].concat(__slice.call(lastArgs)));
        }
      } else {
        if (tasks[idx].length > 0) {
          lastArgs.length = tasks[idx].length - 1;
        }
        return tasks[idx].apply(tasks, __slice.call(lastArgs).concat([function() {
          var err, newArgs;
          err = arguments[0], newArgs = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
          if (err != null) {
            if (done != null) {
              done(err);
            }
            return;
          }
          return execute(idx + 1, newArgs);
        }]));
      }
    };
    return execute(0, []);
  };

  defaultsNull = function(obj, defaults) {
    var key, val, _results;
    _results = [];
    for (key in defaults) {
      val = defaults[key];
      if (obj[key] === void 0) {
        _results.push(obj[key] = val);
      }
    }
    return _results;
  };

  processFunctionAttributes = (function() {
    var n;
    n = 0;
    return function(attrs) {
      var key, val;
      ++n;
      for (key in attrs) {
        if (!__hasProp.call(attrs, key)) continue;
        val = attrs[key];
        if (isFunction(val)) {
          attrs[key] = val(n, attrs);
        }
      }
      return attrs;
    };
  })();

  factories = {};

  factory = {
    db: null,
    define: function(name, options) {
      var after, before, inherited, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
      options.name = name;
      if (options.inherits != null) {
        inherited = factories[options.inherits];
      }
      if ((_ref = options.primaryKey) == null) {
        options.primaryKey = (_ref1 = inherited != null ? inherited.primaryKey : void 0) != null ? _ref1 : 'id';
      }
      if ((_ref2 = options.table) == null) {
        options.table = (_ref3 = inherited != null ? inherited.table : void 0) != null ? _ref3 : options.name;
      }
      if ((_ref4 = options.before) == null) {
        options.before = function(attrs, callback) {
          return callback(null, attrs);
        };
      }
      if ((_ref5 = options.after) == null) {
        options.after = function(attrs, callback) {
          return callback(null, attrs);
        };
      }
      if ((_ref6 = options.defaults) == null) {
        options.defaults = {};
      }
      if (inherited != null) {
        before = options.before;
        options.before = function(attrs, callback) {
          return inherited.before(attrs, function(err, attrs) {
            if (err != null) {
              return callback(err);
            }
            return before(attrs, callback);
          });
        };
        after = options.after;
        options.after = function(attrs, callback) {
          return inherited.after(attrs, function(err, attrs) {
            if (err != null) {
              return callback(err);
            }
            return after(attrs, callback);
          });
        };
        defaultsNull(options.defaults, inherited.defaults);
      }
      return factories[name] = options;
    },
    build: function() {
      var attrs, callback, f, name, _i;
      name = arguments[0], attrs = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), callback = arguments[_i++];
      if (factories[name] == null) {
        throw new Error("Unknown factory " + name);
      }
      f = factories[name];
      attrs = attrs.length === 1 ? attrs[0] : {};
      defaultsNull(attrs, f.defaults);
      attrs = processFunctionAttributes(attrs);
      return f.before(attrs, function(err, attrs) {
        if (err != null) {
          throw new Error(err);
        }
        return callback(null, attrs);
      });
    },
    create: function() {
      var attrs, callback, f, name, _i;
      name = arguments[0], attrs = 3 <= arguments.length ? __slice.call(arguments, 1, _i = arguments.length - 1) : (_i = 1, []), callback = arguments[_i++];
      f = factories[name];
      attrs = attrs.length === 1 ? attrs[0] : {};
      return waterfall([
        function(next) {
          return factory.build(name, attrs, next);
        }, function(attrs, next) {
          return factory.db.insert(f.table, attrs, next);
        }, function(info, next) {
          var params;
          if (f.primaryKey && ((info != null ? info.insertId : void 0) != null) && (factory.db.findOne != null)) {
            params = {};
            params[f.primaryKey] = info.insertId;
            return factory.db.findOne(f.table, params, next);
          } else {
            return next(null, attrs);
          }
        }, function(record, next) {
          return f.after(record, next);
        }
      ], function(err, record) {
        if (err != null) {
          throw new Error(err);
        }
        return callback(err, record);
      });
    }
  };

  exports.factory = factory;

}).call(this);
