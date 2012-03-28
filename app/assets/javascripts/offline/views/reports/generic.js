Views.Reports.Generic = Backbone.View.extend({
	template:  JST["offline/templates/reports/generic"],
	el: "#offline-container",
	
	initialize: function(options) {
		this.products = options.products;
		this.healthCenters = options.healthCenters.toJSON();
		this.hcVisits = options.hcVisits.toJSON();
		this.scoping = options.scoping;
		this.visitMonths = options.visitMonths;
	},
	
	render: function() {
		this.delegateEvents();

		var scopes = (this.scoping || "").split("/");
		var month = scopes.shift();
		var geoScope = scopes;
		

		var scoped_hcs = this.geoscope_filter(this.healthCenters, geoScope, 'hc');
		var scoped_hcvs = this.geoscope_filter(this.hcVisits, geoScope, 'hcvisit');
		var scoped_visited_hcvs = _.filter(scoped_hcvs, function(hcv){return hcv.visited});
		var scoped_hcvs_by_month = _.groupBy(scoped_hcvs, 'month');
		var scoped_visited_hcvs_by_month = _.groupBy(scoped_visited_hcvs, 'month');
		
		
    this.$el.html(this.template({
	    products: this.products.toJSON(),
			scoped_hcvs: scoped_hcvs,
  		scoped_visited_hcvs: scoped_visited_hcvs,
			scoped_hcvs_by_month: scoped_hcvs_by_month,
  		scoped_visited_hcvs_by_month: scoped_visited_hcvs_by_month,
			scoped_hcs:  scoped_hcs,
			visitMonths: this.visitMonths,
			month: month,
			geoScope:  geoScope,
	  }));
	
		return this;
	},
	
	geoscope_filter: function(source_objs, geoScope, obj_type) {
		geoScope = _.compact(geoScope)
		//todo: check geoScope for only trailing nulls/undefs
		//obj_type: hcVisits use health_center_code, hcs just 'code'
		var hc_code_name = obj_type.toLowerCase().match("visit") ? 'health_center_code' : 'code';
		var geoCodes = ['delivery_zone_code','district_code',hc_code_name];
		window.console.log("geofilter: gs "+geoScope.toString() + " source_hcs "+source_objs.length + " gcodes "+geoCodes.toString());

		var filtered_objs = _.filter(source_objs, function(obj) {
			var geoValues = _.map(geoScope, function(g,idx) {return obj[geoCodes[idx]]});
			return _.isEqual(geoValues,geoScope);
		});
		window.console.log("geofilter: filtered count "+filtered_objs.length);
		return filtered_objs;
	},
	


	close: function() {
		this.undelegateEvents();
		this.unbind();
		return this;
	},





});

	
