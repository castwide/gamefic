var Gamefic = (function() {
	var updateCallbacks = [];
	var startCallbacks = [];
	var loggingUrl = null;
	var logId = null;
	var logAlias = null;

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

	return {
		enableLogging: function(url) {
			loggingUrl = url || '//gamefic.com/game/log';
			return loggingUrl;
		},

		logAlias: function(name) {
			logAlias = name || logAlias || 'anonymous';
			return logAlias;
		},

		canLog: function() {
			return _canLog();
		},

		start: function() {
			if (loggingUrl) {
				if (_canLog()) {
					$.post(loggingUrl, { alias: logAlias() }, function(response) {
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
			if (logId) {
				$.post(loggingUrl + logId + '.json', { _method: 'PUT', state: json }, function(response) {

				}).fail(function(response) {
					console.warn('Logging update failed.');
					console.warn(response);
					logId = null;
				});
			}
			var state = JSON.parse(json);
			updateCallbacks.forEach(function(callback) {
				callback(state);
			});
		},

		receive: function(input) {
			Opal.gvars.engine.$receive(input);
		},

		onStart: function(callback) {
			startCallbacks.push(callback);
		},

		onUpdate: function(callback) {
			updateCallbacks.push(callback);
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
