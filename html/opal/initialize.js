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

Gamefic.onRestore(function(json) {
	var snapshot = Opal.JSON.$parse(json);
	return new Promise((resolve) => {
		Opal.gvars.plot.$restore(snapshot);
		Opal.gvars.engine.$user().$character().$flush();
		Opal.gvars.engine.$user().$character().$cue(Opal.gvars.plot.$default_scene());
		Opal.gvars.plot.$update();
		Opal.gvars.plot.$ready();
		Opal.gvars.engine.$user().$character().$tell('Game restored to last available turn.');
		var state = Opal.gvars.engine.$user().$character().$state();
		var response = state.$to_json();
		resolve(JSON.parse(response));
	});
});

Gamefic.onSave(function(filename, data) {
	localStorage.setItem(filename, Opal.JSON.$generate(data));	
});
