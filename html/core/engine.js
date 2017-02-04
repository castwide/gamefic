var Gamefic = (function() {
	var startCallbacks = [];
	var inputCallbacks = [];
	var finishCallbacks = [];
	var responseCallbacks = {};
	var lastInput = null;
	var lastPrompt = null;
	var getResponse = function(withOutput) {
		var r = {
			output: (withOutput ? Opal.GameficOpal.$static_user().$flush() : null),
			//state: Opal.GameficOpal.$static_plot().$scenes().$fetch(Opal.GameficOpal.$static_character().$scene()).$type(),
			state: Opal.GameficOpal.$static_character().$scene().$type(),
			prompt: lastPrompt,
			input: lastInput,
			testing: (Opal.GameficOpal.$static_character().$queue().$length() > 0)
		}
		return r;
	}
	var doReady = function(response) {
		startCallbacks.forEach(function(callback) {
			callback(response);
		});
	}
	var handle = function(response) {
		var handler = responseCallbacks[response.state] || responseCallbacks['Active'];
		handler(response);
	}
	return {
		start: function() {
			Opal.GameficOpal.$load_scripts();
			Opal.GameficOpal.$static_plot().$introduce(Opal.GameficOpal.$static_character());
			lastPrompt = Opal.GameficOpal.$static_character().$prompt();
			this.update('');
		},
		update: function(input) {
			if (input != null) {
				Opal.GameficOpal.$static_character().$queue().$push(input);
			}
			lastInput = input;
			var response = getResponse(false);
			inputCallbacks.forEach(function(callback) {
				callback(response);
			});
			Opal.GameficOpal.$static_plot().$update();
			Opal.GameficOpal.$static_plot().$ready();
			lastPrompt = Opal.GameficOpal.$static_character().$prompt();
			response = getResponse(true);
			var updateResponse = response;
			doReady(response);
			lastPrompt = Opal.GameficOpal.$static_character().$prompt();
			response = getResponse(true);
			response.output = updateResponse.output + response.output;
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
