var Gamefic = Gamefic || {};
Gamefic.Engine = new function() {
	var begun = false;
	this.run = function(command, callback) {
		try {
			var response = {};
			if (!begun) {
				begun = true;
				Opal.GameficOpal.$static_plot().$introduce(Opal.GameficOpal.$static_player().$character());
				//Opal.GameficOpal.$static_player().$character().$scene().$start(Opal.GameficOpal.$static_player().$character());
				//Opal.GameficOpal.$static_player().$character().$scene().$start(Opal.GameficOpal.$static_player().$character());
				Opal.GameficOpal.$static_plot().$ready();
				response.output = Opal.GameficOpal.$static_player().$state().$output();
			} else {
				if (command != null) {
					Opal.GameficOpal.$static_player().$character().$queue().$push(command);
				}
				Opal.GameficOpal.$static_plot().$update();
				Opal.GameficOpal.$static_plot().$ready();
				response.output = Opal.GameficOpal.$static_player().$state().$output();
			}
			response.prompt = Opal.GameficOpal.$static_player().$character().$scene().$data().$prompt();
			response.command = command;
			response.state = Opal.GameficOpal.$static_player().$character().$scene().$state();
			callback(response);
		} catch(e) {
			console.log("Error in Gamefic.Engine: " + e.message);
			// Make sure the interface isn't rendered unusable by engine errors
			$.modal.close();
			$('#controls').removeClass('disabled');
            $('#controls').find('input').attr('readonly', null);
			$('#gamefic_command').focus();
		}
	}
	this.save = function(filename, data) {
		localStorage.setItem(filename, data);
		Opal.GameficOpal.$static_player().$character().$tell('Game saved to local storage.');
	}
	this.restore = function(filename) {
		var data = localStorage.getItem(filename);
		return data;
	}
}
