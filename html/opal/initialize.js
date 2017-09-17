Gamefic.onStart(function() {
	return new Promise((resolve) => {
		Opal.gvars.engine.$run();	
		var state = Opal.gvars.engine.$user().$character().$state();
		var json = state.$to_json();
		resolve(JSON.parse(json));
	});
});

Gamefic.onReceive(function(input) {
	Opal.gvars.engine.$receive(input);
	var state = Opal.gvars.engine.$user().$character().$state();
	var json = state.$to_json();
	return JSON.parse(json);
});

Gamefic.onRestore(function(data) {
	var current = JSON.parse(Opal.gvars.plot.$metadata().$to_json());
	var snapshot = Opal.JSON.$parse(JSON.stringify(data));
	return new Promise((resolve, reject) => {
		if (JSON.stringify(current) == JSON.stringify(data.metadata)) {
			Opal.gvars.plot.$restore(snapshot);
			var preState = JSON.parse(Opal.gvars.engine.$user().$character().$state().$to_json());
			Opal.gvars.plot.$update();
			Opal.gvars.plot.$ready();
			var postState = JSON.parse(Opal.gvars.engine.$user().$character().$state().$to_json());
			postState.output = preState.output;
			resolve(postState);
		} else {
			reject('Incompatible snapshot');
		}
	});
});

Gamefic.onSave(function(filename, data) {
	var snapshot = Opal.JSON.$generate(data);
	localStorage.setItem(filename, snapshot);	
});
