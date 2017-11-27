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
	var lastState = null;

	var _start = function() {
		return new Promise((resolve) => {
			var i = 0;
			var state = null;
			var recursor = function() {
				if (i <= startCallbacks.length - 1) {
					startCallbacks[i]().then((response) => {
						if (response) {
							state = response;
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

	var _startLog = function(state) {
		return new Promise((resolve) => {
			if (loggingUrl) {
				if (_canLog()) {
					$.post(loggingUrl, { alias: _logAlias(), state: state }, function(ajaxResponse) {
						logId = ajaxResponse.id;
						resolve(state);
					}).fail(function(ajaxResponse) {
						console.warn('Logging failed.');
						console.warn(ajaxResponse);
						resolve(state);
					});
				} else {
					console.warn('Logging was not activated for ' + loggingUrl);
					resolve(state);
				}
			} else{
				resolve(state);
			}	
		});
	}

	var _updateLog = function(state) {
		return new Promise((resolve) => {
			if (logId) {
				$.post(loggingUrl + '/' + logId + '.json', { _method: 'PUT', state: state }, function(response) {
					// Log was successful
					resolve();
				}).fail(function(response) {
					console.warn('Logging update failed.');
					console.warn(response);
					logId = null;
					resolve();
				});
			} else {
				resolve();
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
		state: function() {
			return lastState;
		},

		enableLogging: function(url) {
			loggingUrl = url || '/game/log';
			return loggingUrl;
		},

		logAlias: function(name) {
			return _logAlias(name);
		},

		canLog: function() {
			return _canLog();
		},

		start: function() {
			return new Promise((resolve) => {
				_start().then((response) => {
					_startLog(response).then(() => {
						Gamefic.update(response).then(() => {
							resolve(response);							
						});
					});
				});
			});
		},

		update: function(state) {
			// @todo Figure out where this method is getting a string instead of an object
			if (typeof state == 'string') {
				state = JSON.parse(state);
			}
			state.last_prompt = lastPrompt;
			state.last_input = lastInput;
			return new Promise((resolve) => {
				_updateLog(state).then(() => {
					var i = 0;
					var recursor = function() {
						if (i <= updateCallbacks.length - 1) {
							updateCallbacks[i](state).then((response) => {
								recursor();
							});
							i++;
						} else {
							lastPrompt = state.prompt;
							lastState = state;
							resolve(state);
						}
					}
					recursor();		
				});
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
