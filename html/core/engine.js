var Gamefic = (function() {
	var startCallbacks = [];
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
			lastPrompt = Opal.GameficOpal.$static_player().$character().$scene().$data().$prompt();
			Opal.GameficOpal.$static_plot().$update();
			var response = getResponse();
			handle(response);
			finishCallbacks.forEach(function(callback) {
				callback(response);
			});
			lastPrompt = Opal.GameficOpal.$static_player().$character().$scene().$data().$prompt();
			response = getResponse();
			doReady(response);
		},
		onStart: function(callback) {
			startCallbacks.push(callback);
		},
		onFinish: function(callback) {
			finishCallbacks.push(callback);
		},
		handleResponse: function(state, callback) {
			responseCallbacks[state] = callback;
		}
	}
})();
