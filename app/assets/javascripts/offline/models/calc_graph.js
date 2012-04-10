Models.CalcGraph = function(options) {
  options = options || {};

  this._logger = window.console;
  this._refs = {};
  this._memoized = {};

  var that = this;

  this.methods = _.extend(this.defaultMethods, options.methods);
  this.afterCalculate = options.afterCalculate;

  _.each(options.definitions, function(definition) { that.register(definition) });

  this.initialize.apply(this, arguments);
};

_.extend(Models.CalcGraph.prototype, Backbone.Events, {
  initialize: function() {},

  reset: function() {
    this._memoized = {};
  },

  walk: function(definition, callback) {
    var definitions = [definition];
    while (definition = definitions.shift()) {
      var values = definition.values || [definition.value];
      _.each(values, function(value) {
        // skip objects that don't look like a definition
        if (_.isObject(value) && (value.ref || value.method)) {
          definitions.push(value);
        }
      });
      callback(definition);
    }

    return this;
  },

  register: function(definition) {
    var that = this;
    this.walk(definition, function(definition) {
      if (definition.ref) { return; } // don't register references to other definitions

      var refId = definition.name;
      if (!refId) { refId = definition.name = that.genRefId(); }
      if (that._refs[refId]) {
        that._logger.warn('definition already registered with name ' + refId);
      }

      that._refs[refId] = definition;
      that.on('calculate:' + refId, function() { return that.calculate(refId) });
    });

    return this;
  },

  calculate: function(refId) {
    var definition = this._refs[refId];
    if (!definition) {
      this._logger.error('cannot calculate value, missing reference to ' + refId);
      this.trigger('calculated:' + refId, null);
      return this;
    }

    // shortcut for memoized values (already computed)
    var value = this._memoized[refId];
    if (!_.isUndefined(value) && false) {  //turning off for debug
      this.trigger('calculated:' + refId, value);
      return this;
    }

    var method = this.methods[definition.method];
    if (!method) {
      this._logger.error('undefined calc method for ' + refId);
      this.trigger('calculated:' + refId, null);
      return this;
    }

    var that = this;
    var triggers = {};
    var triggerCount = 0;
    var values = _.clone(definition.values || definition.value);
    if (!_.isArray(values)) { values = [values]; }
    _.each(values, function(value, idx) {
      // lookup references to other definitions
      if (_.isObject(value) && value.ref) {
        value = that.dereference(value);
        values[idx] = value;
      }

      // if named definition then fetch asynchronously
      if (_.isObject(value) && value.name) {
        var valName = value.name;
        triggers[valName] = function(value) {
          that.off('calculated:' + valName, triggers[valName]);
          delete triggers[valName];
          values[idx] = value;

          // if triggers list empty then everything evaluated, run callback
          if((triggerCount -= 1) == 0) {
            method(values, definition, function(result) {
              if (that.afterCalculate) { result = that.afterCalculate(result); }
              if (definition.memoize != false) { that._memoized[refId] = result; }
              that.trigger('calculated:' + refId, result);
            });
          }
        };
        triggerCount += 1;
        that.on('calculated:' + valName, triggers[valName]);
      }
    });

    if (_.isEmpty(triggers)) {
      // all values are currently known, no need trigger value calculations
      method(values, definition, function(result) {
        if (that.afterCalculate) { result = that.afterCalculate(result); }
        if (definition.memoize != false) { that._memoized[refId] = result; }
        that.trigger('calculated:' + refId, result);
      });

    } else {
      // one or more value triggers prepared, trigger calculations
      _.each(triggers, function(val, key) { that.trigger('calculate:' + key) });
    }

    return this;
  },

  genRefId: function() {
    // possibility of collisions but unlikely given expected num of definitions
    return 'def#' + Math.floor(Math.random() * 999999 + 1);
  },

  dereference: function(value) {
    if (!_.isObject(value) || !value.ref) { return null; }

    var newVal = this._refs[value.ref];
    if (_.isUndefined(newVal)) {
      this._logger.error('dereferencing to unknown definition ' + value.ref);
      return null;
    }
    return newVal;
  },

  defaultMethods: {
    value: function(values, options, callback) {
      callback(values);
    },
    sum: function(values, options, callback) {
      callback(_.reduce(_.flatten(values), function(a,v) { return a + v }, 0));
    },
    count: function(values, options, callback) {
      var flat_values = _.flatten(values);
      var filtered_results = _.filter(flat_values, function(value) {
          if(options.count_if_equal_to != undefined) {
            return value == options.count_if_equal_to
          } else if(options.count_if_not_equal_to != undefined) {
            return value == options.count_if_not_equal_to
          } else {
            return true
          }
        }
      );
      callback(_.size(filtered_results));
    },
    pluck: function(values, options, callback) {
      var keyChain = _.compact((options.keypath||"").split(/[.\[\]]/));
      result = _.map(_.flatten(values), function(value) {
        return _.reduce(keyChain, function(val,key) {
          val = val || {};
          return val.get ? val.get(key) : val[key]
        }, value);
      });
      callback(result);
    },


  },

});
