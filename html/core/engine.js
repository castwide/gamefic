var Gamefic = (function() {
	var startCallbacks = [];
	var updateCallbacks = [];
	var receiveCallbacks = [];
	var restoreCallbacks = [];
	var loggingUrl = null;
	var logId = null;
	var logAlias = null;
	var lastPrompt = null;
	var lastInput = null;

	var _start = function() {
		startCallbacks.forEach((callback) => {
			var response = callback();
			if (response) {
				Gamefic.update(response);
			}
		});
	}

	var _canLog = function() {
		if (!loggingUrl) {
			return false;
		}
		var a = document.createElement('a');
		a.href = loggingUrl;
		return (a.host == window.location.host);
	}

	var _logAlias = function(name) {
		logAlias = name || logAlias || 'anonymous';
		return logAlias;
	}
	return {
		enableLogging: function(url) {
			loggingUrl = url || '//gamefic.com/game/log';
			return loggingUrl;
		},

		logAlias: function(name) {
			return _logAlias(name);
		},

		canLog: function() {
			return _canLog();
		},

		start: function() {
			if (loggingUrl) {
				if (_canLog()) {
					$.post(loggingUrl, { alias: _logAlias() }, function(response) {
						logId = response.id;
					}).fail(function(response) {
						console.warn('Logging failed.');
						console.warn(response);
					});
				} else {
					console.warn('Logging was not activated for ' + loggingUrl);
				}
			}
			_start();
		},

		update: function(state) {
			console.log('Updating ' + state);
			state.last_prompt = lastPrompt;
			state.last_input = lastInput;
			if (logId) {
				$.post(loggingUrl + '/' + logId + '.json', { _method: 'PUT', state: state }, function(response) {
					// Log was successful
				}).fail(function(response) {
					console.warn('Logging update failed.');
					console.warn(response);
					logId = null;
				});
			}
			updateCallbacks.forEach(function(callback) {
				console.log('Running an update callback');
				callback(state);
			});
			lastPrompt = state.prompt;
		},

		receive: function(input) {
			lastInput = input;
			receiveCallbacks.forEach(function(callback) {
				var state = callback(input);
				if (state) {
					Gamefic.update(state);
				}
			});
		},

		onStart: function(callback) {
			startCallbacks.push(callback);
		},

		onUpdate: function(callback) {
			updateCallbacks.push(callback);
		},

		onReceive: function(callback) {
			receiveCallbacks.push(callback);
		},

		onRestore: function(callback) {
			restoreCallbacks.push(callback);
		},

		save: function(filename, data) {
			localStorage.setItem(filename, Opal.JSON.$generate(data));
		},

		restore: function(filename) {
			var json = localStorage.getItem(filename);
			var state = null;
			restoreCallbacks.forEach(function(callback) {
				state = callback(json);
			});
			if (state) {
				this.update(state);
			}
		}
	}
})();
