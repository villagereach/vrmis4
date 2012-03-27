Views.Reports.Generic = Backbone.View.extend({
	template: JST["offline/templates/reports/generic"],

	el: "#offline-container",
	
	initialize: function(options) {
		//this.loadHcVisitData();
		this.products = options.products;
		window.console.log(this.products.size());
	},
	
	render: function() {
		this.delegateEvents();
		window.console.log(this.products.size());
    this.$el.html(this.template({
	    products: [],
		  foo: "bar",
	  }));
		return this;
	},

	close: function() {
		this.undelegateEvents();
		this.unbind();
		return this;
	},

});

	
