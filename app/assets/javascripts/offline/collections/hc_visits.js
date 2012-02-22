Collections.HcVisits = Backbone.Collection.extend({
  localStorage: new Store('HcVisits'),
  model: Models.HcVisit,

});
