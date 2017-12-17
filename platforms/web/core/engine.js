var Gamefic = (function() {
	var onStart = null;
	var onUpdate = null;

	return {
		start: function() {
			Opal.gvars.engine.$run();	
			var state = Opal.gvars.engine.$user().$character().$state();
			var json = state.$to_json();
			var response = JSON.parse(json);
			if (onStart) {
				onStart(response);
			}
		},

		receive: function(input) {
			Opal.gvars.engine.$receive(input);
			this.update();
		},

		update: function() {
			Opal.gvars.engine.$update();
			var state = Opal.gvars.engine.$user().$character().$state();
			var json = state.$to_json();
			var response = JSON.parse(json);
			if (onUpdate) {
				onUpdate(response);
			}
			if (Opal.gvars.engine.$user().$character().$queue().$length() > 0) {
				this.update();
			}
		},

		onStart: function(callback) {
			onStart = callback;
		},	

		onUpdate: function(callback) {
			onUpdate = callback;
		},
	}
})();
