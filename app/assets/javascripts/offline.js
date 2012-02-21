//= require i18n_dict

//= require underscore
//= require backbone
//= require backbone.localStorage

//= require form2js
//= require jquery.toObject

//= require ./offline/app
//= require ./offline/routes
//= require_tree ./offline/models
//= require_tree ./offline/collections
//= require_tree ./offline/templates
//= require_tree ./offline/views

$(function() {

  window.hcv = new Models.HcVisit({ health_center: "meluluca", month: "2011-12" });

  window.App = new Views.HcVisits.Container({
    model: hcv,
    screens: [
      new Views.HcVisits.EditVisitInfo({ model: hcv }),
      new Views.HcVisits.EditRefrigerators({ model: hcv }),
      new Views.HcVisits.EditEpiInventory({ model: hcv }),
    ],
  });

  var router = new OfflineRouter();
  Backbone.history.start({root: "/offline/"});

});
