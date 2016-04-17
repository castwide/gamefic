var Gamefic = (function() {
	var startCallbacks = [];
	var inputCallbacks = [];
	var finishCallbacks = [];
	var responseCallbacks = {};
	var lastInput = null;
	var lastPrompt = null;
	var getResponse = function(withOutput) {
		var r = {
			output: (withOutput ? Opal.GameficOpal.$static_player().$state().$output() : null),
			state: Opal.GameficOpal.$static_player().$character().$scene().$state(),
			prompt: lastPrompt,
			input: lastInput
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
			Opal.GameficOpal.$static_plot().$introduce(Opal.GameficOpal.$static_player().$character());
			lastPrompt = Opal.GameficOpal.$static_player().$character().$scene().$data().$prompt();
			Opal.GameficOpal.$static_plot().$ready();
			lastPrompt = Opal.GameficOpal.$static_player().$character().$scene().$data().$prompt();
			var response = getResponse(true);
			doReady(response);
			handle(response);
		},
		update: function(input) {
			if (input != null) {
				Opal.GameficOpal.$static_player().$character().$queue().$push(input);
			}
			lastInput = input;
			var response = getResponse(false);
			inputCallbacks.forEach(function(callback) {
				callback(response);
			});
			Opal.GameficOpal.$static_plot().$update();
			Opal.GameficOpal.$static_plot().$ready();
			lastPrompt = Opal.GameficOpal.$static_player().$character().$scene().$data().$prompt();
			response = getResponse(true);
			var updateResponse = response;
			doReady(response);
			lastPrompt = Opal.GameficOpal.$static_player().$character().$scene().$data().$prompt();
			response = getResponse(true);
			response.output = updateResponse.output + response.output;
			handle(response);
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
