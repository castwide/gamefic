import React from 'react';
import {Output} from '../Output';
import {CommandLink} from '../CommandLink';

export class PauseState extends React.Component {
	componentDidMount() {
		this.refs.link.refs.link.focus();
	}

	render() {
		return (
			<div className="PauseState">
				<Output output={this.props.output} />
				<p>
					<CommandLink ref="link" command="" text="Continue..." handleCommand={this.props.handleCommand} />
				</p>
			</div>
		);
	}
}