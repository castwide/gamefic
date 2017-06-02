var Gamefic = (function() {
	var updateCallbacks = [];
	var startCallbacks = [];
	var loggingUrl = null;
	var logId = null;
	var logAlias = null;
	var lastPrompt = null;
	var lastInput = null;

	var _start = function() {
		startCallbacks.forEach((callback) => {
			callback();
		});
		Opal.gvars.engine.$run();
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
						_start();
					}).fail(function(response) {
						console.warn('Logging failed.');
						console.warn(response);
						_start();
					});
				} else {
					console.warn('Logging was not activated for ' + loggingUrl);
					_start();
				}
			} else {
				_start();
			}
		},

		update: function(json) {
			var state = JSON.parse(json);
			state.last_prompt = lastPrompt;
			state.last_input = lastInput;
			if (logId) {
				$.post(loggingUrl + '/' + logId + '.json', { _method: 'PUT', state: state }, function(response) {

				}).fail(function(response) {
					console.warn('Logging update failed.');
					console.warn(response);
					logId = null;
				});
			}
			updateCallbacks.forEach(function(callback) {
				callback(state);
			});
			lastPrompt = state.prompt;
		},

		receive: function(input) {
			lastInput = input;
			Opal.gvars.engine.$receive(input);
		},

		onStart: function(callback) {
			startCallbacks.push(callback);
		},

		onUpdate: function(callback) {
			updateCallbacks.push(callback);
		},

		save: function(filename, data) {
			localStorage.setItem(filename, data);
			Opal.GameficOpal.$static_character().$tell('Game saved.');
		},

		restore: function(filename) {
			var json = localStorage.getItem(filename);
			var snapshot = Opal.JSON.$parse(json);
			Opal.gvars.plot.$restore(snapshot);
			Opal.gvars.engine.$user().$character().$flush();
			Opal.gvars.engine.$user().$character().$cue(Opal.gvars.plot.$default_scene());
			Opal.gvars.plot.$update();
			Opal.gvars.plot.$ready();
			Opal.gvars.engine.$user().$character().$tell('Game restored to last available turn.');
			var state = Opal.gvars.engine.$user().$character().$state();
			var json = state.$to_json();
			this.update(json);
		}
	}
})();
