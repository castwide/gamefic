var Opal;

var Gamefic = new function() {
	let _onStart = null;
	let _onUpdate = null;

	this.onStart = function(callback) {
		_onStart = callback;
	};

	this.onUpdate = function(callback) {
		_onUpdate = callback;
	}

	if (Opal) {
		this.start = function() {
				Opal.gvars.engine.$run();
				var state = Opal.gvars.engine.$user().$character().$state();
				var json = state.$to_json();
				var response = JSON.parse(json);
				if (_onStart) {
					_onStart(response);
				}
		};

		this.receive = function(input) {
			Opal.gvars.engine.$receive(input);
			this.update();
		};

		this.update = function() {
			Opal.gvars.engine.$update();
			var state = Opal.gvars.engine.$user().$character().$state();
			var json = state.$to_json();
			var response = JSON.parse(json);
			if (_onUpdate) {
				_onUpdate(response);
			}
			if (Opal.gvars.engine.$user().$character().$queue().$length() > 0) {
				this.update();
			}
		};
	} else {
		this.start = function() {
			$.post('/start', function(response) {
				if (_onStart) {
					_onStart(response);
				}
			});
		};

		this.receive = function(input) {
			var that = this;
			$.post('/receive', {command: input}, function(response) {
				that.update();
			});
		};

		this.update = function() {
			var that = this;
			$.post('/update', function(response) {
				if (_onUpdate) {
					_onUpdate(response);
				}
				if (response.continued) {
					that.update();
				}
			});
		};
	}
};
