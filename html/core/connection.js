/*
	Gamefic Connection Object
	
	An interface for connecting web pages to Gamefic engines.
	
	Requirements: jQuery, Gamefic.Engine (engine.js)
	
	Author: Fred Snyder
	Website: http://gamefic.com

	Initialization options:
	
		console
			A jQuery reference to the element that contains the game interface.
		form
			A jQuery reference to the console's form element. The game's form
			should contain, at the minimum, a text input field and a label.
		engine
			An object containing the game code. If the engine is null, the
			connection assumes that the engine is hosted on a web server and
			plays the game by submitting the form. Default is a reference to
			Gamefic.Engine, which is null in its default implementation.
		prompt
			A jQuery reference to the command field's label.
		command
			A jQuery reference to the command input element.
		output
			The element where the game's output is displayed. If null, the
			output gets appended before the form. Default is null.
		commandLinks
			The selector for anchors that execute game commands.
		onUpdate
			The callback that handles game responses. The function expects a
			response object as an argument. If this callback is provided, it
			should assume responsibility for all aspects of the game display,
			such as appending output and updating the prompt.
		onBegin
			A callback that gets executed once after the first update. The
			function expects a response object as an argument.
		onConclude
			The callback that handles the game's ending. The function expects
			a response object as an argument. When the game ends, the onUpdate
			function still gets called before onConclude. If this callback is
			provided, it should assume responsibility for all aspects of the
			game's conclusion, such as hiding or disabling the form.
	
	Response object properties:
	
		command
			The last command received from the user.
		prompt
			The current user prompt. The default is typically ">". Another
			common example is "Press enter to continue..." when the player is
			in the Paused state.
		output
			The most recent message from the game, typically represented as an
			HTML fragment.
		state
			The current player state. Typical states are Active, Paused,
			YesNo, MultipleChoice, Prompted, and Concluded.
		error
			If an error occurred, this property contains the error message.
		backtrace
			If an error occurred, this property contains an array that traces
			the stack of code entry points at the time of the error.
		
*/

var Gamefic = Gamefic || {};
Gamefic.Connection = new function() {
	var config = {};
	var begun = false;
	var pollId;
	var startPolling = function() {
		var busy = false;
		pollId = setInterval(function() {
			if (!busy) {
				
			}
		});
	}
	var endPolling = function() {
		clearInterval(pollId);
	}
	this.init = function(options) {
		var defaultOptions = {
			console: $('#gamefic_console'),
			form: $('#gamefic_console form'),
			engine: Gamefic.Engine,
			command: $('#gamefic_console #gamefic_command'),
			prompt: $('#gamefic_console form label[for="gamefic_command"]'),
			output: null,
			commandLinks: 'a[rel="gamefic"]',
			onBegin: function(response) {
				if (response.output == '' && response.state == 'Active') {
					Gamefic.Connection.run('look');
				}
				config.command.focus();
			},
			onUpdate: function(response) {
				$(config.commandLinks).addClass('disabled');
				if (response.error) {
					_display('<p><strong>' + response.error + '</strong></p>');
				} else {
					_display(response.output);
				}
				config.prompt.html(response.prompt);
				config.command.focus();
				window.scrollTo(0, document.body.scrollHeight);
			},
			onConclude: function(response) {
				config.form.hide();
				_display('<p><strong>' + response.prompt + '</strong></p>');
			}
		}
		config = $.extend(defaultOptions, options);
		if (config.commandLinks) {
			$('body').on('click', config.commandLinks, function(evt) {
				evt.preventDefault();
				if ($(this).hasClass('disabled')) {
					return;
				}
				var cmd = $(this).attr('data-command');
				if (!cmd) cmd = $(this).text();
				Gamefic.Connection.run(cmd);
			});
		}
		config.form.submit(function(evt) {
			evt.preventDefault();
			if (!config.engine) {
				// Submit to hosted engine
				var params = $(this).serialize();
				$.post($(this).attr('action'), params, _update);
			} else {
				// Submit to local engine
				config.engine.run(config.command.val(), _update);
			}
			config.command.val('');
		});
		var _update = function(response) {
			console.log(response.state);
			config.onUpdate(response);
			if (!begun) {
				begun = true;
				config.onBegin(response);
			}
			if (response.state == 'Concluded') {
				config.onConclude(response);
			}
		}
		var _display = function(data) {
			if (config.output) {
				config.output.append(data);
			} else {
				config.form.before(data);
			}
		}
		this.run('');
	}
	this.run = function(command) {
		config.command.val(command);
		config.form.submit();
	}
}
