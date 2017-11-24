import React from 'react';

export class Output extends React.Component {
	render() {
	  return (
		<div className="Output" dangerouslySetInnerHTML={{ __html: this.props.output }}></div>
	  )
	}
  }
  