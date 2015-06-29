var Gamefic = Gamefic || {};
Gamefic.Engine = new function() {
	var begun = false;
	this.run = function(command, callback) {
		var response = {};
		if (!begun) {
			begun = true;
			Opal.Gamefic.$static_plot().$introduce(Opal.Gamefic.$static_player().$character());
			response.output = Opal.Gamefic.$static_player().$state().$output();
		} else {
			Opal.Gamefic.$static_player().$character().$queue().$push(command);
			Opal.Gamefic.$static_plot().$update();
			Opal.Gamefic.$static_player().$character().$update();
			response.output = Opal.Gamefic.$static_player().$state().$output();
		}
		response.prompt = Opal.Gamefic.$static_player().$character().$scene().$data().$prompt();
		response.command = command;
		response.state = Opal.Gamefic.$static_player().$character().$scene().$state();
		callback(response);
	}
	this.save = function() {
		var hash = Opal.Gamefic.Snapshots.$save(Opal.Gamefic.$static_plot()).$to_n();
		var json = JSON.stringify(hash);
		Cookies.set('snapshot', json, { expires: 1000, path: '' });
		Opal.Gamefic.$static_player().$character().$tell('Game saved to cookies.');
	}
	this.restore = function() {
		var json = Cookies.get('snapshot');
		if (json) {
			Opal.Gamefic.Snapshots.$restore(json, Opal.Gamefic.$static_plot());
			Opal.Gamefic.$static_player().$character().$tell('Saved game restored.');
		} else {
			Opal.Gamefic.$static_player().$character().$tell('No saved game available.');
		}
	}
}
