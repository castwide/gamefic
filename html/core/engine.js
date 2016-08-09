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
			state: Opal.GameficOpal.$static_plot().$scenes().$fetch(Opal.GameficOpal.$static_player().$character().$scene()).$state(),
			prompt: lastPrompt,
			input: lastInput,
			testing: (Opal.GameficOpal.$static_player().$test_queue().$length() > 0)
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
			lastPrompt = Opal.GameficOpal.$static_plot().$scenes().$fetch(Opal.GameficOpal.$static_player().$character().$scene()).$prompt();
			var response = getResponse(true);
			doReady(response);
			handle(response);
			finishCallbacks.forEach(function(callback) {
				callback(response);
			});
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
			lastPrompt = Opal.GameficOpal.$static_plot().$scenes().$fetch(Opal.GameficOpal.$static_player().$character().$scene()).$prompt();
			response = getResponse(true);
			var updateResponse = response;
			doReady(response);
			lastPrompt = Opal.GameficOpal.$static_plot().$scenes().$fetch(Opal.GameficOpal.$static_player().$character().$scene()).$prompt();
			response = getResponse(true);
			response.output = updateResponse.output + response.output;
			handle(response);
			finishCallbacks.forEach(function(callback) {
				callback(response);
			});
			var testCommand = Opal.GameficOpal.$static_player().$test_queue().$shift();
			if (typeof testCommand == 'string') {
				setTimeout("Gamefic.update(" + JSON.stringify(testCommand) + ");", 1);
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
			var json = JSON.stringify(data);
			console.log("Save " + filename + ": " + json);
			localStorage.setItem(filename, json);
			Opal.GameficOpal.$static_player().$character().$tell('Game saved.');
		},
		restore: function(filename) {
			console.log("Restore " + filename + ": " + localStorage.getItem(filename));
			return JSON.parse(localStorage.getItem(filename));
		}
	}
})();
