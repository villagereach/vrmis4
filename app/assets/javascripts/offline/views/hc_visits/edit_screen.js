Views.HcVisits.EditScreen = Backbone.View.extend({
  tableField: JST['offline/templates/hc_visits/table_field'],

  tagName: 'div',
  state: 'todo',

  events: {
    'change input': 'change',
  },

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

    var name = elem.name;
    var value = null;

    switch(elem.type) {
      case 'number':
        value = Number(elem.value) || null; // removes NaNs
        break;

      case 'radio':
        value = elem.value;
        if (value.match(/^(?:true|false)$/)) {
          value = (value === 'true');
        }
        break;

      case 'checkbox':
        if ($elem.hasClass('nr')) {
          name = name.replace(/^nr\./, '');
        }
        value = elem.checked ? elem.value : null;

      default:
        value = elem.value;
    };

    this.hcVisit.set(name, value);

    if ($elem.hasClass('render')) {
      // changes to this element require a complete screen re-render
      this.render();
    } else {
      // at a minimum, we need to clean up any NR-related fields
      this.cleanupNR(e);
    }
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
