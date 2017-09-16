Gamefic.onStart(function() {
	Opal.gvars.engine.$run();	
	var state = Opal.gvars.engine.$user().$character().$state();
	var json = state.$to_json();
	return JSON.parse(json);
});

Gamefic.onReceive(function(input) {
	Opal.gvars.engine.$receive(input);
	var state = Opal.gvars.engine.$user().$character().$state();
	var json = state.$to_json();
	return JSON.parse(json);
});

Gamefic.onRestore(function(json) {
	console.log('Snapshot: ' + json);
	var snapshot = Opal.JSON.$parse(json);
	Opal.gvars.plot.$restore(snapshot);
	Opal.gvars.engine.$user().$character().$flush();
	Opal.gvars.engine.$user().$character().$cue(Opal.gvars.plot.$default_scene());
	Opal.gvars.plot.$update();
	Opal.gvars.plot.$ready();
	Opal.gvars.engine.$user().$character().$tell('Game restored to last available turn.');
	var state = Opal.gvars.engine.$user().$character().$state();
	var json = state.$to_json();
	return JSON.parse(json);
});
