import React from 'react';
import {ActiveState} from '../ActiveState';
import {MultipleChoiceState} from '../MultipleChoiceState';
import {PauseState} from '../PauseState';
import {YesOrNoState} from '../YesOrNoState';

export class Console extends React.Component {
	constructor(props) {
	  super(props);
	  Opal.gvars.engine.$run();
		  var state = Opal.gvars.engine.$user().$character().$state();
		  var json = state.$to_json();
	  var state = JSON.parse(json);
	  this.state = state;
	}
  
	handleCommand(input) {
	  Opal.gvars.engine.$receive(input);
	  var state = Opal.gvars.engine.$user().$character().$state();
	  var json = state.$to_json();
	  var newState = JSON.parse(json);
	  // HACK: Clear existing state data that is undefined in the new state
	  if (this.state) {
		Object.keys(this.state).forEach((k) => {
		  newState[k] = newState[k] || null;
		});
	  }
	  this.setState(newState);
	}
  
	render () {
	  if (this.state.scene == 'MultipleChoice') {
		return (
			<div className="Console">
				<MultipleChoiceState output={this.state.output} options={this.state.options} handleCommand={this.handleCommand.bind(this)} />
			</div>
		);
	  } else if (this.state.scene == 'Pause') {
		return (
			<div className="Console">
				<PauseState output={this.state.output} handleCommand={this.handleCommand.bind(this)} />
			</div>
		);
	  } else if (this.state.scene == 'YesOrNo') {
		return (
			<div className="Console">
				<YesOrNoState output={this.state.output} handleCommand={this.handleCommand.bind(this)} />
			</div>
		);
	  } else {
		return (
			<div className="Console">
				<ActiveState output={this.state.output} handleCommand={this.handleCommand.bind(this)} />
			</div>
		);
	  }
	}
}
