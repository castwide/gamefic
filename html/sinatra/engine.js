var Gamefic = (function() {
	var startCallbacks = [];
	var updateCallbacks = [];
	return {
		enableLogging: function() {

		},

		logAlias: function() {

		},

		canLog: function() {
			return false
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
				console.log(JSON.stringify(response));
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
			//var json = Opal.JSON.$generate(data);
			console.log('Saving ' + data);
			localStorage.setItem(filename, data);
			//Opal.GameficOpal.$static_character().$tell('Game saved.');
		},

		restore: function(filename) {
			//var data = Opal.JSON.$parse(localStorage.getItem(filename));
			var json = localStorage.getItem(filename);
			var data = JSON.parse(json);
			//var metadata = data.metadata;
			// HACK Converting hashes to strings for JavaScript comparison
			//if (metadata.$to_s() != Opal.GameficOpal.$static_plot().$metadata().$to_s()) {
			//	Opal.GameficOpal.$static_character().$tell('The saved data is not compatible with this version of the game.');
			//	return Opal.nil;
			//} else {
				//return data;
			//}
			console.log('Data: ' + JSON.stringify(data));
			$.post('/restore', {snapshot: data}, function(response) {
				console.log('Updated.')
				that.update(response);
			});
		}
	}
})();
