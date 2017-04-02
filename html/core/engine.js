var Gamefic = (function() {
	var startCallbacks = [];
	var inputCallbacks = [];
	var finishCallbacks = [];
	var responseCallbacks = {};
	var doReady = function(response) {
		startCallbacks.forEach(function(callback) {
			callback(response);
		});
	}
	var handle = function(response) {
		var handler = responseCallbacks[response.scene] || responseCallbacks['Active'];
		handler(response);
	}
	return {
		start: function() {
			Opal.GameficOpal.$load_scripts();
			Opal.GameficOpal.$static_plot().$introduce(Opal.GameficOpal.$static_character());
			Opal.GameficOpal.$static_plot().$ready();
			var response = JSON.parse(Opal.GameficOpal.$static_character().$state().$to_json());
			doReady(response);
			handle(response);
			finishCallbacks.forEach(function(callback) {
				callback(response);
			});
		},
		update: function(input) {
			if (input != null) {
				Opal.GameficOpal.$static_character().$queue().$push(input);
			}
			Opal.GameficOpal.$static_plot().$update();
			Opal.GameficOpal.$static_plot().$ready();
			var response = JSON.parse(Opal.GameficOpal.$static_character().$state().$to_json());
			response.input = input;
			if (Opal.GameficOpal.$static_character().$queue().$length() > 0) {
				response.testing = true;
			}
			inputCallbacks.forEach(function(callback) {
				callback(response);
			});
			doReady(response);
			handle(response);
			finishCallbacks.forEach(function(callback) {
				callback(response);
			});
			if (Opal.GameficOpal.$static_character().$queue().$length() > 0) {
				setTimeout("Gamefic.update();", 1);
			}
		},
		onStart: function(callback) {
			startCallbacks.push(callback);
		},
		onInput: function(callback) {
			inputCallbacks.push(callback);
		},
		onFinish: function(callback) {
			finishCallbacks.push(callback);
		},
		handleResponse: function(state, callback) {
			responseCallbacks[state] = callback;
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
