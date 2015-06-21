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
}
