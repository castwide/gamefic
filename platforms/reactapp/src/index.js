import React from 'react';
import {render} from 'react-dom';
import {Console} from 'react-gamefic';
import {driver} from 'driver';
import 'react-gamefic/styles/ebook';
import './style.css';
var media = require.context('media');

render(
	<Console
		driver={driver}
		mediaContext={media}
		autoScroll={true}
	/>,
	document.getElementById('root')
);
