$(function() {
	$('#gamefic_controls form').submit(function(event) {
		event.preventDefault();
		Gamefic.update($('#gamefic_command').val());
	});
	Gamefic.onStart(function(response) {
		var prompt = response.prompt;
		if (prompt == '>') {
			prompt = 'What do you want to do?'
		}
		$('#gamefic_prompt').html(prompt);
		$('#gamefic_output a[rel="gamefic"]').addClass('disabled');
	});
	Gamefic.onInput(function(response) {
		if (response.input != null) {
			$('#gamefic_output').append('<p><kbd>' + response.prompt + ' ' + response.input + '</kbd></p>');
		}
	});
	Gamefic.onFinish(function(response) {
		$('#gamefic_command').val('');
		$('#gamefic_command').focus();
		var outputElement = document.getElementById('gamefic_output');
		$('#gamefic_output').animate({
			scrollTop: outputElement.scrollHeight
		}, 500);
	});
	Gamefic.handleResponse('Active', function(response) {
		$('#gamefic_output').append(response.output);
	});
	Gamefic.handleResponse('YesOrNo', function(response) {
		$('#gamefic_output').append(response.output);
		$('#gamefic_output').append('<p>(<a href="#" rel="gamefic" data-command="yes">Yes</a> or <a href="#" rel="gamefic" data-command="no">No</a>)</p>');
	});
	Gamefic.handleResponse('MultipleChoice', function(response) {
		var jq = $('<div/>');
		jq.html(response.output);
		jq.find('ol.multiple_choice li').each(function() {
			var item = $(this).text();
			var link = $('<a/>');
			link.attr('href', '#');
			link.attr('rel', 'gamefic');
			link.attr('data-command', item);
			link.text(item);
			$(this).html(link);
		});
		$('#gamefic_output').append(jq);
	});
	Gamefic.handleResponse('Concluded', function(response) {
		if (response.input != null) {
			$('#gamefic_output').append('<p><kbd>' + response.prompt + ' ' + response.input + '</kbd></p>');
		}
		$('#gamefic_console').addClass('concluded');
		$('#gamefic_output').append(response.output);
		$('#gamefic_controls').hide();
	});
	$('#gamefic_output').on('click', 'a[rel="gamefic"]', function(event) {
		event.preventDefault();
		if (!$(this).hasClass('disabled')) {
			Gamefic.update($(this).attr('data-command'));
		}
	});
	Gamefic.start();
	$('#gamefic_command').focus();
});
