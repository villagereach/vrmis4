Views.HcVisits.EditScreen = Backbone.View.extend({
  tableField: JST['offline/templates/hc_visits/table_field'],

  tagName: 'div',
  state: 'todo',

  events: {
    'change input, textarea': 'change',
  },

  vh: Helpers.View,
  t: Helpers.View.t,

  initialize: function(options) {
    var that = this;
    _.each(options, function(v,k) { that[k] = v });    
  },

  render: function() {
    this.delegateEvents();
    this.$el.html(this.template(this));
    return this;
  },

  close: function() {
    this.undelegateEvents();
    this.remove();
    this.unbind();
    return this;
  },

  change: function(e) {
    var elem = e.srcElement;
    var $elem = this.$(elem);

    var obj = this.hcVisit;
    var type = elem.type;
    var name = elem.name;
    var value = null;

    if (type == 'number') {
      value = Number(elem.value) || null; // removes NaNs
      obj.set(name, value);

    } else if (type == 'radio') {
      value = elem.value;

      // convert booleans from string to Boolean
      if (value.match(/^(?:true|false)$/)) {
        value = (value === 'true');
      }

      obj.set(name, value);

    } else if (type == 'checkbox') {
      // NR boxes in a separate namespace to allow form serialization
      if ($elem.hasClass('nr')) {
        name = name.replace(/^nr\./, '');
      }

      var parts = name.match(/^(.+)\[\]$/);
      if (parts) { // parts[0] is name w/o '[]', parts[1] is name w/ '[]'
        // multiple checkboxes, actual name is w/o trailing '[]'
        name = parts[1];

        // initialize w/ empty array if undefined
        var origVal = obj.get(name, {silent: true});
        if (!origVal) { obj.set(name, origVal = []); }

        if (elem.checked) {
          // adding a
          obj.add(name, elem.value);
        } else {
          var idx;
          if ((idx = origVal.indexOf(elem.value)) >= 0) {
            obj.remove(name+'['+idx+']');
          }
        }

        // returned value should be a complete list of checked values
        // note: checkboxes could be a subset of model values, return actual
        var $valueElems = this.$('input[name="' + parts[0] + '"]:checked');
        value = $valueElems.map(function() { return this.value });

      } else {
        // single checkbox
        value = elem.checked ? elem.value : null;
        obj.set(name, value);
      }

    } else {
      value = elem.value;
      obj.set(name, value);
    }

    if ($elem.hasClass('render')) {
      // changes to this element require a complete screen re-render
      this.render();
    } else {
      // at a minimum, we need to clean up any NR-related fields
      this.cleanupNR(e);
    }

    return [name, value];
  },

  cleanupNR: function(e) {
    var elem = e.srcElement;
    var $elem = this.$(elem);

    if ($elem.hasClass('nr')) {
      var valId = elem.id.replace(/-nr$/, '');
      var $valElem = this.$('#' + valId);
      $valElem.val('');

    } else {
      var nrId = elem.id + '-nr';
      var $nrElem = this.$('#' + nrId);
      $nrElem.attr('checked', false);
    }
  },

  setSuper: function(klass) { this.super = klass },

});

// hackish way of setting 'super' class to make subclassed functions cleaner
Views.HcVisits.EditScreen.prototype.setSuper(Views.HcVisits.EditScreen.prototype);
