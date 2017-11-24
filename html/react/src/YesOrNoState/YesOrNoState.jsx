import React from 'react';
import {CommandLink} from '../CommandLink';

export class YesOrNoState extends React.Component {
	render() {
		return (
			<div className="YesOrNoState">
				<CommandLink command="Yes" handleCommand={this.props.handleCommand} />
				<CommandLink command="No" handleCommand={this.props.handleCommand} />
			</div>
		);
	}
}
