import React from 'react';
import {Output} from '../Output';
import {CommandForm} from '../CommandForm';

export class ActiveState extends React.Component {
	render() {
		return (
			<div className="ActiveState">
				<Output output={this.props.output} />
				<CommandForm handleCommand={this.props.handleCommand} />
			</div>
		);
	}
}
