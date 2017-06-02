var Gamefic = (function() {
	var startCallbacks = [];
	var updateCallbacks = [];
	return {
		enableLogging: function() {

		},

		logAlias: function() {

		},

		canLog: function() {
			return false;
		},

		start: function() {
			var that = this;
      $.post('/start', function(response) {
				startCallbacks.forEach(function(callback) {
					callback();
				});
				that.update(response);
      });
		},

		update: function(response) {
			updateCallbacks.forEach(function(callback) {
				callback(response);
			});
		},

		receive: function(input) {
			var that = this;
			$.post('/update', {command: input}, function(response) {
				that.update(response);
			}).fail(function(response) {
				console.log('An error occurred');
			});
		},

		onUpdate: function(callback) {
			updateCallbacks.push(callback);
		},

		onStart: function(callback) {
			updateCallbacks.push(callback);
		},

		save: function(filename, data) {
			console.log('Saving ' + data);
			localStorage.setItem(filename, data);
		},

		restore: function(filename) {
			var json = localStorage.getItem(filename);
			var data = JSON.parse(json);
			var that = this;
			$.post('/restore', {snapshot: JSON.stringify(data)}, function(response) {
				console.log('Restored a snapshot.');
				that.update(response);
			});
		}
	}
})();
