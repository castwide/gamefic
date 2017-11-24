import React from 'react';

export class CommandForm extends React.Component {
	constructor(props) {
	  super(props);
	}
  
	handleSubmit(event) {
	  event.preventDefault();
	  var input = this.refs.command.value;
	  this.props.handleCommand(input);
	  this.refs.command.value = '';
	}
  
	componentDidMount() {
	  this.refs.command.focus();
	}
  
	render() {
	  return (
			<form className="CommandForm" action="#" onSubmit={(event) => this.handleSubmit(event)}>
				<input type="text" ref="command" />
			</form>
	  );
	}
}
