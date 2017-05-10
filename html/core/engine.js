var Gamefic = (function() {
	var updateCallbacks = [];
	return {
		start: function() {
			Opal.gvars.engine.$run();
		},
		update: function(response) {
			console.log('Called the Gamefic update');
			var state = JSON.parse(response);
			console.log('Output: ' + state.output);
			updateCallbacks.forEach(function(callback) {
				callback(state);
			});
		},
		receive: function(input) {
			Opal.gvars.engine.$receive(input);
		},
		onUpdate: function(callback) {
			updateCallbacks.push(callback);
		},
		save: function(filename, data) {
			var json = Opal.JSON.$generate(data);
			localStorage.setItem(filename, json);
			Opal.GameficOpal.$static_character().$tell('Game saved.');
		},
		restore: function(filename) {
			var data = Opal.JSON.$parse(localStorage.getItem(filename));
			var metadata = data.$fetch('metadata');
			// HACK Converting hashes to strings for JavaScript comparison
			if (metadata.$to_s() != Opal.GameficOpal.$static_plot().$metadata().$to_s()) {
				Opal.GameficOpal.$static_character().$tell('The saved data is not compatible with this version of the game.');
				return Opal.nil;
			} else {
				return data;
			}
		}
	}
})();
