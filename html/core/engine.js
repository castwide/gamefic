var Gamefic = (function() {
	var startCallbacks = [];
	var inputCallbacks = [];
	var finishCallbacks = [];
	var responseCallbacks = {};
	var lastInput = null;
	var lastPrompt = null;
	var getResponse = function() {
		return {
			output: Opal.GameficOpal.$static_player().$state().$output(),
			state: Opal.GameficOpal.$static_player().$character().$scene().$state(),
			prompt: lastPrompt,
			input: lastInput
		}
	}
	var doReady = function(response) {
		startCallbacks.forEach(function(callback) {
			callback(response);
		});
		Opal.GameficOpal.$static_plot().$ready();
	}
	var handle = function(response) {
		var handler = responseCallbacks[response.state] || responseCallbacks['Active'];
		handler(response);
	}
	return {
		start: function() {
			Opal.GameficOpal.$load_scripts();			
			Opal.GameficOpal.$static_plot().$introduce(Opal.GameficOpal.$static_player().$character());
			lastPrompt = Opal.GameficOpal.$static_player().$character().$scene().$data().$prompt();
			var response = getResponse();
			doReady(response);
			handle(response);
		},
		update: function(input) {
			if (input != null) {
				Opal.GameficOpal.$static_player().$character().$queue().$push(input);
			}
			lastInput = input;
			var response = getResponse();
			inputCallbacks.forEach(function(callback) {
				callback(response);
			});
			Opal.GameficOpal.$static_plot().$update();
			var previousResponse = getResponse();
			lastPrompt = Opal.GameficOpal.$static_player().$character().$scene().$data().$prompt();
			response = getResponse();
			doReady(response);
			response = getResponse();
			previousResponse.output += response.output;
			previousResponse.prompt = response.prompt;
			handle(previousResponse);
			finishCallbacks.forEach(function(callback) {
				callback(response);
			});
			if (response.state == 'Testing') {
				Gamefic.update(null);
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
		}
	}
})();
