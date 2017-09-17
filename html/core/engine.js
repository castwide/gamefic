var Gamefic = (function() {
	var startCallbacks = [];
	var updateCallbacks = [];
	var receiveCallbacks = [];
	var restoreCallbacks = [];
	var saveCallbacks = [];
	var loggingUrl = null;
	var logId = null;
	var logAlias = null;
	var lastPrompt = null;
	var lastInput = null;

	var _start = function() {
		return new Promise((resolve) => {
			var i = 0;
			var state = null;
			var recursor = function() {
				if (i <= startCallbacks.length - 1) {
					startCallbacks[i]().then((response) => {
						if (response) {
							state = response;
							Gamefic.update(response);
						}
						recursor();
					});
					i++;
				} else {
					resolve(state);
				}
			}
			recursor();	
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
			return _start();
		},

		update: function(state) {
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
			return new Promise((resolve) => {
				var i = 0;
				var recursor = function() {
					if (i <= updateCallbacks.length - 1) {
						updateCallbacks[i](state).then((response) => {
							recursor();
						});
						i++;
					} else {
						lastPrompt = state.prompt;
						resolve(state);
					}
				}
				recursor();	
			});
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

		onSave: function(callback) {
			saveCallbacks.push(callback);
		},

		save: function(filename, data) {
			saveCallbacks.forEach((callback) => {
				callback(filename, data);
			});
		},

		restore: function(filename) {
			return new Promise((resolve, reject) => {
				var json = localStorage.getItem(filename);
				var data = JSON.parse(json);
				var i = 0;
				var state = null;
				var recursor = function() {
					if (i <= restoreCallbacks.length - 1) {
						restoreCallbacks[i](data).then((response) => {
							if (response) {
								state = response;
							}
							recursor();
						}).catch((response) => {
							reject(response);
						});
						i++;
					} else {
						resolve(state);
					}
				}
				recursor();		
			});
		}
	}
})();
