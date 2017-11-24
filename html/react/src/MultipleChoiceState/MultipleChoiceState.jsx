import React from 'react';
import {Output} from '../Output';
import {CommandLink} from '../CommandLink';
import {CommandForm} from '../CommandForm';

export class MultipleChoiceState extends React.Component {
	optionList() {
		return this.props.options.map((opt, index) => {
		  return (
			<li key={index}>
			  <CommandLink command={opt} handleCommand={this.props.handleCommand} />
			</li>
		  );
		});
	}

	render() {
		return (
			<div className="MultipleChoiceState">
				<Output output={this.props.output} />
				<ol>{this.optionList()}</ol>
				<CommandForm handleCommand={this.props.handleCommand} />
			</div>
		);
	}
}
